#!/usr/bin/bash
#SBATCH -t 02:00:00
#SBATCH --mem=4G
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --cluster wice
#SBATCH -A lp_big_wice_cpu
#SBATCH --partition dedicated_big_bigmem
#SBATCH -o %j.o
#SBATCH -e %j.e

cd /staging/leuven/stg_00064/Xinran/db/T2T-CHM13v2.0/ginkgo_BS_reference

chroms=(chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY)

for chr in "${chroms[@]}"; do
    cat ${chr}_split*_150_bismark_done | sort -k2,2n > ${chr}_150_bismark_done &
done
wait
