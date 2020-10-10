# ----------------------------------------------------------------
# Rules for pandoc-doc-ja (pandoc and sphinx-intl)
# ----------------------------------------------------------------

SHELL := /bin/bash

################################################
# 変数
################################################

# jgm/pandocのbranch or tag（チェックアウトしたいバージョン番号を指定する）
# 環境変数として与えること (Dockerfileで定義、またはコマンドで直接与える)
PANDOC := ""

# Pandocバージョンを格納するファイル
PANDOC_VER_LOCK_FILE := ./ja-pandoc-version-lock

# ユーザーズガイド原文
## jgm/pandocのMANUAL.txt
MANUAL_TXT := ./pandoc/MANUAL.txt

# ユーザーズガイドのrstをビルドするためのファイル
## ユーザーズガイドのbody部分 (翻訳対象)
DOC_USERS_GUIDE := users-guide
## Sphinx側のユーザーズガイドrst
USERS_GUIDE_RST := $(DOC_USERS_GUIDE).rst
## ヘッダ
HEADER_USERS_GUIDE := $(DOC_USERS_GUIDE)-header.rst

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
	bash ./scripts/pandoc-version.sh > $(PANDOC_VER_LOCK_FILE)

################################################
# ターゲット：リポジトリ・原文アップデート系
# (jgm/pandoc: MANUAL.txt のアップデートと翻訳ファイルの更新)
################################################

# make ja-init
# git submodule を初期化する
.PHONY: ja-init
ja-init:
	git submodule update -i

# make jgm-pandoc-checkout PANDOC=バージョン番号
# jgm/pandocを特定バージョンでチェックアウト
.PHONY: jgm-pandoc-checkout
jgm-pandoc-checkout:
	[ -z $(PANDOC) ] && (echo "[ERROR] specify pandoc version: make pandoc-checkout PANDOC=<VERSION>"; exit 1)
	cd pandoc && git checkout $(PANDOC)
	git submodule update
	make ja-pandoc-version-lock

# make users-guide-rst
# Pandoc: jgm/pandocの MANUAL.txt (Markdown) をrstに変換する
.PHONY: users-guide-rst
users-guide-rst:
	pandoc -f markdown -t rst --reference-links $(MANUAL_TXT) -o $(USERS_GUIDE_RST).tmp
	bash ./scripts/generate-header.sh $(DOC_USERS_GUIDE) $(PANDOC_VER_LOCK_FILE) > $(HEADER_USERS_GUIDE)
	awk 'FNR==1{print ""}{print}' $(HEADER_USERS_GUIDE) $(USERS_GUIDE_RST).tmp > $(USERS_GUIDE_RST)
	rm -f $(USERS_GUIDE_RST).tmp



################################################
# ターゲット：Sphinx系（単品）
################################################

# make intl-update
# users-guide.rst (原文) を更新するときに、翻訳ファイル (pot/po) を更新する
.PHONY: intl-update
intl-update:
	make gettext
	sphinx-intl update -p _build/gettext -l ja

# make ja-html
# Sphinx: htmlをビルドする
.PHONY: ja-html
ja-html:
	make -e SPHINXOPTS="-D language='ja'" html

################################################
# ターゲット：Transifex系
################################################

# make tx-push-pot
# Transifex: 【翻訳前pot】手元の更新後ソースファイル(pot)をpushする
# 要環境変数
.PHONY: tx-push-pot
tx-push-pot:
	tx push -s

# make tx-pull
# Transifex: 【翻訳後po】Transifexから最新の翻訳ファイル(po)をpullする
# 要環境変数
.PHONY: tx-pull
tx-pull: 
	tx pull -l ja

# make tx-push-local-po
# Transifex: 【翻訳後po】手元の翻訳ファイル(po)をpushする
# 
.PHONY: tx-push-local-po
tx-push-local-po:
	tx push -t -l ja

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
