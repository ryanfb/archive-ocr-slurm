#!/bin/bash

SRUN_CONVERT_OPTIONS="--mem=768 --time=10"
SRUN_TESSERACT_OPTIONS="--mem=256 --time=10"
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
          srun -J convert_jp2 $SRUN_CONVERT_OPTIONS convert "${jp2}" $CONVERT_OPTIONS "${jp2%.*}.png" &
        done
        wait
        rm ${1}*.jp2
        ;;
      _tif.zip)
        for tif in ${1}*.tif; do
          srun -J convert_tif $SRUN_CONVERT_OPTIONS convert "${tif}" $CONVERT_OPTIONS "${tif%.*}.png" &
        done
        wait
        rm ${1}*.tif
        ;;
      .pdf|_bw.pdf)
        srun -J convert_pdf $SRUN_CONVERT_OPTIONS convert -density 300 "${filename}" $CONVERT_OPTIONS "${1}_%05d.png" &
        wait
        rm ${filename}
        ;;
      *)
        echo "Unknown extension"
    esac
    # should have everything in Grayscale PNG at this point
    for png in ${1}*.png; do
      srun $SRUN_TESSERACT_OPTIONS ~/local/bin/tesseract -l ${2} "${png}" "${png%.*}" hocrpdf &
      # rm "${png}"
    done
    echo "Waiting for OCR..."
    wait
    rm ${1}*.png
    break
  fi
done
