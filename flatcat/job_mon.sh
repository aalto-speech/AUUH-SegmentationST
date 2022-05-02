#!/bin/bash
#SBATCH --job-name=train_flatcat
#SBATCH --account=project_2005881
#SBATCH --partition=small
#SBATCH --time=1-00:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=64G
#SBATCH -o logs/slurm-train_flatcat%J.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=stig-arne.gronroos@helsinki.fi

make mon_tuning.done
