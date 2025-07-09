#!/usr/bin/env python3
import argparse
import os

def split_fasta(input_fa, n_seq, output_dir):
    base_name = os.path.splitext(os.path.basename(input_fa))[0]
    chrom = base_name.split('_')[0]
    suffix = base_name.replace(chrom, '')

    file_count=1
    seq_count=0
    output_file=None

    with open(input_fa, 'r') as f:
        for line in f:
            if line.startswith('>'):
                if seq_count % n_seq == 0:
                    if output_file:
                        output_file.close()
                    out_path = os.path.join(output_dir, f"{chrom}_split_{file_count}{suffix}")
                    print(f"Generating {out_path}")
                    output_file = open(out_path, 'w')
                    file_count += 1
                seq_count += 1
            output_file.write(line)

    if output_file:
        output_file.close()

def main():
    parser = argparse.ArgumentParser(description="Split a fasta file into chunks of n sequences.")
    parser.add_argument('--input_fa', required=True)
    parser.add_argument('--n_seq', type=int, required=True)
    parser.add_argument('--output_dir', required=True)

    args = parser.parse_args()
    os.makedirs(args.output_dir, exist_ok=True)
    split_fasta(args.input_fa, args.n_seq, args.output_dir)

if __name__ == '__main__':
    main()

