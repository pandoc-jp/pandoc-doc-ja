# ----------------------------------------------------------------
# Rules for pandoc-doc-ja (pandoc and sphinx-intl)
# ----------------------------------------------------------------

SHELL := /bin/bash

################################################
# 変数
################################################

# jgm/pandocのbranch or tag（チェックアウトしたいバージョン番号を指定する）
PANDOC := ""

# Pandocバージョンを格納するファイル
PANDOC_VER_LOCK_FILE := ./ja-pandoc-version-lock

# ユーザーズガイドのrstをビルドするためのファイル
## ユーザーズガイドのヘッダ部分 (Pandocテンプレート)
HEADER_TEMPLATE := ./users-guide-header.txt
## ユーザーズガイドのbody部分 (翻訳対象)
HEADER_BODY := users-guide
## Sphinx側のユーザーズガイドrst
HEADER_OUTPUT := users-guide-header.rst

# ユーザーズガイド原文
## jgm/pandocのMANUAL.txt
MANUAL_TXT := ./pandoc/MANUAL.txt
## pandoc -f markdown -t rst したもの
USERS_GUIDE_RST := users-guide.rst

################################################
# ターゲット
################################################

## 初期設定

# make ja-init
# ビルドのための初期設定をする (git submodule: jgm/pandoc)
.PHONY: ja-init
ja-init:
	git submodule update -i

## Pandocバージョン関連

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

## 原文アップデート系
## (jgm/pandoc:MANUAL.txt のアップデートと翻訳ファイルの更新)

# make jgm-pandoc-checkout PANDOC=バージョン番号
# jgm/pandocを特定バージョンでチェックアウト
.PHONY: jgm-pandoc-checkout
jgm-pandoc-checkout:
	[ -z $(PANDOC) ] && (echo "[ERROR] specify pandoc version: make pandoc-checkout PANDOC=<VERSION>"; exit 1)
	cd pandoc && git checkout $(PANDOC)
	git submodule update
	make ja-pandoc-version-lock

# make ja-pandoc
# Pandoc: jgm/pandocの MANUAL.txt (Markdown) をrstに変換する
.PHONY: ja-pandoc
ja-pandoc:
	pandoc -f markdown -t rst --reference-links $(MANUAL_TXT) -o $(USERS_GUIDE_RST).tmp
	make ja-users-guide-rst
	awk 'FNR==1{print ""}{print}' $(HEADER_OUTPUT) $(USERS_GUIDE_RST).tmp > $(USERS_GUIDE_RST)
	rm -f $(USERS_GUIDE_RST).tmp

# make intl-update
# users-guide.rst (原文) を更新するときに、翻訳ファイル (pot/po) を更新する
.PHONY: intl-update
intl-update:
	make gettext
	sphinx-intl update -p _build/gettext -l ja

# make tx-push-pot
# Transifex: 【翻訳前pot】手元の更新後ソースファイル(pot)をpushする
.PHONY: tx-push-pot
tx-push-pot:
	tx push -s

# make ja-update-src
# アップデート作業をまとめてする (pandoc -> intl-update -> tx-push-pot)
.PHONY: ja-update-src
ja-update-src: ja-pandoc intl-update tx-push-pot

## ビルド：ユーザーズガイド用rst

# make ja-users-guide-rst
# ユーザーズガイドのrstをビルド
# (Pandocテンプレートのみを入力としたいため、形式的に入力ファイルを無し(/dev/null)とする)
.PHONY: ja-users-guide-rst
ja-users-guide-rst:
	pandoc /dev/null -f markdown -t rst \
	  --template=$(HEADER_TEMPLATE) \
	  -V trans-pandoc-version="$(shell cat $(PANDOC_VER_LOCK_FILE))" \
	  -V date="$(shell date "+%Y/%m/%d")" \
	  -V users-guide-rst="$(HEADER_BODY)" > $(HEADER_OUTPUT)

## ビルド：全体

# make tx-pull
# Transifex: 【翻訳後po】Transifexから最新の翻訳ファイル(po)をpullする
.PHONY: tx-pull
tx-pull: 
	tx pull -l ja

# make ja-html
# Sphinx: htmlをビルドする
.PHONY: ja-html
ja-html:
	make -e SPHINXOPTS="-D language='ja'" html

# make ja-build
# Transifexから翻訳ファイル(po)をpullし、そのままビルドする
.PHONY: ja-build
ja-build: tx-pull ja-html

# make ja-build-local
# ローカル環境で必要なアップデート・ビルド作業をまとめてする 
.PHONY: ja-build-local
ja-build-local: ja-pandoc intl-update ja-html

## その他

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
