#!/bin/bash

CONVERT_OPTIONS="-type Grayscale -background white +matte -depth 32"

LANG="${1}"
shift

while (($#)); do 
  image="$1"
  echo "Processing: ${image}"
  if [ "${image##*.}" != ".png" ]; then
    convert "${image}" $CONVERT_OPTIONS "${image%.*}.png"
    rm "${image}"
  fi
  ~/local/bin/tesseract -l "$LANG" "${image%.*}.png" "${image%.*}" hocr
  rm "${image%.*}.png"
  shift
done
