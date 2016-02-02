#!/bin/bash

SRUN_CONVERT_OPTIONS="--mem-per-cpu=768 --time=10 -n 1 -N 1"
SRUN_TESSERACT_OPTIONS="--mem-per-cpu=256 --time=10 -n 1 -N 1"
CONVERT_OPTIONS="-type Grayscale -background white +matte -depth 32"

cd "${1}"
find . -maxdepth 1 -name '*.png' -o -name '*.tif' -o -name '*.jp2' | while read image; do 
  if [ "${image##*.}" != ".png" ]; then
    convert "${image}" $CONVERT_OPTIONS "${image%.*}.png"
    rm "${image}"
  fi
  ~/local/bin/tesseract -l ${2} "${image%.*}.png" "${image%.*}" hocr
  rm "${image%.*}.png"
done
