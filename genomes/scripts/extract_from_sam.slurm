#!/usr/bin/bash
#SBATCH -t 04:00:00
#SBATCH --mem=30G
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --cluster wice
#SBATCH -A lp_big_wice_cpu
#SBATCH --partition dedicated_big_bigmem
#SBATCH -o %j.o
#SBATCH -e %j.e

# extract mapping info for SAM files of all the chromosomes, and all the splits
export PATH=/staging/leuven/stg_00064/Xinran/sw/SAMTOOLS/bin:$PATH
cd /staging/leuven/stg_00064/Xinran/db/hg38/ginkgo_BS_reference

mapq_cutoff=30
LENGTH=150

for f in *_split*_${LENGTH}_frags_bismark_bt2.sam; do
  [[ -e "$f" ]] || continue  # skip if no matching files

  # extract chromosome and split number
  base=$(basename "$f")
  chr=$(echo "$base" | cut -d'_' -f1)
  split=$(echo "$base" | sed -E 's/.*_split([0-9]+)_.*/\1/')
  echo "Processing $chr split $split"

  samtools view -h "$f" | \
    awk -v chr="$chr" -v mapq_cutoff="$mapq_cutoff" 'BEGIN {OFS="\t"} !/^@/ && $3 == chr && $5 >= mapq_cutoff {print $3, $4}' | \
    sort -k2,2g > "${chr}_split${split}_${LENGTH}_bismark_done" &
done
wait
