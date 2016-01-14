#!/bin/bash

declare -a extensions=("_jp2.zip" "_tif.zip" "_raw_jp2.zip" ".pdf" "_bw.pdf")

for extension in "${extensions[@]}"; do
  curl_output=$(curl --fail -L -I "https://archive.org/download/${1}/${1}${extension}" 2>&1)
  if [ $? -eq 0 ]; then
    # echo "$curl_output"
    content_length=$(echo "$curl_output" | grep 'Content-Length' | tail -1 | cut -d' ' -f2)
    echo -e "$1\t${extension}\t${content_length}"
    exit
  fi
done

echo -e "$1\tmissing\t0"
