#!/bin/bash

# Organize output files of ginkgo output
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <dir_path>"
    exit 1
fi

RUN=$1

if [ ! -d "$RUN" ]; then
    echo "Dir does not exist: $RUN"
    exit 1
fi

cd $RUN
mkdir -p CN GC SoS counts dist hist lorenz clust cnv bedfile

mv *_CN* CN/ && mv *_GC* GC/ && mv *_SoS* SoS/ && mv *_counts* counts/ && mv *_dist* dist/ && mv *_hist* hist/ && mv *_lorenz* lorenz/ && mv clust*.* clust/ && mv *.cnv cnv/ && mv *.bed* bedfile/ && echo "Organizing complete for directory: $RUN"

echo "Converting CN pdf files to png..."
cd CN

for file in *.pdf; do
	convert -density 150 "$file" -quality 90 "${file%.pdf}.png"
done

mkdir -p ../CN_png && mv *.png ../CN_png && tar -czf ../CN_png.tar.gz -C ../ CN_png && echo "Image conversion finished!"
