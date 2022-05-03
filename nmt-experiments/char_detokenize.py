#!/usr/bin/env python3
import pathlib
import more_itertools

conversions = {"@@": " @@",
               "<w>": " "}

def run_on_line(line):
    tokens = line.strip().split()
    tokens = [conversions[token] if token in conversions else token
              for token in tokens]
    output = "".join(tokens)
    return output

def get_meta_data(line):
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
        word_class = None
    return source, target, word_class

def run_detokenization(translationfile, metadatafile, outputfile):
    with open(translationfile) as translation_fin, \
         open(metadatafile) as metadata_fin, \
         open(outputfile, "w") as fout:
        for translation, metadata in more_itertools.zip_equal(translation_fin, metadata_fin):
            detokenized = run_on_line(translation)
            source, target, word_class = get_meta_data(metadata)
            if word_class is not None:
                print(source, detokenized, word_class, file=fout, sep="\t")
            else:
                print(source, detokenized, file=fout, sep="\t")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser("Detokenizer for character tokenized data with Sigmorphon 22 data and Marian")
    parser.add_argument("translation", help="Path to translation output file (e.g. fra.word.dev.decoded)")
    parser.add_argument("metadata", help="Path to file with metadata")
    parser.add_argument("outputfile", help="Path to file with metadata")
    args = parser.parse_args()
    run_detokenization(args.translation, args.metadata, args.outputfile)
