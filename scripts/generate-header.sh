#!/bin/bash

# カレントディレクトリをプロジェクトルートに変更
SCRIPT_DIR=$(dirname $0)
cd "${SCRIPT_DIR}"/.. || exit 1

if [ $# -ne 2 ]; then
  echo "usage: $0 doc_basename pandoc_ver_lock_file" 1>&2
  exit 1
fi

# 翻訳対象のbasename (hoge.rst の hogeの部分)
users_guide_basename=$1

# ヘッダ
header_users_guide=${users_guide_basename}-header       # basename: hoge
header_users_guide_output=${header_users_guide}.rst     # header reST: hoge.rst
header_users_guide_template=${header_users_guide}.txt   # Pandoc template: hoge.txt

# 本文 (reST、翻訳済)
body_users_guide=${users_guide_basename}.rst

# Pandocバージョン
pandoc_ver_lock_file=$(cat $2)

# 日付
thedate=$(date "+%Y/%m/%d")

# 出力（入力は標準入力）
echo "" | \
    pandoc -f markdown -t rst \
    --template="${header_users_guide_template}" \
    -V trans-pandoc-version="${pandoc_ver_lock_file}" \
    -V date="${thedate}"
