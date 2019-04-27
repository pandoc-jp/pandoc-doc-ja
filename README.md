# pandoc-doc-ja: Pandocユーザーズガイド日本語版

[Pandoc User's Guide](http://pandoc.org/MANUAL.html) を日本語訳するプロジェクトです。

[従来の日本語訳](http://sky-y.github.io/site-pandoc-jp/users-guide/)はバージョン `1.12.4.2` 準拠（翻訳時点で2014年6月27日）ですが、
かなり古くなってしまったので新たに翻訳しようとしています。

## 翻訳するバージョン

- Pandoc ~~2.5~~ 2.7.2
    - それ以降に大きなアップデートがあった場合は、可能な範囲で追従する

## 使用ツール・Webサービスまとめ

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
$ pipenv update
$ pipenv lock -r > requirements.txt
```

`requirements.txt` は、Read the Docsでビルドするために必要です。
