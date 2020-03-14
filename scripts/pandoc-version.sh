#!/bin/bash

SCRIPT_DIR=$(dirname $0)
cd ${SCRIPT_DIR}

cat ../pandoc/pandoc.cabal | grep '^version:' | awk '{print $2}'
