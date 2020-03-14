# pandoc-doc-ja: Pandocユーザーズガイド日本語版

[Pandoc User's Guide](http://pandoc.org/MANUAL.html) を日本語訳するプロジェクトです。

[従来の日本語訳](http://sky-y.github.io/site-pandoc-jp/users-guide/)はバージョン `1.12.4.2` 準拠（翻訳時点で2014年6月27日）ですが、
かなり古くなってしまったので新たに翻訳しようとしています。

## 翻訳するバージョン

- Pandoc ~~2.5~~ 2.7.2
    - それ以降に大きなアップデートがあった場合は、可能な範囲で追従する

## 使用ツール・Webサービスまとめ

- Pipenv (Python)
    - Sphinxのために必要なライブラリを管理
- GitHub
    - jgm/pandocのMANUAL.txt: `git submodule` で追随
    - このリポジトリ（pandoc-jp/pandoc-doc-ja）
- [Pandoc](http://pandoc.org/)
    - 変換: MANUAL.txt(markdown) -> users-guide.rst(reStructuredText, reST)
    - 後述のsphinx-intlによる国際化の恩恵を受けるためには、reSTで書く必要があります
- [Sphinx](https://www.sphinx-doc.org/ja/master/index.html)
    - reSTからHTML（サイト）を構築
    - 国際化 ([sphinx-intl](https://www.sphinx-doc.org/ja/master/usage/advanced/intl.html))
    - Sphinxのインストールに、Pythonの[Pipenv](https://pipenv-ja.readthedocs.io/ja/translate-ja/)を利用
- [Transifex](https://www.transifex.com/)
    - 実際にテキストを翻訳（ブラウザ上で共同作業）
- [Read the Docs](https://readthedocs.org/)
    - GitHub上のSphinxサイトをビルドして公開
    - 必要なライブラリに関しては requirements.txt が参照される（Pipenvから要エクスポート）

## 初期設定

### Pythonのバージョンについて

Python3系を前提とします。厳密な動作バージョンは調査していませんが、Python3.7以上であれば動くと思います。

一度普段使っているPythonでPipenvを使ってみて、ダメそうならpyenvでインストール・バージョン指定してみてください。

### Pythonのインストール：pyenvを使う手順

もしくはpyenvでPython3系のバージョンを切り替えます（ついでに最新版もインストールする手順を示します）。

※ 手元ではWSLのUbuntuのシステムPythonが該当

- 必要なライブラリをインストール
    - [Common build problems · pyenv/pyenv Wiki](https://github.com/pyenv/pyenv/wiki/Common-build-problems) を参照
- pyenvのインストール
    - Homebrew: `brew install pyenv`
    - [pyenv installer](https://github.com/pyenv/pyenv-installer): `curl https://pyenv.run | bash`
    - または手動インストール: [pyenv/pyenv](https://github.com/pyenv/pyenv) を参照
- pyenvを使ったPythonのインストール

```shell
pyenv install -l
(一覧が表示されるので、最新っぽいPythonのバージョンを選ぶ→今回は3.8.2)
pyenv install 3.8.2
pyenv global 3.8.2
```

`python -V` でバージョンを確かめてみてください（「Python 3.8.2」のようになっていればOK）。
バージョンが変わっていなかったらPATHを通していない可能性があるので、確認の上PATHを通す。

```shell
# 確認
echo $PYENV_ROOT
echo $PATH

# 追加
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
echo 'export PATH="$PYENV_ROOT/shims:$PATH"' >> ~/.bash_profile
```

### 必要なライブラリのインストール（Pipenv）

Pipenv本体のインストール：

```shell
pip install --upgrade pip
```

既存プロジェクトの必要パッケージをPipfile.lockからインストール：

```shell
pipenv install
```

### 補足：Pipenvでインストールされたコマンドの実行

`pipenv run` を先頭に付けて実行すると、Python仮想環境内で実行したことになります。

```shell
# 例：Sphinxのバージョンを確かめる
$ pipenv run sphinx-build --version
sphinx-build 2.3.0
```

仮想環境内のシェルに入るには`pipenv shell`を使います。

```shell
# 仮想環境シェルに入る (activate)
$ pipenv shell
(.venv) $ sphinx-build --version
sphinx-build 2.3.0

# 仮想環境シェルを終了
$ deactivate
```

## ビルド

`make`コマンドでビルドを行います。Makefileは2つあるので注意してください。

- `Makefile`: Sphinx付属のMakefile
- `Makefile.pandoc`: このプロジェクトで使うMakefile、こちらを使う（`-f` オプションで指定）

```
# jgm/pandoc のtag「2.7.2」にチェックアウトする
$ make -f Makefile.pandoc checkout PANDOC=2.7.2

# Pandoc: jgm/pandocの MANUAL.txt (Markdown) をrstに変換する
make -f Makefile.pandoc pandoc

# users-guide.rst (原文)を更新するときに、翻訳ファイル (pot/po) をupdateする
make -f Makefile.pandoc intl-update

# アップデート作業をまとめてする (pandoc -> intl-update)
make -f Makefile.pandoc update

# Transifex(tx): poファイルをpushする
make -f Makefile.pandoc tx-push-source

# Transifex(tx): poファイルをpullする
make -f Makefile.pandoc tx-pull

# Sphinx: htmlを生成する
make -f Makefile.pandoc html
```

## Sphinxのアップデート

PipenvというPython用パッケージマネージャを用いてアップデートします（事前にインストールしておく）。

まず `Pipfile` を書き換えて、必要なSphinxのバージョンを指定します。

その後、次の手順でアップデートします。

```
pipenv update
pipenv lock -r > requirements.txt
```

`requirements.txt` は、Read the Docsでビルドするために必要です。
