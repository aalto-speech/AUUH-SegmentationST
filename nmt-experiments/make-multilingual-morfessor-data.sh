#!/bin/bash

# Just a basic script to record what I did.

mkdir -p multiling-morfessor-data
cd multiling-morfessor-data

rm -f all_best_baseline.sentence.train.tsv
rm -f all_best_baseline.sentence.dev.tsv

#Make a model with all sentence and word level data for these languages
for lang in eng ces mon; do
  cat \
    <(sed "s/^/⌬/g" ../../morfessor/${lang}_best_baseline.train.tsv ) \
    ../../morfessor/no_case_folding/${lang}_best_baseline.sentence.train.tsv \
    | sed "s/^/<$lang>/g" \
  > ${lang}_best_baseline.sentence.train.tsv
  sort --random-sort ${lang}_best_baseline.sentence.train.tsv -o ${lang}_best_baseline.sentence.train.tsv
  cp ${lang}_best_baseline.sentence.train.tsv ${lang}_best_baseline.train.tsv
  cat ${lang}_best_baseline.sentence.train.tsv >> all_best_baseline.sentence.train.tsv

  sed "s/^/<$lang>/g" ../../morfessor/no_case_folding/${lang}_best_baseline.sentence.dev.tsv \
  > ${lang}_best_baseline.sentence.dev.tsv
  cat ${lang}_best_baseline.sentence.dev.tsv >> all_best_baseline.sentence.dev.tsv

  sed "s/^/<$lang>⌬/g" ../../morfessor/${lang}_best_baseline.dev.tsv \
  > ${lang}_best_baseline.dev.tsv
done

sort --random-sort all_best_baseline.sentence.train.tsv -o all_best_baseline.sentence.train.tsv

ln -s all_best_baseline.sentence.train.tsv all.sentence.train.tsv
ln -s all_best_baseline.sentence.dev.tsv all.sentence.dev.tsv
