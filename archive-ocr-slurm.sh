#!/bin/bash
#SBATCH -n 1
#SBATCH -N 1
#SBATCH --time=10
#SBATCH --mem-per-cpu=2048

SBATCH_OPTIONS="-n 1 -N 1 --time=10 --mem-per-cpu=1024"
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
          sbatch $SBATCH_OPTIONS ~/archive-ocr-slurm-runocr.sh "${jp2}" "${2}"
        done
        ;;
      _tif.zip)
        for tif in ${1}*.tif; do
          sbatch $SBATCH_OPTIONS ~/archive-ocr-slurm-runocr.sh "${tif}" "${2}"
        done
        ;;
      .pdf|_bw.pdf)
        convert -density 300 "${filename}" $CONVERT_OPTIONS "${1}_%05d.png"
        rm "${filename}"
        for png in ${1}*.png; do
          sbatch $SBATCH_OPTIONS ~/archive-ocr-slurm-runocr.sh "${png}" "${2}"
        done
        ;;
      *)
        echo "Unknown extension"
    esac
    break
  fi
done
