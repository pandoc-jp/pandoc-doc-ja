# ----------------------------------------------------------------
# Rules for pandoc-doc-ja (pandoc and sphinx-intl)
# ----------------------------------------------------------------

################################################
# 引数
################################################

## jgm/pandocのbranch or tag（チェックアウトしたいバージョン番号を指定する）
PANDOC := ""
PANDOC_VER_LOCK_FILE := ./ja-pandoc-version-lock

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
pandoc: users-guide.rst
users-guide.rst: ./pandoc/MANUAL.txt
	pandoc -f markdown -t rst --reference-links $< -o $@.tmp
	cat users-guide-header.txt $@.tmp > $@
	rm $@.tmp

# make intl-update
# users-guide.rst (原文) を更新するときに、翻訳ファイル (pot/po) を更新する
.PHONY: intl-update
intl-update: users-guide.rst
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

## ビルド

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
