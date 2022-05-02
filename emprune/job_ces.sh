#!/bin/bash
#SBATCH --job-name=train_emprune
#SBATCH --account=project_2005881
#SBATCH --partition=small
#SBATCH --time=1-00:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=64G
#SBATCH -o logs/slurm-train_emprune_ces%J.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=stig-arne.gronroos@helsinki.fi

make ces_tuning.done
