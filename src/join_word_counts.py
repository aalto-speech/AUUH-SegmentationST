#!/usr/bin/env python3

import argparse
import collections
import logging

import tqdm


logger = logging.getLogger(__name__)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Extract word counts from raw text')
    parser.add_argument('--verbose', '-v', action='store_true', help='increase verbosity')
    parser.add_argument('--max-length', '-l', type=int, help='max word length to include')
    parser.add_argument('--min-count', '-c', type=int, default=1, help='min word count to include')
    parser.add_argument('--lowercase', action='store_true', help='lowercase input words')
    parser.add_argument('infiles', type=argparse.FileType('r'), nargs='+', help='input files')
    parser.add_argument('outfile', type=argparse.FileType('w'), default='-', help='output file')
    args = parser.parse_args()
    logging.basicConfig(level=logging.DEBUG if args.verbose else logging.INFO)

    counter = collections.Counter()
    for countfile in args.infiles:
        for line in tqdm.tqdm(countfile):
            count, word = line.split()
            if args.lowercase:
                word = word.lower()
            counter[word] += int(count)

    for word, count in sorted(counter.items()):
        if args.max_length and len(word) > args.max_length:
            continue
        if count < args.min_count:
            continue
        args.outfile.write(f"{count} {word}\n")
