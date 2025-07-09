scripts_dir=$(realpath "$(pwd)/..")
output_dir='/staging/leuven/stg_00064/Xinran/db/T2T-CHM13v2.0/ginkgo_BS_reference'
cd $output_dir

genome_name=T2T
script="${scripts_dir}/binning.sh" # "${scripts_dir}/buildGenome.mapBISMARK_bin.sh" #${scripts_dir}/buildGenome.mapBISMARK.sh
nohup sh $script $genome_name $scripts_dir 2>&1 &
