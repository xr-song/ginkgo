export PATH=/staging/leuven/stg_00064/Xinran/sw/miniconda3/envs/myenv/bin:$PATH

scripts_dir=/staging/leuven/stg_00064/Xinran/sw/ginkgo/scripts

blacklist_bed="/staging/leuven/stg_00064/Xinran/db/T2T-CHM13v2.0/blacklist/T2T.blacklist.for_CNA.bed"

output_dir="."

cd $output_dir

for input in variable_*_150_bismark; do
	sh ${scripts_dir}/generate_badbins.sh $input $blacklist_bed $scripts_dir
done
