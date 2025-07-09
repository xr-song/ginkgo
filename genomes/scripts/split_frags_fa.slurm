#!/usr/bin/bash
#SBATCH -t 01:00:00
#SBATCH --mem=4G
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --cluster wice
#SBATCH -A lp_big_wice_cpu
#SBATCH --partition dedicated_big_bigmem
#SBATCH -o %j.o
#SBATCH -e %j.e

export PATH=/staging/leuven/stg_00064/Xinran/sw/miniconda3/envs/myenv/bin:$PATH
ref_dir=/staging/leuven/stg_00064/Xinran/db/T2T-CHM13v2.0/ginkgo_BS_reference

files=('chr1_150_frags' 'chr2_150_frags' 'chr3_150_frags' 'chr4_150_frags' 'chr5_150_frags' 'chr6_150_frags' 'chr7_150_frags' 'chr8_150_frags' 'chr9_150_frags' 'chr10_150_frags' 'chr11_150_frags' 'chr12_150_frags' 'chr13_150_frags' 'chr14_150_frags' 'chr15_150_frags' 'chr16_150_frags' 'chr17_150_frags' 'chr18_150_frags' 'chr19_150_frags' 'chr20_150_frags' 'chr21_150_frags' 'chr22_150_frags' 'chrX_150_frags' 'chrY_150_frags')
for file in "${files[@]}"; do
	python split_frags_fa.py --input_fa $ref_dir/$file --n_seq 20000000 --output_dir $ref_dir &
done

wait

# get a list
ls -1 | grep split | sed -E 's/_150_frags.*//' | grep -v list_chr_splits > list_chr_splits
