This repository contains some simple control scripts for running Tesseract OCR against digitized Internet Archive books on a [SLURM](https://en.wikipedia.org/wiki/Slurm_Workload_Manager) cluster.

It assumes you've installed Tesseract (and the corresponding language training files) in `~/local` following [these instructions](https://code.google.com/p/tesseract-ocr/wiki/Compiling#Install_elsewhere_/_without_root).

Usage
=====

    ./archive-ocr-slurm.sh [Internet Archive volume identifier] [Tesseract language code(s)]

Example:

    ./archive-ocr-slurm.sh ananatomicaldis00morggoog lat+grc