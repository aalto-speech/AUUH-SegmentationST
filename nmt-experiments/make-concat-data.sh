#!/bin/bash

# Just a basic script to record what I did.

mkdir -p concatenated-data
cd concatenated-data

for lang in eng ces mon; do
  cat \
    <(sed "s/^/⌬/g" ../../data/${lang}.word.train.tsv ) \
    ../../data/${lang}.sentence.train.tsv \
    > ${lang}.concat.train.tsv
  sort --random-sort ${lang}.concat.train.tsv -o ${lang}.concat.train.tsv
  ln -s ${lang}.concat.train.tsv ${lang}.sentence.train.tsv
  ln -s ../../data/${lang}.sentence.dev.tsv .
done

