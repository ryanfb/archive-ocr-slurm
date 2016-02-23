#!/bin/bash
#SBATCH -n 1
#SBATCH -N 1
#SBATCH --time=200
#SBATCH --mem-per-cpu=2048

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CHUNK_SIZE=50
SBATCH_OPTIONS="-J ${1} -n 1 -N 1 --time=$((CHUNK_SIZE * 4)) --mem-per-cpu=2048"
CONVERT_OPTIONS="-type Grayscale -background white +matte -depth 32"
declare -a extensions=("_jp2.zip" "_tif.zip" "_raw_jp2.zip" ".pdf" "_bw.pdf")

LANG="${1}"
shift

while (($#)); do
  for extension in "${extensions[@]}"; do
    url="https://archive.org/download/${1}/${1}${extension}"
    curl_output=$(curl --fail -L -I "${url}" 2>&1)
    if [ $? -eq 0 ]; then
      mkdir -pv "${1}"
      cd "${1}"
      filename="${1}${extension}"
      if [ ! -f "$filename" ]; then
        echo "Downloading $filename from $url"
        curl -s -L ${url} -o "${filename}"
        case "${filename##*.}" in
          zip)
            echo "Unzipping..."
            unzip -ojq "${filename}" && rm "${filename}" && touch "${filename}"
            ;;
          pdf)
            echo "Converting..."
            convert -density 300 "${filename}" $CONVERT_OPTIONS "${1}_%05d.png" && rm "${filename}" && touch "${filename}"
            ;;
          *)
            echo "Unknown extension"
            ;;
        esac
      fi
      wget "https://github.com/latin-ocr/${1}/archive/master.zip"
      if [ $? -eq 0 ]; then
        unzip -j -o master.zip
        rm *.hocr master.zip
      fi
      find . \( -name '*.jp2' -o -name '*.tif' -o -name '*.png' \) -print0 | xargs -0 -r -n $CHUNK_SIZE sbatch $SBATCH_OPTIONS $DIR/archive-ocr-slurm-runocr.sh "${LANG}"
      break
    fi
  done
  shift
done

echo "Done."
