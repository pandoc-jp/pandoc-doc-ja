#!/bin/bash

################################################################
# Pandocテンプレートを使って、rst文書にヘッダを付与するスクリプト
# 
# $ generate-header.sh doc_md
# doc_md: Markdownファイル
################################################################

# カレントディレクトリをプロジェクトルートに変更
SCRIPT_DIR=$(dirname $0)
cd "${SCRIPT_DIR}"/.. || exit 1

# 引数の数をチェック
if [ $# -ne 1 ]; then
  echo "usage: $0 doc_md" 1>&2
  exit 1
fi

################################################################
# 変数
################################################################

# 引数を格納
doc_md=$1             # 本文 (Markdown; 拡張子は.mdとする)

# ヘッダ（Pandocテンプレート形式で書く）
header_txt=./headers/users-guide-header.txt         

# Pandocバージョン
ver_lock_file=./jgm/ja-pandoc-version-lock
pandoc_ver=$(cat "${ver_lock_file}")

# 本文をPandocでrstに変換したもの（ヘッダ付き）
# 注意：パスがディレクトリ付きなので、basenameでディレクトリを外してプロジェクトルートに戻す
# さらに拡張子を .md -> .rst に変更する
doc_md_base=$(basename $doc_md)
doc_rst=./${doc_md_base%.md}.rst

# 日付
thedate=$(date "+%Y/%m/%d")

# 出力用の一時ファイル（rst）
tmp_header_rst=$(mktemp)             # ヘッダ
tmp_doc_rst=$(mktemp)                # body
tmp_doc_rst_fixed_verbatim=$(mktemp) # fix: Verbatim in reference link in RST by Sphinx

# フィルタ
# fix-header-inconsistency.lua: ヘッダのレベルスキップ（例：2→4）をなくす（例：2→3）
# (Sphinxで CRITICAL: Title level inconsistent エラーをなくすため)
filter_fix_header_inconsistency=./scripts/fix-header-inconsistency.lua

################################################################
# 処理
################################################################

# ヘッダを生成する
# - doc_md からタイトル・原著者名を抽出
# - テンプレート変数として日付とPandocバージョンを指定
# - 以上をPandocテンプレートに流し込む
pandoc "${doc_md}" -s -f markdown -t rst \
  --template="${header_txt}" \
  -V trans-pandoc-version="${pandoc_ver}" \
  -V date="${thedate}" \
  -o "${tmp_header_rst}"

# bodyを変換する
pandoc -f markdown -t rst -L "${filter_fix_header_inconsistency}" --reference-links "${doc_md}" -o "${tmp_doc_rst}"

pandoc -f markdown -t rst --reference-links "${doc_md}" -o "${tmp_doc_rst}"

# ヘッダとbodyを結合する
awk 'FNR==1{print ""}{print}' "${tmp_header_rst}" "${tmp_doc_rst}" > "${doc_rst}"

# 一時ファイルを削除
rm -f "${tmp_doc_rst}"
rm -f "${tmp_header_rst}"
