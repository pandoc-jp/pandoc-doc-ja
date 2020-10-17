# ----------------------------------------------------------------
# Rules for pandoc-doc-ja (pandoc and sphinx-intl)
# ----------------------------------------------------------------

SHELL := /bin/bash

################################################
# 変数
################################################

# jgm/pandocのbranch or tag（チェックアウトしたいバージョン番号を指定する）
# 環境変数として与えること (Dockerfileで定義、またはコマンドで直接与える)
PANDOC_VER := ""

# jgm/pandoc のローカルGitリポジトリ（submoduleで管理）
PANDOC_DIR := ./jgm/pandoc

# Pandocバージョンを格納するファイル
PANDOC_VER_LOCK_FILE := ./jgm/ja-pandoc-version-lock

# ターゲットの原文 (.txt/Pandoc's Markdown)
SRC_MD_DIR := src-md
SRC_MD := $(PANDOC_DIR)/MANUAL.txt                # ユーザーズガイド原文 (jgm/pandocのMANUAL.txt)
SRC_MD += $(PANDOC_DIR)/doc/epub.md               # EPUB
SRC_MD += $(PANDOC_DIR)/doc/filters.md            # JSONフィルタの解説
SRC_MD += $(PANDOC_DIR)/doc/getting-started.md    # 初心者向けチュートリアル
SRC_MD += $(PANDOC_DIR)/doc/lua-filters.md        # Luaフィルタの解説
SRC_MD += $(PANDOC_DIR)/doc/using-the-pandoc-api.md  # Pandoc API (Haskell)

# ターゲットの原文：ワイルドカード版（MANUAL.txt -> users-guide.md の変換が終わった前提）
SRC_MD_ALL := src-md/*.md

################################################
# 変数：Docker実行
################################################

# Dockerに与えるオプション
# 1. カレントディレクトリを /docs にマウント
# 2. .env ファイルから環境変数(TX_TOKEN)を読み込む
DOCKER_OPTIONS=-v $(shell pwd):/docs --env-file .env

# 1回のみ実行：docker run
DOCKER_RUN=docker run $(DOCKER_OPTIONS) pandocjp/pandoc-doc-ja

# ログインシェル実行：docker run -it
DOCKER_IT=docker run -it $(DOCKER_OPTIONS) pandocjp/pandoc-doc-ja

################################################
# ターゲット：まとめて実行
################################################

# make ja-update-src
# アップデート作業をまとめてする
# (pandoc -> intl-update -> tx-push-pot)
# 要環境変数
.PHONY: ja-update-src
ja-update-src: users-guide-rst intl-update tx-push-pot

# make ja-build
# Transifex: 翻訳ファイル(po)をpullし、そのままビルドする
# 要環境変数
.PHONY: ja-build
ja-build: tx-pull ja-html

# make ja-build-local
# ローカル環境のみ：アップデート・ビルド作業をまとめてする
# (pandoc -> intl-update -> ja-html)
.PHONY: ja-build-local
ja-build-local: users-guide-rst intl-update ja-html

################################################
# ターゲット：Pandocバージョン関連
################################################

# make jgm-pandoc-version
# 元リポジトリPandocバージョンを表示する (pandoc/pandoc.cabalのversionを参照)
.PHONY: jgm-pandoc-version
jgm-pandoc-version:
	bash ./scripts/pandoc-version.sh

# make ja-pandoc-version
# 翻訳対象Pandocバージョンを表示する (./ja-pandoc-version-lock ファイルを参照)
.PHONY: ja-pandoc-version
ja-pandoc-version:
	cat $(PANDOC_VER_LOCK_FILE)

# make ja-pandoc-version-lock
# 翻訳対象Pandocバージョンをjgm/pandocのものに固定する (ファイルに書き出すだけ)
.PHONY: ja-pandoc-version-lock
ja-pandoc-version-lock:
	bash ./scripts/pandoc-version.sh $(PANDOC_DIR) > $(PANDOC_VER_LOCK_FILE)

################################################
# ターゲット：リポジトリ・原文アップデート系
# (jgm/pandoc: MANUAL.txt のアップデートと翻訳ファイルの更新)
################################################

# make ja-init
# git submodule を初期化する
.PHONY: ja-init
ja-init:
	git submodule update -i

# make jgm-pandoc-checkout PANDOC_VER=バージョン番号
# jgm/pandocを特定バージョンでチェックアウト
.PHONY: jgm-pandoc-checkout
jgm-pandoc-checkout:
	if [ -z $(PANDOC_VER) ]; then \
	  echo "[ERROR] specify version: make pandoc-checkout PANDOC_VER=<VERSION>" && exit 1; \
	fi
	cd $(PANDOC_DIR) && git checkout $(PANDOC_VER)
	make ja-pandoc-version-lock
	make jgm-copy-src-md

# make jgm-copy-src-md
# jgm/pandocの MANUAL.txt および doc/ の特定ドキュメント(md) をコピーする（翻訳対象のみ）
# 注意: MANUAL.txt のみ users-guide.md にリネーム（既にこの名前で公開済のため）
.PHONY: jgm-copy-src-md
jgm-copy-src-md:
	rm -rf $(SRC_MD_DIR)
	mkdir -p $(SRC_MD_DIR)
	cp -f $(SRC_MD) $(SRC_MD_DIR)
	cd $(SRC_MD_DIR) && mv MANUAL.txt users-guide.md

# make users-guide-rst
# Pandoc: src-md のMarkdownファイルをすべて、ヘッダ付きでrstに変換する
.PHONY: users-guide-rst
users-guide-rst:
	ls $(SRC_MD_ALL) | xargs -I {} bash ./scripts/generate-rst.sh {}

################################################
# ターゲット：Sphinx系（単品）
################################################

# make intl-update
# users-guide.rst (原文) を更新するときに、翻訳ファイル (pot/po) を更新する
.PHONY: intl-update
intl-update:
	$(DOCKER_RUN) make gettext
	$(DOCKER_RUN) sphinx-intl update -p _build/gettext -l ja

# make ja-html
# Sphinx: htmlをビルドする
.PHONY: ja-html
ja-html:
	$(DOCKER_RUN) make -e SPHINXOPTS="-D language='ja'" html

################################################
# ターゲット：Transifex系
################################################

# make tx-push-pot
# Transifex: 【翻訳前pot】手元の更新後ソースファイル(pot)をpushする
.PHONY: tx-push-pot
tx-push-pot:
	$(DOCKER_RUN) tx push -s --skip

# make tx-pull
# Transifex: 【翻訳後po】Transifexから最新の翻訳ファイル(po)をpullする
.PHONY: tx-pull
tx-pull: 
	$(DOCKER_RUN) tx pull -l ja

# make tx-push-local-po
# Transifex: 【翻訳後po】手元の翻訳ファイル(po)をpushする
.PHONY: tx-push-local-po
tx-push-local-po:
	$(DOCKER_RUN) tx push -t -l ja

################################################
# ターゲット：ユーティリティ
################################################

# make bash
# Docker内でBashログインする
.PHONY: bash
bash:
	$(DOCKER_IT) /bin/bash

# ----------------------------------------------------------------
# Rules for Sphinx
# ----------------------------------------------------------------

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
SOURCEDIR     = .
BUILDDIR      = _build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
