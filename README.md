# pandoc-doc-ja: Pandocユーザーズガイド日本語版

## 翻訳するバージョン

- Pandoc 2.5
    - それ以降に大きなアップデートがあった場合は、追従もありえる（未定）

## 前提

- 翻訳にはsphinx-intlとTransifexを活用したい
    - sphinx-intlの恩恵を受けるためには、reStructuredTextで書く必要がある
    - したがって、Pandoc's Markdown（とPandoc）は使わない
- intersphinxで、2つのSphinxドキュメントをつなぐ
    - Pandocユーザーズガイド日本語版 (pandoc-doc-ja)
        - Read the Docsにホスティングしたい
        - 旧ユーザーズガイドページ（GitHub Pages）は、Read the Docsに301リダイレクトする
    - 日本Pandocユーザ会 (pandoc-jp)
        - GitHub Pages or Read the Docsにホスティング
        - 旧ユーザ会サイト（GitHub Pages）は、ユーザーズガイド以外を301リダイレクトする
- 翻訳元(jgm/pandoc)のPandocの`MANUAL.txt`は、`git submodule`で取得する

## 準備

TODO: 以下、書きかけです。間違ってるかもしれません。

```
$ cd pandoc-doc-ja
$ . bin/activate                  # Python venv環境に入る
$ pip install -r requiments.txt
$ npm install  # textlintのインストール
$ git submodule update
```

※ 作業終了時は `$ deactivate` で、Python venv環境から抜ける

## ビルド

```
$ make html
```

## Transifexのpoファイルを入れてビルドする

- 事前に、Transifexからpoファイルをダウンロードする（今のところ手動管理）。
    - Transifexでリソース「users-guide.po (Japanese (Japan))」を選択
    - 「利用のためにダウンロード」をクリック
    - `for_use_pandoc-users-guide_users-guidepo_ja_JP.po` がダウンロードされる
    - `for_use_pandoc-users-guide_users-guidepo_ja_JP.po` を `users-guide.po` にリネーム
    - ディレクトリ `source/locale/ja/LC_MESSAGES/` にコピー

```
$ make gettext
$ sphinx-intl update -p build/gettext -l ja
```
