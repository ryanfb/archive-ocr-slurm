#!/bin/bash

SRUN_CONVERT_OPTIONS="--mem-per-cpu=768 --time=10 -n 1 -N 1"
SRUN_TESSERACT_OPTIONS="--mem-per-cpu=256 --time=10 -n 1 -N 1"
CONVERT_OPTIONS="-type Grayscale -background white +matte -depth 32"

LANG="${1}"
shift

while (($#)); do 
  image="$1"
  if [ "${image##*.}" != ".png" ]; then
    convert "${image}" $CONVERT_OPTIONS "${image%.*}.png"
    rm "${image}"
  fi
  ~/local/bin/tesseract -l "$LANG" "${image%.*}.png" "${image%.*}" hocr
  rm "${image%.*}.png"
  shift
done
