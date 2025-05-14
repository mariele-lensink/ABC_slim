#!/bin/bash
#SBATCH -D /home/mlensink/slimsimulations/ABCslim/ABC_slim/
#SBATCH -o /home/mlensink/slurm-log/abcslim_stdout-%j.txt
#SBATCH -e /home/mlensink/slurm-log/abcslim_stderr-%j.txt
#SBATCH -J abc_slim
#SBATCH -t 2-00:00:00
#SBATCH --mem 200G
#SBATCH --ntasks=400
#SBATCH --cpus-per-task=1
#SBATCH --account=gmonroegrp
#SBATCH --partition=bmm
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=melensink@ucdavis.edu

bash
source ~/anaconda3/etc/profile.d/conda.sh
# Activate your conda environment if needed
conda activate slimsims

Rscript /home/mlensink/slimsimulations/ABCslim/ABC_slim/scripts/generate_parameters.R
snakemake --snakefile Snakefile \
	  --configfile config.yaml \
	  --jobs 400\
	  --cores 400 \
	  --latency-wait 60 \
          --rerun-incomplete \
          --keep-going


