#!/bin/bash

# Computes Fixed and Variable length bins for Ginkgo
####################################################

# List of read lengths to consider
#READLEN=(48 76 101 150)
READLEN=(150)

# List of bin sizes (uniquely mappable bases) to consider
BINSIZE=(100000 500000 1000000 2500000 5000000 10000000)

if [ $# != 2 ]
then
  echo "buildGenome input params incorrect!"
  exit
fi

ASSEMBLY=$1

# Path to rest of scripts
SCRIPTS=$2


if [ ! -f bismark_done ]
then
  ## Create a file of binsizes to compute
  rm -f binsizes
  for l in ${BINSIZE[*]}; do
    echo $l >> binsizes
  done

  echo -e "\n Step (7/8): Mapping Simulated Reads To Reference and Bin"
  while read line; do
    for len in ${READLEN[*]}; do
	sbatch --export=ASSEMBLY=$ASSEMBLY,IN=$line,LENGTH=$len --job-name=mapBISMARK.$line -o %j.mapBISMARK.o -e %j.mapBISMARK.e --mem=60G -c 2 -t 10:00:00 --wrap="$SCRIPTS/mapBISMARK" --cluster wice -A lp_big_wice_cpu --partition dedicated_big_bigmem
    done
  done < list_chr_splits

  echo -e "\nFinished Launching Jobs"
fi

