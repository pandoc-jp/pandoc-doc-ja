#!/bin/bash

################################################################
# Pandocテンプレートを使って、rst文書にヘッダを付与するスクリプト
# 
# $ generate-header.sh pandoc_template pandoc_ver
# pandoc_template: Pandocのテンプレートのパス（headers参照）
# pandoc_ver: Pandocのバージョン番号（例：2.7.2）
################################################################

# カレントディレクトリをプロジェクトルートに変更
SCRIPT_DIR=$(dirname $0)
cd "${SCRIPT_DIR}"/.. || exit 1

if [ $# -ne 3 ]; then
  echo "usage: $0 pandoc_template doc_md pandoc_ver" 1>&2
  exit 1
fi

# 引数を格納
header_txt=$1         # ヘッダ（Pandocテンプレート形式で書く）
doc_md=$2             # 本文 (Markdown; 拡張子は.mdとする)
pandoc_ver=$3         # Pandocバージョン

# 本文をPandocでrstに変換したもの（ヘッダ付き）
# 注意：パスがディレクトリ付きなので、basenameでディレクトリを外して
# プロジェクトルートに戻す
doc_rst=./$(basename "${2%.md}").rst  


# 日付
thedate=$(date "+%Y/%m/%d")

# 一時ファイル（rst）
tmp_header_rst=$(mktemp)  # ヘッダ
tmp_doc_rst=$(mktemp)       # body

# ヘッダを生成する
# （Pandocテンプレートから生成したいので、入力はダミーの標準入力）
echo "" | pandoc -f markdown -t rst \
  --template="${header_txt}" \
  -V trans-pandoc-version="${pandoc_ver}" \
  -V date="${thedate}" \
  -o "${tmp_header_rst}"

# bodyを変換する
pandoc -f markdown -t rst --reference-links \
  "${doc_md}" -o "${tmp_doc_rst}"

# ヘッダとbodyを結合する
awk 'FNR==1{print ""}{print}' ${tmp_header_rst} ${tmp_doc_rst} > "${doc_rst}"

# 一時ファイルを削除
rm -f "${tmp_doc_rst}"
