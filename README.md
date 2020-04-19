# pandoc-doc-ja: Pandocユーザーズガイド日本語版

[Pandoc User's Guide](http://pandoc.org/MANUAL.html) を日本語訳するプロジェクトです。

[従来の日本語訳](http://sky-y.github.io/site-pandoc-jp/users-guide/)はバージョン `1.12.4.2` 準拠（翻訳時点で2014年6月27日）ですが、
かなり古くなってしまったので新たに翻訳しようとしています。

### Pandocのバージョンについて

ここでいう「Pandocのバージョン」は3つあります。

- 翻訳対象Pandocバージョン
    - 翻訳するターゲットとなるユーザーズガイドのバージョン
    - ja-pandoc-version-lock に記述してあります
- 元リポジトリPandocバージョン
    - [jgm/pandoc](https://github.com/jgm/pandoc)のバージョン (git submodule管理)
    - `make ja-version-jgm` もしくは `./scripts/pandoc-version.sh` で表示
- ツール用Pandocバージョン
    - Makefileの中で使う`pandoc`のバージョン
    - 任意だが最新版を推奨

## 使用ツール・Webサービスまとめ

- Python環境
    - Pipenv: 必要なライブラリを管理
    - pyenv（オプション）：Python自体のバージョンを管理
- GitHub
    - jgm/pandocのMANUAL.txt: `git submodule` で追随
    - このリポジトリ（pandoc-jp/pandoc-doc-ja）
- [Pandoc](http://pandoc.org/)
    - ツールとして変換
        - MANUAL.txt (Pandoc's Markdown) -> users-guide.rst (reStructuredText)
    - 後述のsphinx-intlによる国際化の恩恵を受けるためには、reSTで書く必要がある
- [Sphinx](https://www.sphinx-doc.org/ja/master/index.html)
    - reSTからHTML（サイト）を構築
    - 国際化 ([sphinx-intl](https://www.sphinx-doc.org/ja/master/usage/advanced/intl.html))
- [Transifex](https://www.transifex.com/)
    - 事前に原文のpotファイルをアップロード
    - 翻訳者がテキストを翻訳（ブラウザ上で共同作業）
    - 翻訳ファイル(po)を最終的にダウンロードする
- [Read the Docs](https://readthedocs.org/)
    - GitHub上のSphinxサイトをビルドして公開
    - 必要なライブラリに関しては requirements.txt が参照される（Pipenvから要エクスポート）

## 初期設定：Dockerを使う場合

このプロジェクトのDockerfileは[sphinxdoc/sphinx](https://hub.docker.com/r/sphinxdoc/sphinx)をベース(`FROM`)にしています。

- 参考: [Sphinxのインストール — Sphinx 4\.0\.0\+/c443e742f ドキュメント](https://www.sphinx-doc.org/ja/master/usage/installation.html#docker)

## docker pull

TODO

## ローカルで docker build

```
docker build . -t skyy0079:pandoc-doc-ja
```

## docker run

Bashにログインする場合(インタラクティブ実行)

```
docker run -v 【カレントディレクトリ】:/docs -it skyy0079:pandoc-doc-ja /bin/bash
```

`make ja-html`コマンドを実行する場合（`ja-html`の部分を任意のmakeサブコマンドにできる）

```
docker run -v 【カレントディレクトリ】:/docs -it skyy0079:pandoc-doc-ja make ja-html
```

翻訳後のHTMLをビルドする場合（本家`sphinxdoc/sphinx`と違い、`make ja-html`をデフォルトで実行します）

```
docker run -v 【カレントディレクトリ】:/docs -it skyy0079:pandoc-doc-ja
```

### 応用（Docker for Windowsにおける【カレントディレクトリ】）

WSL(1 or 2)上のカレントディレクトリからアクセスしたい場合(ホストBashからゲストBashにログイン)

- `wslpath -aw`: WSL上のパスをフルパス(`/mnt/c/...`)にした上で、Windows上のパスに変換する

```
docker run -v $(wslpath -aw $(pwd)):/docs -it skyy0079:pandoc-doc-ja /bin/bash
```

## 初期設定：手動でインストールする場合

### ツール用Pandocのインストール

Makefileの中で使う`pandoc`をあらかじめインストールしておいてください。
（翻訳対象Pandocバージョンにかかわらず、その時点での最新版のインストールを推奨します）

### Pythonのバージョンについて

Python3系を前提とします。厳密な動作バージョンは調査していませんが、Python3.7以上であれば動くと思います。

一度普段使っているPythonでPipenvを使ってみて、ダメそうならpyenvでインストール・バージョン指定してみてください。

### Pythonのインストール：pyenvを使う手順（必要に応じて）

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

# コマンド実行
(.venv) $ sphinx-build --version
sphinx-build 2.3.0

# 仮想環境シェルを終了
$ deactivate
```

## txコマンド (Transifex Client) のセットアップ

※ 事前にブラウザ上でTransifexにログインできる状態で以下を行ってください。

- Transifexの[APIトークン](https://www.transifex.com/user/settings/api/)ページで「トークンを生成」
    - トークン文字列を記録しておく
- `~/.transifexrc` というファイルを新規作成し、次のように記入する
    - 間違ってこのGitリポジトリにpushしないこと！

```.transifexrc
[https://www.transifex.com]
api_hostname = https://api.transifex.com
hostname = https://www.transifex.com
token = 【トークン文字列】
```

## ビルド

`make`コマンドでビルドを行います。ここに書いてないコマンドはMakefileを参照。
（従来はMakefileが2つありましたが、1つのMakefileに統合しました）

```
# ビルドのための初期設定をする (pipenv install, git submodule: jgm/pandoc)
# 注意：Transifex Client (tx) の設定を別途すること
$ make ja-init

# 元リポジトリPandocバージョンを表示する
$ make jgm-pandoc-version

# 翻訳対象Pandocバージョンを表示する
$ make ja-pandoc-version

# jgm/pandoc のtag「2.7.2」にチェックアウトする
$ make jgm-pandoc-checkout PANDOC=2.7.2

# アップデート作業をまとめてする (pandoc -> intl-update -> tx-push-pot)
$ make ja-update-src

# Transifexから翻訳ファイル(po)をpullし、そのままビルドする
$ make ja-build

# Pipenv: pipenv updateして、requirements.txt に書き出す
$ make pipenv-update
```

## Sphinxのアップデート

PipenvというPython用パッケージマネージャを用いてアップデートします（事前にインストールしておく）。

まず `Pipfile` を書き換えて、必要なパッケージのバージョンを指定します。

その後、次の手順でアップデートします。

```
make pipenv-update
```

※ このとき生成される `requirements.txt` は、Read the Docsでビルドするために必要です。
