#!/bin/bash

# set ImageMagick temp directory so it doesn't write (and fill up) default /tmp on login nodes
export MAGICK_TMPDIR="/work/$(whoami)"

CONVERT_OPTIONS="-type Grayscale -background white +matte -depth 32"

LANG="${1}"
shift

while (($#)); do 
  image="$1"
  echo "Processing: ${image}"
  if [ ! -s "${image%.*}.txt" ]; then
    if [ "${image##*.}" != "png" ]; then
      convert "${image}" $CONVERT_OPTIONS "${image%.*}.png"
    fi
    ~/local/bin/tesseract -l "$LANG" "${image%.*}.png" "${image%.*}" hocr
  fi
  rm -fv "${image%.*}.png" "${image}"
  shift
done

echo "Done."
