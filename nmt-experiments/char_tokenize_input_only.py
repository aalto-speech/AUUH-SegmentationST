#!/usr/bin/env python3
# Character segmentation on the type of input that Sigmorphon data has
# NOTE: Currently ignores the possible third column (word class)
from char_tokenize import tokenize

def run_on_file(inputfile, outputfile):
    with open(inputfile) as fin, \
         open(outputfile, "w") as fout:
        for i, line in enumerate(fin):
            inp = line.strip()
            tokenized = tokenize(inp)
            print(" ".join(tokenized), file=fout)

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser("Character tokenizer for Sigmorphon 22 test data and Marian")
    parser.add_argument("input", help="Path to input file (e.g. ../data/fra.word.test.tsv )")
    parser.add_argument("outputfile")
    args = parser.parse_args()
    run_on_file(args.input, args.outputfile)

