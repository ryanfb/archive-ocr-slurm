#!/bin/bash

cd "$1"

if [ ! -d .git ]; then
  git init .
fi

git add '*.hocr' '*.txt'
git commit -m "$(date '+%Y-%m-%d') OCR update"

git ls-remote --exit-code -h "git@github.com:latin-ocr/$(basename ${1}).git" &> /dev/null
if [ $? -ne 0 ]; then
  hub create -h "https://archive.org/details/$(basename ${1})" "latin-ocr/${1}" && sleep 5
fi

git push origin master
