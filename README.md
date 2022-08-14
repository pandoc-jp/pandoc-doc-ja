# pandoc-doc-ja: Pandocユーザーズガイド日本語版

[Pandoc User's Guide](http://pandoc.org/MANUAL.html) を日本語訳するプロジェクトです。

- [日本Pandocユーザ会](https://pandoc-doc-ja.readthedocs.io/ja/latest/)
    - [Pandocユーザーズガイド 日本語版](https://pandoc-doc-ja.readthedocs.io/ja/latest/users-guide.html)

## Pandocのバージョンについて

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
-  `tx` コマンド (Transifex Client)
    - 翻訳作業で使うWebサービス[Transifex](https://www.transifex.com/) のクライアント
    - po/potファイルををpush/pullする（後述）

### Webサービス

- GitHub
    - [jgm/pandoc](https://github.com/jgm/pandoc)
        - ユーザーズガイド原文(MANUAL.txt)
        - `git submodule` で取り込む
    - [pandoc-jp/pandoc-doc-ja](https://github.com/pandoc-jp/pandoc-doc-ja/): このリポジトリ
        - 日本Pandocユーザ会 サイト
        - ユーザーズガイド日本語版
- [Transifex](https://www.transifex.com/)
    - 翻訳作業で使うWebサービス
    - 翻訳者がテキストを翻訳（ブラウザ上で共同作業）
- [Read the Docs](https://readthedocs.org/)
    - GitHub上のSphinxサイトをビルドして公開
    - 必要なライブラリに関しては requirements.txt が参照される

## 初期設定：Dockerを使う場合

Docker Hubの[pandocjp/pandoc-doc-ja](https://hub.docker.com/r/pandocjp/pandoc-doc-ja)でイメージを公開しています。

- 参考: ベースイメージは [sphinxdoc/sphinx](https://hub.docker.com/r/sphinxdoc/sphinx) です
    - [Sphinxのインストール — Sphinx 4\.0\.0\+/c443e742f ドキュメント](https://www.sphinx-doc.org/ja/master/usage/installation.html#docker)

### txコマンド (Transifex Client) のセットアップ

※ APIトークンを持っている人のみ。権限ほしい人は[日本Pandocユーザ会Slack](https://join.slack.com/t/jpang/shared_invite/enQtNjE1MTgzOTkxMjgyLWEzNGVhMmZhODE4ZTVjNDhiYmU1OGNkYzJlZjMwM2NlNmNlNzJmOGY4YzFmYjQ1MTVlNjJiNzk1MzI3ODdmNmY)で相談してください。

（[翻訳の手引 for Pandocユーザーズガイド](https://pandoc-doc-ja.readthedocs.io/ja/latest/trans-intro.html)も参照）

- Transifexの[APIトークン](https://www.transifex.com/user/settings/api/)ページで「トークンを生成」
    - トークン文字列を記録しておく
- ホスト側のカレントディレクトリに環境変数ファイル `.env` を新規作成する
    - このファイルは`git add`しないこと！

`.env` ファイルは次のように書きます。

```.env
TX_TOKEN=【APIトークン】
```

- `docker run` にて `--env-file .env` オプションでコンテナ側に環境変数を読み込ませる

※ `~/.transifexrc` というファイルを新規作成する方法もありますが、Dockerを使う場合は環境変数で読み込ませるのがよいでしょう。

詳細: [Init: Initialization \| Transifex Documentation](https://docs.transifex.com/client/init)

## docker pull

```
docker pull pandocjp/pandoc-doc-ja
```

## ローカルで docker build

```
docker build -t pandocjp/pandoc-doc-ja .
```

## docker run

※ `-v ホスト側ディレクトリ:コンテナ側ディレクトリ` で、カレントディレクトリを読み込ませる。

### Bashにログインする（インタラクティブ実行）

```
docker run -v 【カレントディレクトリ】:/docs -it pandocjp/pandoc-doc-ja /bin/bash
```

例（macOSや純粋なLinux環境のBash）：

```
docker run -v $(pwd):/docs -it pandocjp/pandoc-doc-ja bash
```

### 任意のコマンドを実行する（環境変数を使わない場合、`make`コマンド含む）

- 例：`make ja-html`コマンドを実行する場合
    - `make ja-html`の部分を任意のコマンドにできる
- `-it` はインタラクティブ実行が必要なときのみ付ける（シェルなど）

```
docker run -v $(pwd):/docs pandocjp/pandoc-doc-ja make ja-html
```

※ コマンドを指定しなかった場合のデフォルトは`make ja-html`

```
docker run -v $(pwd):/docs pandocjp/pandoc-doc-ja
```

### 環境変数を使うコマンドを実行する（txコマンド、`make tx-pull`など）

- `docker run` にて `--env-file .env` オプションでコンテナ側に環境変数を読み込ませる

```
docker run -v $(pwd):/docs --env-file .env pandocjp/pandoc-doc-ja make tx-pull
```

### Docker for Windowsにおける【カレントディレクトリ】

WSL(1 or 2)上のカレントディレクトリからアクセスしたい場合(ホストBashからゲストBashにログイン)

- `wslpath -aw`: WSL上のパスをフルパス(`/mnt/c/...`)にした上で、Windows上のパスに変換する

```
docker run -v $(wslpath -aw $(pwd)):/docs -it pandocjp/pandoc-doc-ja bash
```

## `make`コマンド一覧

このプロジェクトにおけるあらゆる操作は、`make`コマンドで行えます。
Makefileに書いてある記述を元に、直接元のコマンドを打っても動くはずです。

```shell
# 例: Sphinxでhtmlをビルドする
$ make ja-html
```

### ターゲット：まとめて実行

```
$ make jgm-pandoc-checkout PANDOC=バージョン番号
jgm/pandocを特定バージョンでチェックアウトし、独自のヘッダを付与する

$ make ja-update-src
アップデート作業をまとめてする
(pandoc -> intl-update -> tx-push-pot)
要環境変数

$ make ja-build
Transifex: 翻訳ファイル(po)をpullし、そのままビルドする
要環境変数

$ make ja-build-local
ローカル環境のみ：アップデート・ビルド作業をまとめてする
(ja-pandoc -> intl-update -> ja-html)
```

### ターゲット：Pandocバージョン関連

```
$ make jgm-pandoc-version
元リポジトリPandocバージョンを表示する (pandoc/pandoc.cabalのversionを参照)

$ make ja-pandoc-version
翻訳対象Pandocバージョンを表示する (./ja-pandoc-version-lock ファイルを参照)

$ make ja-pandoc-version-lock
翻訳対象Pandocバージョンをjgm/pandocのものに固定する (ファイルに書き出すだけ)
```

### ターゲット：リポジトリ・原文アップデート系

(jgm/pandoc: MANUAL.txt のアップデートと翻訳ファイルの更新)

```
$ make ja-init
git submodule を初期化する

$ make users-guide-rst
Pandoc: jgm/pandocの MANUAL.txt (Markdown) をrstに変換する
```

### ターゲット：Sphinx系（単品）

```
$ make intl-update
users-guide.rst (原文) を更新するときに、翻訳ファイル (pot/po) を更新する

$ make ja-html
Sphinx: htmlをビルドする
```

### ターゲット：Transifex系

```
# make tx-push-pot
Transifex: 【翻訳前pot】手元の更新後ソースファイル(pot)をpushする
要環境変数

# make tx-pull
Transifex: 【翻訳後po】Transifexから最新の翻訳ファイル(po)をpullする
要環境変数

# make tx-push-local-po
Transifex: 【翻訳後po】手元の翻訳ファイル(po)をpushする
```

## 典型的なワークフロー

下記の実行のために、あらかじめコンテナのBashにログインしておきます（環境変数も読み込ませる）。

```
docker run -v $(pwd):/docs --env-file .env -it pandocjp/pandoc-doc-ja bash
```

### Pandoc翻訳対象バージョンのアップグレード

例: Pandoc 2.9.2.1 にバージョンアップ

```
make jgm-pandoc-checkout PANDOC_VER=2.9.2.1
make ja-update-src
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

- リリース時は `git tag` でタグ付けする。（Read the Docs側でタグが反映される）
- 同じバージョンを更新する際は `_revN` のプレフィックスを付ける
    - 例: `v2.9.2.1_rev2`

```
git add *
git commit -m '[update] 現時点での翻訳を取り込んでビルド'
git tag -a v2.9.2.1 -m 'Pandoc 2.9.2.1 準拠'
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

## 原文について

- [Pandoc](https://pandoc.org/index.html)
- [GitHub - jgm/pandoc: Universal markup converter](https://github.com/jgm/pandoc)

### ライセンス

© 2006-2022 John MacFarlane (jgm@berkeley.edu). Released under the GPL, version 2 or greater. This software carries no warranty of any kind. (See COPYRIGHT for full copyright and warranty notices.)