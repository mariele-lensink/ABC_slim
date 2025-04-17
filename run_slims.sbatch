#!/bin/bash
#SBATCH -D /home/mlensink/slimsimulations/ABCslim/ABC_slim/
#SBATCH -o /home/mlensink/slurm-log/abcslim_apr16_stdout-%j.txt
#SBATCH -e /home/mlensink/slurm-log/abcslim_apr16_stderr-%j.txt
#SBATCH -J abc_slim_apr16
#SBATCH -t 22-00:00:00
#SBATCH --mem 10G
#SBATCH --ntasks=100
#SBATCH --cpus-per-task=1
#SBATCH --account=gmonroegrp
#SBATCH --partition=bmh
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=melensink@ucdavis.edu

bash
source ~/anaconda3/etc/profile.d/conda.sh
# Activate your conda environment if needed
conda activate slimsims

Rscript /home/mlensink/slimsimulations/ABCslim/ABC_slim/scripts/generate_parameters.R
snakemake --snakefile Snakefile \
	  --configfile config.yaml \
	  --jobs 100\
	  --cores $SLURM_CPUS_PER_TASK \
	  --latency-wait 60 \
          --rerun-incomplete \
          --keep-going


