#!/bin/bash

# Computes Fixed and Variable length bins for Ginkgo
####################################################

# List of read lengths to consider
#READLEN=(48 76 101 150)
READLEN=(150)

# List of bin sizes (uniquely mappable bases) to consider
#BINSIZE=(10000 25000 50000 100000 175000 250000 500000 1000000 2500000 5000000 10000000)
BINSIZE=(100000 500000 1000000 2500000 5000000 10000000)

# Time out for SGE
export SGE_JSV_TIMEOUT=120

if [ $# != 2 ]
then
  echo "buildGenome input params incorrect!"
  exit
fi

ASSEMBLY=$1

# Path to rest of scripts
SCRIPTS=$2


echo "# Indexing $ASSEMBLY for ${READLEN[*]} bp reads using bins of size ${BINSIZE[*]}"

if [ ! -f list ]
then
  echo " Step (1/8): Building Chrom List"
  ls | grep ^chr | grep ".fa" |  awk -F ".fa" '{print $1}' | sort -V | uniq > list
fi

if [ ! -f ${ASSEMBLY}.fa ]
then
  echo -e "\n Step (2/8): Preparing Genome"
  cat `ls | grep chr | sort -V | tr '\n' ' '` > ${ASSEMBLY}.fa
fi

#if [ ! -f bowtieBUILT ]
#then
#  echo -e "\n Step (3/8): Building Index Files"
#  sbatch --mem=8G --export=ASSEMBLY=$ASSEMBLY --wrap="$SCRIPTS/indexBWA" --job-name=indexBWA -o %j.indexBWA.o -e %j.indexBWA.e --cluster wice -A lp_big_wice_cpu --partition dedicated_big_bigmem
#  sbatch --mem=8G --export=ASSEMBLY=$ASSEMBLY --wrap="$SCRIPTS/indexBOWTIE" --job-name=indexBOWTIE -o %j.indexBOWTIE.o -e %j.indexBOWTIE.e --cluster wice -A lp_big_wice_cpu --partition dedicated_big_bigmem
#fi

for len in ${READLEN[*]}; do
  if [ ! -f frag_${len}_done ]
  then
    echo -e "\n Step (4/8): Simulating $len bp Reads"
    while read line; do
        sbatch --export=IN=$line,LENGTH=$len --mem=3G -t 03:00:00 --job-name=simulating_bp_reads -o %j.simulating_bp_reads.o -e %j.simulating_bp_reads.e --cluster wice -A lp_big_wice_cpu --partition dedicated_big_bigmem --wrap="$SCRIPTS/processGenome"
    done < list
    touch frag_${len}_done
  fi
done

if [ ! -f lengths ]
then
  echo -e "\n Step (5/8): Generating Essential Chromosome Files"
  echo -e "  [Computing chromomsome lengths]"
  while read CHROM
    do echo $CHROM $((`grep -v ">" ${CHROM}.fa | wc -c`-`wc -l < ${CHROM}.fa`+1))
  done < list > lengths
fi

if [ ! -r centromeres ]
then
  echo "  [Computing centromere positions]"
  for i in `cat list`; do 
    $SCRIPTS/findCentromeres ${i}.fa out${i}
    if [ `wc -l < out${i}` -eq 0 ]; then
      echo -e "${i}\t0\t0"
    else
      awk '{print $2-$1"\t"$1"\t"$2}' out${i} | sort -rg | head -1 | awk -v chr=$i '{print chr"\t"$2"\t"$3}'
    fi
  done > centromeres
  rm -f out*
fi

for size in ${BINSIZE[*]}; do 
  if [ ! -f fixed_${size} ]
  then
    echo -e "\nStep (6/8): Generating fixed-length interval files for ${size} bp bins"
    $SCRIPTS/fixed lengths fixed_${size} $size
    $SCRIPTS/bounds fixed_${size} bounds_fixed_${size}
    $SCRIPTS/GC fixed_${size} GC_fixed_${size} lengths

    if [ -f genes ]
    then
      $SCRIPTS/match_genes_to_bins fixed_${size} genes genes_fixed_${size}
    fi
  fi
done

echo -e "\nAll done."
