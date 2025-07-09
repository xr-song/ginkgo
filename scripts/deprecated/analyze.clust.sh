#!/bin/bash

# ==============================================================================
# == Launch analysis
# ==============================================================================

# ------------------------------------------------------------------------------
# -- Variables
# ------------------------------------------------------------------------------

home="/staging/leuven/stg_00064/Xinran/sw/ginkgo"
dir=${home}/uploads/${1}
source "${dir}"/config
distMet=$distMeth
touch "$dir"/index.html

inFile=list
statFile=status.xml
genome=${home}/genomes/${chosen_genome}

if [ "$rmpseudoautosomal" == "1" ];
then
  genome=${genome}/pseudoautosomal
else
  genome=${genome}/original
fi

# ------------------------------------------------------------------------------
# -- Error Check and Reformat User Files
# ------------------------------------------------------------------------------

if [ "$f" == "0" ]; then
  touch "${dir}"/ploidyDummy.txt
  facs=ploidyDummy.txt
else 
  # In case upload file with \r instead of \n (Mac, Windows)
  tr '\r' '\n' < "${dir}"/${facs} > "${dir}"/quickTemp
  mv "${dir}"/quickTemp "${dir}"/${facs}
  # 
  sed "s/.bed//g" "${dir}"/${facs} | sort -k1,1 | awk '{print $1"\t"$2}' > "${dir}"/quickTemp 
  mv "${dir}"/quickTemp "${dir}"/${facs}
fi

# ------------------------------------------------------------------------------
# -- Run Mapped Data Through Primary Pipeline
# ------------------------------------------------------------------------------

if [ "$process" == "1" ]; then
  echo "Launching process.R $genome $dir $statFile data $segMeth $binMeth $clustMeth $distMet $color ${ref}_mapped $f $facs $sex $rmbadbins"
  ${home}/scripts/process.R $genome "$dir" $statFile data $segMeth $binMeth $clustMeth $distMet $color ${ref}_mapped $f $facs $sex $rmbadbins
fi
