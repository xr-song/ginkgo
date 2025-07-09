#!/bin/bash

input=$1 # e.g. "variable_2500000_150_bismark"
blacklist_bed=$2 # bed file of blacklisted regions to exclude
scripts_dir=$3 # path to scripts

# Step1: generate bed file from the bin file
input_bed=${input}.bed
python ${scripts_dir}/get_bedfile_from_binfile.py -i $input -o $input_bed

# Step2: generate the bad bin indexes
outputFile=badbins_${input}
rm -f $outputFile
bedtools intersect -a "$input_bed" -b "$blacklist_bed" -wa -wb | cut -f 1-3 | uniq | \
while read -r line; do
  grep -n "$line" "$input_bed" | cut -d: -f1 >> "$outputFile"
done && echo "Indices written to $outputFile"
