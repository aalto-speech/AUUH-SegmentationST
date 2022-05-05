#!/usr/bin/env python3
# Character segmentation on the type of input that Sigmorphon data has
# NOTE: Currently ignores the possible third column (word class)
import pathlib
import warnings

MORPH_SEP = "@@"
TMP_SEP = "⌨"  # Use cool computer keyboard sign as temporary separator
SPACE_TOKEN = "<w>"
MARIAN_TOKENS = ["</s>", "<unk>"]

def tokenize(raw):
    separated = raw.replace(" "+MORPH_SEP, TMP_SEP)
    outputs = []
    for char in separated:
        if char == " ":
            outputs.append(SPACE_TOKEN)
        elif char == TMP_SEP:
            outputs.append(MORPH_SEP)
        else:
            outputs.append(char)
    return outputs


def process_line(line):
    line = line.strip()
    if line.count("\t") == 2:
        with_classes = True
    elif line.count("\t") == 1:
        with_classes = False
    else:
        without_tabs = line.replace('\t','TAB')
        raise ValueError(f"Don't know how to process line: {without_tabs}")
    if with_classes:
        source, target, word_class = line.split("\t")
    else:
        source, target = line.split("\t")
    return tokenize(source), tokenize(target)

def run_on_file(inputfile, out_prefix):
    src_vocab = set()
    tgt_vocab = set()
    outpath = pathlib.Path(out_prefix)
    outpath.parent.mkdir(parents=True,exist_ok=True)
    with open(inputfile) as fin, \
         open(out_prefix+".src.txt", "w") as fo_srctxt, \
         open(out_prefix+".tgt.txt", "w") as fo_tgttxt: 
        for i, line in enumerate(fin):
            try:
                src, tgt = process_line(line)
            except ValueError:
                warnings.warn(f"Malformed line {i}:\n{line}")
            src_vocab |= set(src)
            tgt_vocab |= set(tgt)
            print(" ".join(src), file=fo_srctxt)
            print(" ".join(tgt), file=fo_tgttxt)
    with open(out_prefix+".src.vocab", "w") as fout:
        for token in MARIAN_TOKENS + sorted(src_vocab):
            print(token, file=fout)
    with open(out_prefix+".tgt.vocab", "w") as fout:
        for token in MARIAN_TOKENS + sorted(tgt_vocab):
            print(token, file=fout)


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser("Character tokenizer for Sigmorphon 22 data and Marian")
    parser.add_argument("input", help="Path to input file (e.g. ../data/fra.word.train.tsv )")
    parser.add_argument("output_prefix", 
            help="Output prefix, will output files: "
            "prefix.src.txt, prefix.tgt.txt, prefix.src.vocab, prefix.tgt.vocab")
    args = parser.parse_args()
    run_on_file(args.input, args.output_prefix)

