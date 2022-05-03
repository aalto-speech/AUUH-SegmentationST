#!/bin/bash
#SBATCH --job-name=train-nmt
#SBATCH --account=project_205881
#SBATCH --time=0:10:0
#SBATCH --partition=gputest
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBTACH --gres=gpu:v100:1

DATAROOT="/scratch/project_2005881/2022SegmentationST/data/"
PROCESSED="/scratch/project_2005881/2022SegmentationST/nmt-experiments/processed-data/"
EXPOUT="/scratch/project_2005881/2022SegmentationST/nmt-experiments/exp/"
CONFIGDIR="/scratch/project_2005881/2022SegmentationST/nmt-experiments/configs/"

# CHANGE THIS TO TRAIN OTHER CONFIGURATIONS:
RUN_FAMILY="A"

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <lang> <task>"
  echo "example: $0 fra word"
  echo "lang should be one of the three letter codes used"
  echo "task should be word or sentence"
  exit 1
fi

lang="$1"
task="$2"
expdir=${EXPOUT}/${lang}.${task}/${RUN_FAMILY}

mkdir -p $expdir

source path.sh

python3 char_tokenize.py \
  ${DATAROOT}/${lang}.${task}.train.tsv \
  ${PROCESSED}/${lang}.${task}.train
python3 char_tokenize.py \
  ${DATAROOT}/${lang}.${task}.dev.tsv \
  ${PROCESSED}/${lang}.${task}.dev


marian \
  --model $expdir/model.npz \
  --train-sets \
    ${PROCESSED}/${ḷang}.${task}.train.src.txt \
    ${PROCESSED}/${ḷang}.${task}.train.tgt.txt \
  --vocabs \
    ${PROCESSED}/${ḷang}.${task}.train.src.vocab \
    ${PROCESSED}/${ḷang}.${task}.train.tgt.vocab \
  --valid-sets \
    ${PROCESSED}/${ḷang}.${task}.dev.src.txt \
    ${PROCESSED}/${ḷang}.${task}.dev.tgt.txt \
  --config ${CONFIGDIR}/${RUN_FAMILY}.yaml

