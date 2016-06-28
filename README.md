This repository contains some simple control scripts for running Tesseract OCR against digitized Internet Archive books on a [SLURM](https://en.wikipedia.org/wiki/Slurm_Workload_Manager) cluster.

It assumes you've installed Tesseract (and the corresponding language training files) in `~/local` following [these instructions](https://github.com/tesseract-ocr/tesseract/wiki/Compiling#install-elsewhere--without-root).

Usage
=====

    ./archive-ocr-slurm.sh [Tesseract language code(s)] [Internet Archive volume identifier(s)]

Example:

    ./archive-ocr-slurm.sh lat+grc ananatomicaldis00morggoog
