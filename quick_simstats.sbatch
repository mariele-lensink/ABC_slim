#!/bin/bash
#SBATCH -D /home/mlensink/slimsimulations/ABCslim/ABC_slim/
#SBATCH -o /home/mlensink/slurm-log/quicksimstats_stdout-%j.txt
#SBATCH -e /home/mlensink/slurm-log/quicksimstats_stderr-%j.txt
#SBATCH -J abc_simstats
#SBATCH -t 00:30:00
#SBATCH --mem 50G
#SBATCH --cpus-per-task=100
#SBATCH --account=gmonroegrp
#SBATCH --partition=bmm
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=melensink@ucdavis.edu

bash
source ~/anaconda3/etc/profile.d/conda.sh
# Activate your conda environment if needed
conda activate slimsims

Rscript calc_sim_stats.R
