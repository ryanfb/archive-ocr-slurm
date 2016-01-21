#!/bin/bash

SRUN_CONVERT_OPTIONS="--mem-per-cpu=768 --time=10 -n 1 -N 1"
SRUN_TESSERACT_OPTIONS="--mem-per-cpu=256 --time=10 -n 1 -N 1"
CONVERT_OPTIONS="-type Grayscale -background white +matte -depth 32"

if [ "${filename##*.}" != ".png" ]; then
  convert "${1}" $CONVERT_OPTIONS "${1%.*}.png"
  rm "${1}"
fi
~/local/bin/tesseract -l ${2} "${1%.*}.png" "${1%.*}" hocr
rm "${1%.*}.png"
