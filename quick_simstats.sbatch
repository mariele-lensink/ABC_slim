#!/bin/bash
#SBATCH -D /home/mlensink/slimsimulations/ABCslim/ABC_slim/
#SBATCH -o /home/mlensink/slurm-log/quicksimstats_stdout-%j.txt
#SBATCH -e /home/mlensink/slurm-log/quicksimstats_stderr-%j.txt
#SBATCH -J abc_slim
#SBATCH -t 3-00:00:00
#SBATCH --mem 60G 
#SBATCH --cpus-per-task=200
#SBATCH --account=gmonroegrp
#SBATCH --partition=bmm
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=melensink@ucdavis.edu

bash
source ~/anaconda3/etc/profile.d/conda.sh
# Activate your conda environment if needed
conda activate slimsims

Rscript calc_sim_stats.R