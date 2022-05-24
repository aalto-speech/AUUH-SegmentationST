#!/bin/bash
#SBATCH --job-name=decode-nmt
#SBATCH --account=project_2005881
#SBATCH --time=0:10:00
#SBATCH --partition=gputest
#SBATCH --cpus-per-task=1
#SBATCH --mem=12G
#SBATCH --gres=gpu:v100:1

TESTDATA="/scratch/project_2005881/latest-organizer-git-for-test/data/"
PROCESSED="./test-data/"
OUTTEMP="./test-temp"
OUTMAIN="./test-outputs"
RUN_FAMILY="BLSTM-A"
SEED=5620221720
EXPDIR="./exp-fmes"

. path.sh
. parse_options.sh

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 lang task sysname"
  exit 1
fi

lang="$1"
task="$2"
sysname="$3"
dataname=${lang}.${task}.test
modeldir=${EXPDIR}/${lang}.${task}.morfessor_best/${RUN_FAMILY}-${SEED}/
morfessormdl="../morfessor//${lang}_best_baseline.bin"

mkdir -p ${PROCESSED}/$sysname
mkdir -p ${OUTTEMP}/$sysname
mkdir -p ${OUTMAIN}/$sysname

if [ -f "${OUTTEMP}/${sysname}/${dataname}.tokens" ]; then
  echo "${OUTTEMP}/${sysname}/${dataname}.tokens already exists!"
  exit 1
fi

if [ "$task" == "sentence" ]; then
  bash morfessorize-sentence.sh ${TESTDATA}/${dataname}.tsv $morfessormdl ${PROCESSED}/${sysname}/${dataname}.morf
else
  bash morfessorize-word.sh ${TESTDATA}/${dataname}.tsv $morfessormdl ${PROCESSED}/${sysname}/${dataname}.morf
fi

python3 char_tokenize_input_only.py ${PROCESSED}/${sysname}/${dataname}.morf ${PROCESSED}/${sysname}/${dataname}.txt

marian-decoder \
  --config ${modeldir}/model.npz.best-translation.npz.decoder.yml \
  --input ${PROCESSED}/${sysname}/${dataname}.txt \
  --output ${OUTTEMP}/${sysname}/${dataname}.tokens

python3 char_detokenize_output_only.py \
  ${OUTTEMP}/${sysname}/${dataname}.tokens \
  ${OUTTEMP}/${sysname}/${dataname}.txt

paste ${TESTDATA}/${dataname}.tsv ${OUTTEMP}/${sysname}/${dataname}.txt > ${OUTMAIN}/${sysname}/${dataname}.tsv
