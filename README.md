# A modified version of Ginkgo copy number calling pipeline

The original version can be found [here](https://github.com/robertaboukhalil/ginkgo).

## Prerequisites
- Clone the current repository: `git clone https://github.com/xr-song/ginkgo.git`
- Include Java in your PATH
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
cd /path/to/ginkgo
make
```

- Prepare the genome reference files including variably sized bins and GC content per bin. The authors of Ginkgo do not provide reference for GRCh38 and T2T-CHM13v2.0.
- Prepare the config file. See [examples](config_examples). Major choices include bin size, ploidy, and whether to remove bad bins. Make sure to change `chosen_genome` to the directory containing the reference files.

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

Calling [run_ginkgo.sh](scripts/run_ginkgo.sh) will take you through all the steps of running Ginkgo. It takes ~1 hour with <1G memory for 1k cells.

Check `SegCopy` file in the output directory for the called copy numbers.
