#!/bin/bash
#SBATCH -n 1
#SBATCH -N 1
#SBATCH --time=10
#SBATCH --mem-per-cpu=2048

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CHUNK_SIZE=50
SBATCH_OPTIONS="-n 1 -N 1 --time=$((CHUNK_SIZE * 3)) --mem-per-cpu=1024"
declare -a extensions=("_jp2.zip" "_tif.zip" "_raw_jp2.zip" ".pdf" "_bw.pdf")

for extension in "${extensions[@]}"; do
  url="https://archive.org/download/${1}/${1}${extension}"
  curl_output=$(curl --fail -L -I "${url}" 2>&1)
  if [ $? -eq 0 ]; then
    mkdir -v "${1}"
    cd "${1}"
    filename="${1}${extension}"
    if [ ! -f "$filename" ]; then
      echo "Downloading $filename from $url"
      curl -s -L ${url} -o "${filename}"
      case "${filename##*.}" in
        zip)
          echo "Unzipping..."
          unzip -jq "${filename}"
          ;;
        *)
          echo "Skipping unzip"
      esac
    fi
    echo "Converting..."
    case $extension in
      _jp2.zip|_raw_jp2.zip|_tif.zip)
        find . -name '*.jp2' -o -name '*.tif' | xargs -n $CHUNK_SIZE sbatch $SBATCH_OPTIONS $DIR/archive-ocr-slurm-runocr.sh "$(pwd)" "${2}"
        ;;
      .pdf|_bw.pdf)
        convert -density 300 "${filename}" $CONVERT_OPTIONS "${1}_%05d.png"
        rm "${filename}"
        find . -name '*.png' | xargs -n $CHUNK_SIZE sbatch $SBATCH_OPTIONS $DIR/archive-ocr-slurm-runocr.sh "$(pwd)" "${2}"
        ;;
      *)
        echo "Unknown extension"
    esac
    break
  fi
done
