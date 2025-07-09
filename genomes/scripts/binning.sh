#!/bin/bash

# Computes Fixed and Variable length bins for Ginkgo
####################################################

# List of read lengths to consider
#READLEN=(48 76 101 150)
READLEN=(150)

# List of bin sizes (uniquely mappable bases) to consider
#BINSIZE=(10000 25000 50000 100000 175000 250000 500000 1000000 2500000 5000000 10000000)
#BINSIZE=(100000 500000 1000000 2500000 5000000 10000000)
BINSIZE=(100000)

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

for SIZE in ${BINSIZE[*]}; do
  for LENGTH in ${READLEN[*]}; do
    for TYPE in "bismark"; do
     if [ ! -f GC_variable_${SIZE}_${LENGTH}_${TYPE} ]
      then
        echo -e "\n Step (8/8): Creating variable length ${SIZE} bins with ${LENGTH} bp reads for $TYPE"

        #Concatenate chromsome intervals
#        echo -e "CHR\tEND" > variable_${SIZE}_${LENGTH}_${TYPE}
#        cat `ls | grep results_${SIZE}_${LENGTH}_${TYPE} | sort -V` >> variable_${SIZE}_${LENGTH}_${TYPE}

        #Generate interval boundaries
#        $SCRIPTS/bounds variable_${SIZE}_${LENGTH}_${TYPE} bounds_variable_${SIZE}_${LENGTH}_${TYPE}

        #Calculate GC content in intervals
        $SCRIPTS/GC variable_${SIZE}_${LENGTH}_${TYPE} GC_variable_${SIZE}_${LENGTH}_${TYPE} lengths

#        if [ -f genes ]
#        then
#          #Generate gene files
#          $SCRIPTS/match_genes_to_bins variable_${SIZE}_${LENGTH}_${TYPE} genes genes_variable_${SIZE}_${LENGTH}_${TYPE}
#        fi
      fi
    done
  done
done

echo -e "\nAll done."
