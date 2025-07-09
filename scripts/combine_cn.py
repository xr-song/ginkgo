import os
import pandas as pd

def process_cnv_files(input_dir=".", output_file="cnv_mtx.tsv", return_df=False):
    os.makedirs("temp_processed_files", exist_ok=True)
    specific_files = ["CHR.cnv", "START.cnv", "END.cnv"]
    processed_files = {}

    for specific_file in specific_files:
        file_path = os.path.join(input_dir, specific_file)
        if os.path.isfile(file_path):
            df = pd.read_csv(file_path, usecols=[1], header=None)
            processed_files[specific_file] = df
            df.to_csv(f"temp_processed_files/{specific_file}_processed", index=False, header=False)
        else:
            print(f"File {specific_file} not found in directory {input_dir}.")

    for file in os.listdir(input_dir):
        if file.endswith(".cnv") and file not in specific_files:
            file_path = os.path.join(input_dir, file)
            df = pd.read_csv(file_path, usecols=[1], header=None)
            processed_files[file] = df
            df.to_csv(f"temp_processed_files/{file}_processed", index=False, header=False)

    ordered_files = ["CHR.cnv", "START.cnv", "END.cnv"] + [
        f for f in os.listdir("temp_processed_files") 
        if f.endswith("_processed") and f not in {f + "_processed" for f in specific_files}
    ]

    dfs = [pd.read_csv(f"temp_processed_files/{file}", header=None) for file in ordered_files]
    cnv_matrix = pd.concat(dfs, axis=1)
    
    cnv_matrix.to_csv(os.path.join(input_dir, output_file), sep="\t", index=False, header=False)
    print(f"Combined CN matrix was written to {output_file}")

    for file in os.listdir("temp_processed_files"):
        os.remove(os.path.join("temp_processed_files", file))
    os.rmdir("temp_processed_files")

    if return_df:
        return cnv_matrix
    return None

