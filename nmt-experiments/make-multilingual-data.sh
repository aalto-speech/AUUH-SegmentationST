#!/bin/bash

# Just a basic script to record what I did.

mkdir -p multiling-data
cd multiling-data

rm -f all.sentence.train.tsv
rm -f all.sentence.dev.tsv
rm -f all.word.train.tsv
rm -f all.word.dev.tsv

for lang in eng ces mon; do
  #Make a model with allllll data and a model with just the word level data
  cat \
    <(sed "s/^/⌬/g" ../../data/${lang}.word.train.tsv ) \
    ../../data/${lang}.sentence.train.tsv \
    | sed "s/^/<$lang>/g" \
  >> all.sentence.train.tsv
  sed "s/^/<$lang>/g" ../../data/${lang}.word.train.tsv \
  >> all.word.train.tsv

  #dev to specific languages:
  # Going to just use sentence level data for this:
  sed "s/^/<$lang>/g" ../../data/${lang}.sentence.dev.tsv \
  >> all.sentence.dev.tsv
  sed "s/^/<$lang>/g" ../../data/${lang}.word.dev.tsv \
  > ${lang}.word.dev.tsv
done

for lang in fra hun ita lat rus spa; do
  #sed "s/^/<$lang>⌬/g" ../../data/${lang}.word.train.tsv \
  #>> all.sentence.train.tsv
  sed "s/^/<$lang>/g" ../../data/${lang}.word.train.tsv \
  >> all.word.train.tsv
  sed "s/^/<$lang>/g" ../../data/${lang}.word.dev.tsv \
  > ${lang}.word.dev.tsv
done

sort --random-sort all.sentence.train.tsv -o all.sentence.train.tsv
sort --random-sort all.word.train.tsv -o all.word.train.tsv

# Take subsets for development:
for lang in eng ces mon fra hun ita lat rus spa; do
  sort --random-sort ${lang}.word.dev.tsv | head -n 1000 >> all.word.dev.tsv
done
