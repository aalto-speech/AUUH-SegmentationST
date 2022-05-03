#!/bin/bash
#SBATCH --job-name=train-nmt
#SBATCH --account=project_2005881
#SBATCH --time=16:00:00
#SBATCH --partition=gpu
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --gres=gpu:v100:1

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

### STAGE 1: Preprocess data ###

if [ -d ${PROCESSED}/${lang}.${task} ]; then
  echo "Using existing preprocessed data in"
  echo " ${PROCESSED}/${lang}.${task}"
else
  echo "Preprocess data to ${PROCESSED}/${lang}.${task}"
  mkdir ${PROCESSED}/${lang}.${task}
  python3 char_tokenize.py \
    ${DATAROOT}/${lang}.${task}.train.tsv \
    ${PROCESSED}/${lang}.${task}/train
  python3 char_tokenize.py \
    ${DATAROOT}/${lang}.${task}.dev.tsv \
    ${PROCESSED}/${lang}.${task}/dev
fi

### STAGE 2: Train model ###

marian \
  --model $expdir/model.npz \
  --train-sets \
    ${PROCESSED}/${lang}.${task}/train.src.txt \
    ${PROCESSED}/${lang}.${task}/train.tgt.txt \
  --vocabs \
    ${PROCESSED}/${lang}.${task}/train.src.vocab \
    ${PROCESSED}/${lang}.${task}/train.tgt.vocab \
  --valid-sets \
    ${PROCESSED}/${lang}.${task}/dev.src.txt \
    ${PROCESSED}/${lang}.${task}/dev.tgt.txt \
  --config ${CONFIGDIR}/${RUN_FAMILY}.yaml

### STAGE 3: Decode dev data ###

marian-decoder \
  --config ${expdir}/model.npz.best-cross-entropy.npz.decoder.yml \
  --input ${PROCESSED}/${lang}.${task}/dev.src.txt \
  --output ${expdir}/decode-dev.txt

### STAGE 4: Detokenize ###

python char_detokenize.py ${expdir}/decode-dev.txt ${DATAROOT}/${lang}.${task}.dev.tsv ${expdir}/decode-dev.tsv

### STAGE 5: Compute the evaluation metrics ###

if [ "$task" == "word" ]; then
  python /scratch/project_2005881/2022SegmentationST/evaluation/evaluate.py \
    --category \
    --gold ${DATAROOT}/${lang}.${task}.dev.tsv \
    --guess ${expdir}/decode-dev.tsv \
    > ${expdir}/decode-dev.evaluation
else
  python /scratch/project_2005881/2022SegmentationST/evaluation/evaluate.py \
    --gold ${DATAROOT}/${lang}.${task}.dev.tsv \
    --guess ${expdir}/decode-dev.tsv \
    > ${expdir}/decode-dev.evaluation
fi
# Here's the output:
tail -n5 ${expdir}/decode-dev.evaluation
