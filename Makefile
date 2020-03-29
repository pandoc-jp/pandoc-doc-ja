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
HEADER_OUTPUT := users-guide-ja

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
# ビルドのための初期設定をする (pipenv, git submodule: jgm/pandoc)
.PHONY: ja-init
ja-init:
	pipenv install
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

# make pandoc
# Pandoc: jgm/pandocの MANUAL.txt (Markdown) をrstに変換する
.PHONY: pandoc
pandoc: $(USERS_GUIDE_RST)
$(USERS_GUIDE_RST): $(MANUAL_TXT)
	pandoc -f markdown -t rst --reference-links $< -o $@

# make intl-update
# users-guide.rst (原文) を更新するときに、翻訳ファイル (pot/po) を更新する
.PHONY: intl-update
intl-update: $(USERS_GUIDE_RST)
	pipenv run make gettext
	pipenv run sphinx-intl update -p _build/gettext -l ja

# make tx-push-pot
# Transifex: 【翻訳前pot】手元の更新後ソースファイル(pot)をpushする
.PHONY: tx-push-pot
tx-push-pot:
	pipenv run tx push -s

# make ja-update-src
# アップデート作業をまとめてする (pandoc -> intl-update -> tx-push-pot)
.PHONY: ja-update-src
ja-update-src: pandoc intl-update tx-push-pot

## ビルド：ユーザーズガイド用rst

# make ja-users-guide-rst
# ユーザーズガイドのrstをビルド
# (Pandocテンプレートのみを入力としたいため、形式的に入力ファイルを無し(/dev/null)とする)
.PHONY: ja-users-guide-rst
ja-users-guide-rst: $(HEADER_OUTPUT)
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
	pipenv run tx pull -l ja

# make ja-html
# Sphinx: htmlをビルドする
.PHONY: ja-html
ja-html:
	pipenv run make -e SPHINXOPTS="-D language='ja'" html

# make ja-build
# Transifexから翻訳ファイル(po)をpullし、そのままビルドする
.PHONY: ja-build
ja-build: tx-pull ja-html

## その他

# make pipenv-update
# Pipenv: pipenv updateして、requirements.txt に書き出す
.PHONY: pipenv-update
pipenv-update:
	pipenv update
	pipenv lock -r > ./requirements.txt

# make tx-push-local-po
# Transifex: 【翻訳後po】手元の翻訳ファイル(po)をpushする
# 
.PHONY: tx-push-local-po
tx-push-local-po:
	pipenv run tx push -t -l ja

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
