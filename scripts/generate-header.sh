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

if [ $# -ne 2 ]; then
  echo "usage: $0 pandoc_template pandoc_ver" 1>&2
  exit 1
fi

# ヘッダ
header_users_guide_template=$1

# Pandocバージョン
pandoc_ver=$2

# 日付
thedate=$(date "+%Y/%m/%d")

# 出力（入力は標準入力）
echo "" | \
    pandoc -f markdown -t rst \
    --template="${header_users_guide_template}" \
    -V trans-pandoc-version="${pandoc_ver}" \
    -V date="${thedate}"
