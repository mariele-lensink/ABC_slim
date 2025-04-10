#!/bin/bash
#SBATCH -D /home/mlensink/slimsimulations/ABCslim/ABC_slim/
#SBATCH -o /home/mlensink/slurm-log/quicktd_stdout-%j.txt
#SBATCH -e /home/mlensink/slurm-log/quicktd_stderr-%j.txt
#SBATCH -J abc_slim
#SBATCH -t 10-00:00:00
#SBATCH --mem 30G #memory per task
#SBATCH --cpus-per-task=200
#SBATCH --account=gmonroegrp
#SBATCH --partition=bmm
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=melensink@ucdavis.edu

bash
source ~/anaconda3/etc/profile.d/conda.sh
# Activate your conda environment if needed
conda activate slimsims

#./quick_tajima.sh
./vcf_calc_td_1.26.2025.sh
