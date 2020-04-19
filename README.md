# pandoc-doc-ja: Pandocユーザーズガイド日本語版

[Pandoc User's Guide](http://pandoc.org/MANUAL.html) を日本語訳するプロジェクトです。

[従来の日本語訳](http://sky-y.github.io/site-pandoc-jp/users-guide/)はバージョン `1.12.4.2` 準拠（翻訳時点で2014年6月27日）ですが、
かなり古くなってしまったので新たに翻訳しようとしています。

### Pandocのバージョンについて

ここでいう「Pandocのバージョン」は2つあります。

- **翻訳対象バージョン**
    - 翻訳するターゲットとなるユーザーズガイドのバージョン
    - 今のGitリポジトリ [jgm/pandoc](https://github.com/jgm/pandoc) のバージョン（tag）
        - `git submodule` で管理
    - `ja-pandoc-version-lock` ファイルに記述してある
- **ツール用バージョン**
    - Makefileの中で使う`pandoc`のバージョン
    - Dockerfileの `PANDOC_VERSION` で定義

## 使用ツール・Webサービスまとめ

### ツール

以下のツールはDockerイメージで整うようにしています。

- [Pandoc](http://pandoc.org/)
    - 補助的な変換ツールとして用いる
        - MANUAL.txt (`markdown`) -> users-guide.rst (`rst`)
        - 後述のsphinx-intlによる国際化の恩恵を受けるためにreSTに変換する
- [Sphinx](https://www.sphinx-doc.org/ja/master/index.html)
    - reSTからHTML（サイト）を構築
    - [sphinx-intl](https://www.sphinx-doc.org/ja/master/usage/advanced/intl.html): 国際化のための拡張機能
- [Transifex](https://www.transifex.com/) / `tx` コマンド (CLI)
    - 事前に原文のpotファイルをアップロード
    - 翻訳者がテキストを翻訳（ブラウザ上で共同作業）
    - 翻訳ファイル(po)を最終的にダウンロードする

### Webサービス

- GitHub
    - [jgm/pandoc](https://github.com/jgm/pandoc)
        - ユーザーズガイド原文(MANUAL.txt)
        - `git submodule` で取り込む
    - [pandoc-jp/pandoc-doc-ja](https://github.com/pandoc-jp/pandoc-doc-ja/): このリポジトリ
        - 日本Pandocユーザ会 サイト
        - ユーザーズガイド日本語版
- [Read the Docs](https://readthedocs.org/)
    - GitHub上のSphinxサイトをビルドして公開
    - 必要なライブラリに関しては requirements.txt が参照される（Pipenvから要エクスポート）

## 初期設定：Dockerを使う場合

このプロジェクトのDockerfileは[sphinxdoc/sphinx](https://hub.docker.com/r/sphinxdoc/sphinx)をベース(`FROM`)にしています。

- 参考: [Sphinxのインストール — Sphinx 4\.0\.0\+/c443e742f ドキュメント](https://www.sphinx-doc.org/ja/master/usage/installation.html#docker)

### txコマンド (Transifex Client) のセットアップ

- Transifexの[APIトークン](https://www.transifex.com/user/settings/api/)ページで「トークンを生成」
    - トークン文字列を記録しておく

- ホスト側のシェルで、トークン文字列を環境変数 `TX_TOKEN` に設定
    - Bash: `export TX_TOKEN=【トークン文字列】`
    - 必要に応じて .bashrc 等に同じコマンドを書く

※ `~/.transifexrc` というファイルを新規作成する方法もありますが、間違ってこのGitリポジトリにpushしないように環境変数で読み込ませます

詳細: [Init: Initialization \| Transifex Documentation](https://docs.transifex.com/client/init)

## docker pull

TODO

## ローカルで docker build

```
docker build -t skyy0079/pandoc-doc-ja .
```

## docker run

※ `-v ホスト側ディレクトリ:コンテナ側ディレクトリ` で、カレントディレクトリを読み込ませる。

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

## ビルド

`make`コマンドでビルドを行います。ここに書いてないコマンドはMakefileを参照。

### 初期設定

```
# ビルドのための初期設定をする (git submodule: jgm/pandoc)
make ja-init
```

### Pandocバージョン関連

```
# 元リポジトリPandocバージョンを表示する (pandoc/pandoc.cabalのversionを参照)
make jgm-pandoc-version

# 翻訳対象Pandocバージョンを表示する (./ja-pandoc-version-lock ファイルを参照)
make ja-pandoc-version

# 翻訳対象Pandocバージョンをjgm/pandocのものに固定する (ファイルに書き出すだけ)
make ja-pandoc-version-lock
```

### 原文アップデート系

(jgm/pandoc:MANUAL.txt のアップデートと翻訳ファイルの更新)

```
# jgm/pandocを特定バージョンでチェックアウト
make jgm-pandoc-checkout PANDOC=バージョン番号

# Pandoc: jgm/pandocの MANUAL.txt (Markdown) をrstに変換する
make ja-pandoc

# users-guide.rst (原文) を更新するときに、翻訳ファイル (pot/po) を更新する
make intl-update

# Transifex: 【翻訳前pot】手元の更新後ソースファイル(pot)をpushする
make tx-push-pot

# アップデート作業をまとめてする (pandoc -> intl-update -> tx-push-pot)
make ja-update-src
```

### ビルド：ユーザーズガイド用rst

```
# ユーザーズガイドのrstをビルド
# (Pandocテンプレートのみを入力としたいため、形式的に入力ファイルを無し(/dev/null)とする)
make ja-users-guide-rst
```

### ビルド：全体

```
# Transifex: 【翻訳後po】Transifexから最新の翻訳ファイル(po)をpullする
make tx-pull

# Sphinx: htmlをビルドする
make ja-html

# Transifexから翻訳ファイル(po)をpullし、そのままビルドする
make ja-build

# ローカル環境で必要なアップデート・ビルド作業をまとめてする
make ja-build-local
```

### その他

```
# Transifex: 【翻訳後po】手元の翻訳ファイル(po)をpushする
make tx-push-local-po
```

## 付録

### 初期設定：手動でインストールする場合

Makefileの中で使う`pandoc`をあらかじめインストールしておいてください。
（翻訳対象バージョンにかかわらず、その時点での最新版のインストールを推奨します）

Pythonのバージョンについては、Python3系を前提とします。

### pipでインストール

以下をpip (pip3) でインストールします。

- Sphinx
- sphinx-intl
- tx (Transifex Client)

実際には requirements.txt でまとめてインストールします。

```
pip3 install -r requirements.txt
```
