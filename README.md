# pandoc-doc-ja: Pandocユーザーズガイド日本語版

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
