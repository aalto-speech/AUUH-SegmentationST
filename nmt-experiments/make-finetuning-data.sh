#!/bin/bash

# Just a basic script to record what I did.

mkdir -p multiling-data
cd multiling-data

for lang in eng ces mon; do
  #Make a model with allllll data and a model with just the word level data
  cat \
    <(sed "s/^/⌬/g" ../../data/${lang}.word.train.tsv ) \
    ../../data/${lang}.sentence.train.tsv \
    | sed "s/^/<$lang>/g" \
  > ${lang}.sentence.train.tsv
  cp ${lang}.sentence.train.tsv ${lang}.word.train.tsv
  #sed "s/^/<$lang>⌬/g" ../../data/${lang}.word.train.tsv \
  #> ${lang}.word.train.tsv

  #dev to specific languages:
  # Going to just use sentence level data for this:
  sed "s/^/<$lang>⌬/g" ../../data/${lang}.word.dev.tsv \
  > ${lang}.word.dev.tsv
  sed "s/^/<$lang>/g" ../../data/${lang}.sentence.dev.tsv \
  > ${lang}.sentence.dev.tsv
done

for lang in fra hun ita lat rus spa; do
  sed "s/^/<$lang>⌬/g" ../../data/${lang}.word.train.tsv \
  > ${lang}.word.train.tsv
done

