#!/bin/bash

# カレントディレクトリをプロジェクトルートに変更
SCRIPT_DIR=$(dirname $0)
cd "${SCRIPT_DIR}"/.. || exit 1

if [ $# -ne 1 ]; then
  echo "usage: $0 [jgm/pandoc's path]" 1>&2
  exit 1
fi

# jgm/pandoc のリポジトリパスに移動
cd $1

if [ -f pandoc.cabal ]; then
    grep '^version:' pandoc.cabal | awk '{print $2}'
else
    exit 1
fi

