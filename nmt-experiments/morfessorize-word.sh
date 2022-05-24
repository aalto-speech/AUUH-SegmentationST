#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <inp> <morfessor-mdl> <out>"
  exit 1
fi

inp=$1
morfmdl=$2
out=$3

source ./more-morfessor-path.sh

morfessor-segment \
    -l $morfmdl \
    --output-format "{analysis}" --output-format-separator "⁙" --output-newlines \
    -o $out \
    - <$inp
