Ginkgo
=========

#### Ginkgo is a cloud-based single-cell copy-number variation analysis tool.
#### Launch Ginkgo: [qb.cshl.edu/ginkgo](http://qb.cshl.edu/ginkgo)

Usage
=========

* Step 0: Upload .bed files
* Step 1: Choose analysis parameters
* Step 2: Compute Copy Number Profiles, and a Phylogenetic Tree
* Step 3: Analyze Individual Cells


Setup Ginkgo on your own server
=========

**Requirements:**

- PHP >=5.2
- R >= 3.0.0
- R Packages:
	- ctc
	- DNAcopy
	- inline
	- gplots
	- scales
	- plyr
	- ggplot2
	- gridExtra
	- fastcluster
	- heatmap3

**WARNING** Version 3.0.0 (Mar 28, 2016) of gplots introduced a bug in heatmap.2 that makes it calculate dendrograms even when Rowv or Colv is set to FALSE so that Ginkgo will run for a very long time. The solution is to use an older version of gplots or use fixed version from: https://github.com/ChristophH/gplots. This can be installed using the commands below

```
remove.packages('gplots'); 
library('devtools'); 
install_github("ChristophH/gplots")
```

	

**Install Ginkgo:**

Type ```make``` in the ginkgo/ directory

**Server Configuration:**

- /etc/php.ini
	- ```upload_tmp_dir```: make sure this directory has write permission
	- ```upload_max_filesize```: set to >2G since .bam files can be large

- ginkgo/includes/fileupload/server/php/UploadHandler.php
	- In constructor, on line 43 and 44:
		- ```upload_dir = [FULL_PATH_TO_UPLOADS_DIR] . $_SESSION["user_id"] . '/'```
		- ```upload_url = [FULL_URL_TO_UPLOADS_DIR]  . $_SESSION["user_id"] . '/'```

- ginkgo/bootstrap.php
	- Change ```DIR_ROOT```, ```DIR_UPLOADS``` and ```URL_ROOT```

- ginkgo/scripts/analyze.sh
	- Change ```home``` variable to where the ginkgo/ folder is located

- ginkgo/scripts/process.R
	- Change ```main_dir``` variable to the folder where ginkgo/scripts is located

- ginkgo/scripts/reclust.R
	- Change ```main_dir``` variable to the folder where ginkgo/scripts is located

- ginkgo/scripts/analyze-subset.R
	- Set the folder to where ginkgo/scripts is located
	- Set the folder to where ginkgo/genomes is located (warning: test this carefully if your ginkgo/uploads folder is a symlink)

- Make sure the uploads directory has the correct write permissions

**Download data files:**

- Download binning data for hg19 at https://labshare.cshl.edu/shares/schatzlab/www-data/ginkgo/genomes/hg19.tgz
	- untar into ginkgo/genomes/hg19 (which needs to be created)

- Other genomes, including hg18, hg19, mm9, mm10, rheMac7, rheMac8, rn5 and dm3 can be found at http://labshare.cshl.edu/shares/schatzlab/www-data/ginkgo/genomes/
