#!/bin/bash

input_dir="."

while getopts "i:" opt; do
    case $opt in
        i)
            input_dir="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

mkdir -p temp_processed_files

specific_files=("CHR.cnv" "START.cnv" "END.cnv")

for specific_file in "${specific_files[@]}"; do
    if [[ -f "$input_dir/$specific_file" ]]; then
        echo "$specific_file" > "temp_processed_files/${specific_file}_processed"
        cut -f 2 -d, "$input_dir/$specific_file" >> "temp_processed_files/${specific_file}_processed"
    else
        echo "File $specific_file not found in directory $input_dir."
    fi
done

for file in "$input_dir"/*.cnv; do
    filename=$(basename "$file")
    if [[ ! " ${specific_files[*]} " =~ " $filename " ]]; then
        echo "$filename" > "temp_processed_files/${filename}_processed"
        cut -f 2 -d, "$file" >> "temp_processed_files/${filename}_processed"
    fi
done

paste temp_processed_files/CHR.cnv_processed temp_processed_files/START.cnv_processed temp_processed_files/END.cnv_processed $(ls temp_processed_files/*.cnv_processed | grep -vE 'CHR.cnv_processed|START.cnv_processed|END.cnv_processed') > $input_dir/cnv_mtx.tsv

echo "Combined CN matrix was written to cnv_mtx.tsv"

rm -rf temp_processed_files
