#!/usr/bin/env python3

import argparse
import collections
import gzip
import html
import logging
import re
import os

import regex
import tqdm


logger = logging.getLogger(__name__)


def file_open(filename, mode='r', encoding='utf8'):
    """Open file with implicit gzip/bz2 support

    Uses text mode by default regardless of the compression.

    In write mode, creates the output directory if it does not exist.

    """
    if 'w' in mode and not os.path.isdir(os.path.dirname(filename)):
        os.makedirs(os.path.dirname(filename))
    if filename.endswith('.bz2'):
        if mode in {'r', 'w', 'x', 'a'}:
            mode += 't'
        return bz2.open(filename, mode=mode, encoding=encoding)
    if filename.endswith('.xz'):
        if mode in {'r', 'w', 'x', 'a'}:
            mode += 't'
        return lzma.open(filename, mode=mode, encoding=encoding)
    if filename.endswith('.gz'):
        if mode in {'r', 'w', 'x', 'a'}:
            mode += 't'
        return gzip.open(filename, mode=mode, encoding=encoding)
    return open(filename, mode=mode, encoding=encoding)


class WordExtractor:

    def __init__(self, script):
        self.clean_word_re = regex.compile(
            r'(?P<word>\p{' + script + r'}+)$'
            r'|(\p{punct}{,3}(?P<word>\p{' + script + r'}{2,})\p{punct}{,3})$'
        )

    def clean_word(self, block):
        block = html.unescape(block)
        match = self.clean_word_re.match(block)
        if not match:
            return None
        return match.group('word')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Extract word counts from raw text')
    parser.add_argument('--verbose', '-v', action='store_true', help='increase verbosity')
    parser.add_argument('--script', '-s', default='Latin', help='increase verbosity')
    parser.add_argument('corpus', type=file_open, help='raw text file')
    parser.add_argument('counts', type=argparse.FileType('w'), default='-', help='output file')
    args = parser.parse_args()
    logging.basicConfig(level=logging.DEBUG if args.verbose else logging.INFO)

    extractor = WordExtractor(args.script)
    counter = collections.Counter()
    for line in tqdm.tqdm(args.corpus):
        for block in line.split():
            word = extractor.clean_word(block)
            if word:
                counter[word] += 1

    for word, count in sorted(counter.items()):
        args.counts.write(f"{count} {word}\n")
