#!/bin/bash
#SBATCH --job-name=train-nmt
#SBATCH --account=project_2005881
#SBATCH --time=16:00:00
#SBATCH --partition=gpu
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --gres=gpu:v100:1

DATAROOT="/scratch/project_2005881/2022SegmentationST/data/"
AUGMENTROOT="/scratch/project_2005881/2022SegmentationST/flatcat/"
PROCESSED="/scratch/project_2005881/2022SegmentationST/nmt-experiments/processed-data/"
EXPOUT="/scratch/project_2005881/2022SegmentationST/nmt-experiments/exp-fmes/"
CONFIGDIR="/scratch/project_2005881/2022SegmentationST/nmt-experiments/configs/"
SEED=5620221720

# CHANGE THIS TO TRAIN OTHER CONFIGURATIONS:
RUN_FAMILY="A"

stage=1

. path.sh
# parse_options.sh makes it so you can specify e.g. train-baseline.sh --EXPOUT ./exp2
. parse_options.sh  

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <lang> <task>"
  echo "example: $0 fra word"
  echo "lang should be one of the three letter codes used"
  echo "task should be word or sentence"
  exit 1
fi

lang="$1"
task="$2"
expdir=${EXPOUT}/${lang}.${task}.flatcat/${RUN_FAMILY}-${SEED}

mkdir -p $expdir

### STAGE 1: Preprocess data ###
if [ $stage -le 1 ]; then
  if [ -d ${PROCESSED}/${lang}.${task}.flatcat ]; then
    echo "Using existing preprocessed data in ${PROCESSED}/${lang}.${task}.flatcat"
  else
    echo "Preprocessing data to ${PROCESSED}/${lang}.${task}.flatcat"
    mkdir -p ${PROCESSED}/${lang}.${task}.flatcat
    if [ ${task} == "sentence" ]; then
      python3 char_tokenize.py \
        ${AUGMENTROOT}/${lang}_best_flatcat.sentence.train.tsv \
        ${PROCESSED}/${lang}.${task}.flatcat/train
      python3 char_tokenize.py \
        ${AUGMENTROOT}/${lang}_best_flatcat.sentence.dev.tsv \
        ${PROCESSED}/${lang}.${task}.flatcat/dev
    else
      python3 char_tokenize.py \
        ${AUGMENTROOT}/${lang}_best_flatcat.train.tsv \
        ${PROCESSED}/${lang}.${task}.flatcat/train
      python3 char_tokenize.py \
        ${AUGMENTROOT}/${lang}_best_flatcat.dev.tsv \
        ${PROCESSED}/${lang}.${task}.flatcat/dev
    fi
  fi
fi

### STAGE 2: Train model ###

if [ $stage -le 2 ]; then
  marian \
    --model $expdir/model.npz \
    --train-sets \
      ${PROCESSED}/${lang}.${task}.flatcat/train.src.txt \
      ${PROCESSED}/${lang}.${task}.flatcat/train.tgt.txt \
    --vocabs \
      ${PROCESSED}/${lang}.${task}.flatcat/train.src.vocab \
      ${PROCESSED}/${lang}.${task}.flatcat/train.tgt.vocab \
    --valid-sets \
      ${PROCESSED}/${lang}.${task}.flatcat/dev.src.txt \
      ${PROCESSED}/${lang}.${task}.flatcat/dev.tgt.txt \
    --seed ${SEED} \
    --valid-metrics translation \
    --valid-script-path /scratch/project_2005881/2022SegmentationST/nmt-experiments/validate.py \
    --valid-script-args ${DATAROOT}/${lang}.${task}.dev.tsv \
    --valid-translation-output $expdir/"validation-{U}-updates.txt" \
    --config ${CONFIGDIR}/${RUN_FAMILY}.yaml
fi

### STAGE 3: Decode dev data ###

if [ $stage -le 3 ]; then
  marian-decoder \
    --config ${expdir}/model.npz.best-translation.npz.decoder.yml \
    --input ${PROCESSED}/${lang}.${task}.flatcat/dev.src.txt \
    --output ${expdir}/decode-dev.txt
fi

### STAGE 4: Detokenize ###

if [ $stage -le 4 ]; then
  python3 char_detokenize.py ${expdir}/decode-dev.txt ${DATAROOT}/${lang}.${task}.dev.tsv ${expdir}/decode-dev.tsv
fi

### STAGE 5: Compute the evaluation metrics ###
#NOTE: Not using --category because all lang/task pairs don't have it
if [ $stage -le 5 ]; then
  python3 /scratch/project_2005881/2022SegmentationST/evaluation/evaluate.py \
    --gold ${DATAROOT}/${lang}.${task}.dev.tsv \
    --guess ${expdir}/decode-dev.tsv \
    > ${expdir}/decode-dev.evaluation
  # Here's the output:
  tail -n5 ${expdir}/decode-dev.evaluation
fi

