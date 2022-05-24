#!/usr/bin/env python3
from char_detokenize import run_on_line

def run_detokenization(inputfile, outputfile):
    with open(inputfile) as fin, \
         open(outputfile, "w") as fout:
        for i, line in enumerate(fin):
            detok = run_on_line(line)            
            print(detok, file=fout)


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser("Detokenizer for character tokenized test data with Sigmorphon 22 data and Marian")
    parser.add_argument("translation", help="Path to translation output file (e.g. fra.word.dev.decoded)")
    parser.add_argument("outputfile", help="Path to file with output")
    args = parser.parse_args()
    run_detokenization(args.translation, args.outputfile)

