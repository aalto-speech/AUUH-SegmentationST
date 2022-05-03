#!/usr/bin/env python3
import pathlib

conversions = {"@@": " @@",
               "<w>": " "}

def run_on_line(line):
    tokens = line.strip().split()
    tokens = [conversions[token] if token in conversions else token
              for token in tokens]
    output = "".join(tokens)
    return output

def run_on_file(inputfile):
    with open(inputfile) as fin, \
         open(inputfile+".detok", "w") as fout:
        for line in fin:
            output = run_on_line(line)
            print(output, file=fout)

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser("Detokenizer for character tokenized data with Sigmorphon 22 data and Marian")
    parser.add_argument("input", help="Path to input file (e.g. fra.word.dev.decoded), "
    "will output to input.detok")
    args = parser.parse_args()
    run_on_file(args.input)

