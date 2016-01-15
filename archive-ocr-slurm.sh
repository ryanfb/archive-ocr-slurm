#!/bin/bash

CONVERT_OPTIONS="-type Grayscale -background white +matte -depth 32"
declare -a extensions=("_jp2.zip" "_tif.zip" "_raw_jp2.zip" ".pdf" "_bw.pdf")

for extension in "${extensions[@]}"; do
  url="https://archive.org/download/${1}/${1}${extension}"
  curl_output=$(curl --fail -L -I "${url}" 2>&1)
  if [ $? -eq 0 ]; then
    mkdir -v "${1}"
    cd "${1}"
    filename="${1}${extension}"
    echo "Downloading $filename from $url"
    curl -s -L ${url} -o "${filename}"
    case "${filename##*.}" in
      zip)
        echo "Unzipping..."
        unzip -jq "${filename}"
        rm "${filename}"
        ;;
      *)
        echo "Skipping unzip"
    esac
    echo "Converting..."
    case $extension in
      _jp2.zip|_raw_jp2.zip)
        for jp2 in ${1}*.jp2; do
          srun convert "${jp2}" $CONVERT_OPTIONS "${jp2%.*}.png" &
          # rm "${jp2}"
        done
        ;;
      _tif.zip)
        for tif in ${1}*.tif; do
          srun convert "${tif}" $CONVERT_OPTIONS "${tif%.*}.png" &
          # rm "${tif}"
        done
        ;;
      .pdf|_bw.pdf)
        srun convert -density 300 "${filename}" $CONVERT_OPTIONS "${1}_%05d.png" &
        # rm "${filename}"
        ;;
      *)
        echo "Unknown extension"
    esac
    echo "Waiting for conversion..."
    wait
    # should have everything in Grayscale PNG at this point
    for png in ${1}*.png; do
      srun ~/local/bin/tesseract -l ${2} "${png}" "${png%.*}" hocrpdf &
      # rm "${png}"
    done
    echo "Waiting for OCR..."
    wait
    break
  fi
done
