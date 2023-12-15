#! /bin/bash



#SBATCH --job-name L2E1_1

#SBATCH --mail-type=end,fail

#SBATCH --cpus-per-task=1

#SBATCH --mem-per-cpu=3g

#SBATCH --time=05:59:59

#SBATCH --account=biostat625f23_class

#SBATCH --partition=standard



module load Rtidyverse



R CMD BATCH second_try_2.R
