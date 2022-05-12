#!/bin/bash

# Just a basic script to record what I did.

mkdir -p concatenated-data-morfessor
cd concatenated-data-morfessor

for lang in eng ces mon; do
  cat \
    <(sed "s/^/⌬/g" ../../morfessor/${lang}_best_baseline.train.tsv ) \
    ../../morfessor/${lang}_best_baseline.sentence.train.tsv \
    > ${lang}.concat.train.tsv
  sort --random-sort ${lang}.concat.train.tsv -o ${lang}.concat.train.tsv
  ln -s ${lang}.concat.train.tsv ${lang}_best_baseline.sentence.train.tsv
  ln -s ../../morfessor/${lang}_best_baseline.sentence.dev.tsv .
  ln -s ../../morfessor/${lang}_best_baseline.sentence.dev.tsv ${lang}.${sentence}.dev.tsv
done

