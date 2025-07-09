#!/usr/bin/env bash

if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <BARCODES_LIST> <BEDFILE_DIR> <OUTPUT_DIR> <CONFIG> <REPO_DIR>"
    exit 1
fi

BARCODES_LIST="$1" # a simple text file with one single-cell barcode per line
BEDFILE_DIR="$2" # directory
OUTPUT_DIR="$3" # directory to write results to
CONFIG="$4" # config file
REPO_DIR="$5" # path to the ginkgo repository

mkdir -p "$OUTPUT_DIR"

while IFS= read -r bc; do
    bc_clean=$(echo "$bc" | tr -d '\r')
    src_file="$BEDFILE_DIR/${bc_clean}.bed.gz"
    dest_link="$OUTPUT_DIR/${bc_clean}.bed.gz"

    if [ -e "$src_file" ]; then
        if [ -e "$dest_link" ]; then
            echo "Warning: link already exists for $bc_clean, skipping"
        else
            ln -s "$(realpath "$src_file")" "$dest_link" && \
            echo "Linked: $bc_clean" || \
            echo "Error: failed to link $bc_clean"
        fi
    else
        echo "Missing: $src_file"
    fi
done < "$BARCODES_LIST"

echo "Start running Ginkgo pipeline for $OUTPUT_DIR"

cp ${CONFIG} ${OUTPUT_DIR}/config &&
ls ${OUTPUT_DIR} | grep .bed.gz > ${OUTPUT_DIR}/list &&

# run CN calling
${REPO_DIR}/scripts/analyze.sh ${OUTPUT_DIR} ${REPO_DIR} &&

# run the organize script
${REPO_DIR}/scripts/organize.sh ${OUTPUT_DIR} &&

echo "All done!"
