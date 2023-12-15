#!/bin/bash

#SBATCH --job-name LFE1_1

#SBATCH --mail-type=end,fail

#SBATCH --cpus-per-task=1

#SBATCH --mem-per-cpu=3g

#SBATCH --time=03:59:00

#SBATCH --account=biostat625f23_class

#SBATCH --partition=standard




module load Rtidyverse


R CMD BATCH  second_try_f.R

