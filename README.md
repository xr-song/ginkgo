# A modified version of Ginkgo copy number calling pipeline

## Prerequisites
- Clone the current repository: `git clone https://github.com/xr-song/ginkgo.git`
- Have Java in your PATH
- Have R installed in a conda environment
- Make sure you have the following R packages installed: 
```sh
BiocManager::install("ctc")
BiocManager::install("DNAcopy") 
install.packages("inline")
install.packages("gplots")
install.packages("scales")
install.packages("plyr")
install.packages("gridExtra")
```

- Run `make` to compile the .cpp source files:
```bash
cd /path/to/this/repository
make
```

- Prepare the genome reference files including variably sized bins and GC content per bin. See `genome` folder. The authors of Ginkgo do not provide reference for GRCh38 and T2T-CHM13v2.0.
- Prepare the config file. See `config_examples` folder. Major choices include bin size and whether to remove bad bins.

## Usage
Submit a job with the following commands (replace with your actual paths):

```bash
export PATH=/path/to/environment/bin:$PATH # environment with R and required packages installed

wd=$(realpath "$(pwd)/..") # your working directory
BARCODES_LIST=$wd/barcode_lists/barcodes.txt # one barcode per line, (partially) matching the corresponding bed file name
SOURCE_DIR=/path/to/bedfile # source directory of all the bed files to consider
OUTPUT_DIR=$wd/ginkgo_output # output directory
CONFIG=/path/to/config # config file
REPO_DIR=/path/to/ginkgo # path to this repository

sh ${REPO_DIR}/scripts/run_ginkgo.sh $BARCODES_LIST $SOURCE_DIR $OUTPUT_DIR $CONFIG $REPO_DIR
```

This will take you through all the steps of running Ginkgo. It takes ~1 hour with <1G memory for 1k cells.
