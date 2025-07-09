#!/usr/bin/bash
#SBATCH -t 00:40:00
#SBATCH --mem=1G
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --cluster wice
#SBATCH -A lp_big_wice_cpu
#SBATCH --partition dedicated_big_bigmem
#SBATCH -o %j.o
#SBATCH -e %j.e

ref_dir=/staging/leuven/stg_00064/Xinran/db/T2T-CHM13v2.0/ginkgo_BS_reference
mkdir -p $ref_dir && cd $ref_dir

ref_fasta=/staging/leuven/stg_00064/Xinran/db/T2T-CHM13v2.0/fasta/UCSC/Bisulfite_Genome/GA_conversion/genome_mfa.GA_conversion.fa

#ln -s $ref_fasta .
mkdir -p chromosomes

# seperate into fa of individual chromosomes
awk '/^>chr[XY]([^0-9]|$)|^>chr[0-9]+([^0-9]|$)/{filename="chromosomes/"substr($1,2)".fa"} {print > filename}' $ref_fasta

# remove redundant chromosomes
#rm chromosomes/*_*.fa

# modify the first line of each .fa file so that it only contains the chromosome name
#for file in chromosomes/*.fa; do
#    sed -i '1s/ .*//' "$file"
#done &&

for file in chromosomes/*.fa; do
    sed -i '1s/\([^_]*\)_.*/\1/' "$file"
done

mv chromosomes/*.fa . && rm -r chromosomes
