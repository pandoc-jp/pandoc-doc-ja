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
- ホスト側のカレントディレクトリに環境変数ファイル `.env` を新規作成する
    - このファイルは`git add`しないこと！（`.gitignore`には入っている）
    - 内容は次のように書く

```.env
TX_TOKEN=【APIトークン】
```

- `docker run` にて `--env-file .env` オプションでコンテナ側に環境変数を読み込ませる

※ `~/.transifexrc` というファイルを新規作成する方法もありますが、Dockerを使う場合は環境変数で読み込ませるのがよいでしょう。

詳細: [Init: Initialization \| Transifex Documentation](https://docs.transifex.com/client/init)

## docker pull

TODO

## ローカルで docker build

```
docker build -t skyy0079/pandoc-doc-ja .
```

## docker run

※ `-v ホスト側ディレクトリ:コンテナ側ディレクトリ` で、カレントディレクトリを読み込ませる。

### Bashにログインする（インタラクティブ実行）

```
docker run -v 【カレントディレクトリ】:/docs -it skyy0079/pandoc-doc-ja /bin/bash
```

例（macOSや純粋なLinux環境のBash）：

```
docker run -v $(pwd):/docs -it skyy0079/pandoc-doc-ja bash
```

### 任意のコマンドを実行する（環境変数を使わない場合、`make`コマンド含む）

- 例：`make ja-html`コマンドを実行する場合
    - `make ja-html`の部分を任意のコマンドにできる
- `-it` はインタラクティブ実行が必要なときのみ付ける（シェルなど）

```
docker run -v $(pwd):/docs skyy0079/pandoc-doc-ja make ja-html
```

※ コマンドを指定しなかった場合のデフォルトは`make ja-html`

```
docker run -v $(pwd):/docs skyy0079/pandoc-doc-ja
```

### 環境変数を使うコマンドを実行する（txコマンド、`make tx-pull`など）

- `docker run` にて `--env-file .env` オプションでコンテナ側に環境変数を読み込ませる

```
docker run -v $(pwd):/docs --env-file .env skyy0079/pandoc-doc-ja make tx-pull
```

### Docker for Windowsにおける【カレントディレクトリ】

WSL(1 or 2)上のカレントディレクトリからアクセスしたい場合(ホストBashからゲストBashにログイン)

- `wslpath -aw`: WSL上のパスをフルパス(`/mnt/c/...`)にした上で、Windows上のパスに変換する

```
docker run -v $(wslpath -aw $(pwd)):/docs -it skyy0079/pandoc-doc-ja bash
```

## `make`コマンド一覧

このプロジェクトにおけるあらゆる操作は、`make`コマンドで行えます。
Makefileに書いてある記述を元に、直接元のコマンドを打っても動くはずです。

下記では`docker run ...`を省略した形で記述します。

- 例: `make ja-html` を実行
    - 直接実行
        - `docker run -v $(pwd):/docs skyy0079/pandoc-doc-ja make ja-html`
    - Bashから実行
        - `docker run -v $(pwd):/docs -it skyy0079/pandoc-doc-ja bash`
        - `make ja-html`
- 例: `make tx-pull` の実行（環境変数が必要なコマンド）
    - 直接実行
        - `docker run -v $(pwd):/docs --env-file .env skyy0079/pandoc-doc-ja make tx-pull`
    - Bashから実行
        - `docker run -v $(pwd):/docs --env-file .env -it skyy0079/pandoc-doc-ja bash`
        - `echo $TX_TOKEN` (環境変数が渡されていることを確認)
        - `make tx-pull`

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
# 要環境変数: --env-file .env
make tx-push-pot

# アップデート作業をまとめてする (pandoc -> intl-update -> tx-push-pot)
# 要環境変数: --env-file .env
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
# 要環境変数: --env-file .env
make tx-pull

# Sphinx: htmlをビルドする
make ja-html

# Transifex: 翻訳ファイル(po)をpullし、そのままビルドする
# 要環境変数: --env-file .env
make ja-build

# ローカル環境のみ：原文rst変換・pot/poアップデート・ビルドをまとめてする
# (ja-pandoc -> intl-update -> ja-html)
make ja-build-local
```

### その他

```
# Transifex: 【翻訳後po】手元の翻訳ファイル(po)をpushする
# 要環境変数: --env-file .env
make tx-push-local-po
```

## 典型的なワークフロー

下記の実行のために、あらかじめコンテナのBashにログインしておきます（環境変数も読み込ませる）。

```
docker run -v $(pwd):/docs --env-file .env -it skyy0079/pandoc-doc-ja bash
```

### Pandoc翻訳対象バージョンのアップグレード

例: Pandoc 2.9.2.1 にバージョンアップ

```
make jgm-pandoc-checkout PANDOC=2.9.2.1
make ja-update-src
git add *
git commit -m '[pandoc upgrade] 翻訳対象バージョンを2.9.2.1にアップグレード'
git push origin master
```

### HTMLビルド（Transifex上で翻訳済のpoファイルをpullしてから）

現段階の翻訳を取り込む際はこちら。

```
make ja-build
```

随時 `./_build/html/index.html` をブラウザで開いて確認する。

### HTMLビルド（ローカルファイルの変更をチェックしたいとき）

特にPandocテンプレートや翻訳前のrstをいじる際はこちら。

```
make ja-build-local
```

随時 `./_build/html/index.html` をブラウザで開いて確認する。

### ビルドしたものをGitHubにpush

```
git add *
git commit -m '[update] 現時点での翻訳を取り込んでビルド'
git push origin master
```

GitHubにpushできたら、Read the Docs側で自動的にビルド・更新されデプロイされる。

確認する: <https://pandoc-doc-ja.readthedocs.io/ja/latest/>

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
