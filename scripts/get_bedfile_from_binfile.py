import argparse

parser = argparse.ArgumentParser(description="Process input and output file paths.")
parser.add_argument('-i', '--input_file', required=True, help="Input file path")
parser.add_argument('-o', '--output_file', required=True, help="Output file path")
args = parser.parse_args()
input_file = args.input_file
output_file = args.output_file

with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
    next(infile)
    previous_chromosome = None
    previous_end = None
    for line in infile:
        line = line.strip()
        if not line:
            continue
        fields = line.split()
        chromosome = fields[0]
        start_position = int(fields[1])
        if previous_chromosome is None or chromosome != previous_chromosome:
            outfile.write(f"{chromosome}\t0\t{start_position}\n")
            previous_end = None
        if previous_end is not None and chromosome == previous_chromosome:
            outfile.write(f"{previous_chromosome}\t{previous_end}\t{start_position}\n")
        previous_chromosome = chromosome
        previous_end = start_position
