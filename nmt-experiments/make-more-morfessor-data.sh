#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <lang> <weight>"
  exit 1
fi

lang=$1
weight=$2

source ./more-morfessor-path.sh

mkdir -p more-morfessor


#WORDS:
cat ../data/${lang}.word.train.tsv \
  | cut -f 1 \
  | morfessor-segment \
    -l ../morfessor/${lang}_tuning/baseline_${weight}.bin \
    --output-format "{analysis}" --output-format-separator "⁙" --output-newlines \
    -o more-morfessor/${lang}_${weight}_baseline.train.txt -

cat ../data/${lang}.word.train.tsv | \
  cut -f 2- | \
  paste more-morfessor/${lang}_${weight}_baseline.train.txt - | \
  grep -v '^	' > more-morfessor/${lang}_${weight}_baseline.train.tsv

cat ../data/${lang}.word.dev.tsv \
  | cut -f 1 \
  | morfessor-segment \
    -l ../morfessor/${lang}_tuning/baseline_${weight}.bin \
    --output-format "{analysis}" --output-format-separator "⁙" --output-newlines \
    -o more-morfessor/${lang}_${weight}_baseline.dev.txt -

cat ../data/${lang}.word.dev.tsv | \
  cut -f 2- | \
  paste more-morfessor/${lang}_${weight}_baseline.dev.txt - | \
  grep -v '^	' > more-morfessor/${lang}_${weight}_baseline.dev.tsv


#SENTENCES:
cat ../data/${lang}.sentence.train.tsv \
  | cut -f 1 \
  | morfessor-segment \
    -l ../morfessor/${lang}_tuning/baseline_${weight}.bin \
    --output-format "{analysis} " --output-format-separator "⁙" --output-newlines \
    -o more-morfessor/${lang}_${weight}_baseline.sentence.train.txt -

cat ../data/${lang}.sentence.train.tsv | \
  cut -f 2- | \
  paste more-morfessor/${lang}_${weight}_baseline.sentence.train.txt - | \
  grep -v '^	' > more-morfessor/${lang}_${weight}_baseline.sentence.train.tsv

cat ../data/${lang}.sentence.dev.tsv \
  | cut -f 1 \
  | morfessor-segment \
    -l ../morfessor/${lang}_tuning/baseline_${weight}.bin \
    --output-format "{analysis} " --output-format-separator "⁙" --output-newlines \
    -o more-morfessor/${lang}_${weight}_baseline.sentence.dev.txt -

cat ../data/${lang}.sentence.dev.tsv | \
  cut -f 2- | \
  paste more-morfessor/${lang}_${weight}_baseline.sentence.dev.txt - | \
  grep -v '^	' > more-morfessor/${lang}_${weight}_baseline.sentence.dev.tsv
