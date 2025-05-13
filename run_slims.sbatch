#!/bin/bash
#SBATCH -D /home/mlensink/slimsimulations/ABCslim/ABC_slim/
#SBATCH -o /home/mlensink/slurm-log/abcslim_stdout-%j.txt
#SBATCH -e /home/mlensink/slurm-log/abcslim_stderr-%j.txt
#SBATCH -J abc_slim
<<<<<<< HEAD
#SBATCH -t 22-00:00:00
#SBATCH --mem 100G
=======
#SBATCH -t 4-00:00:00
#SBATCH --mem 50G
>>>>>>> 7956874d4f0e6b87a4a7610d60d1156f110c5efa
#SBATCH --ntasks=200
#SBATCH --cpus-per-task=1
#SBATCH --account=gmonroegrp
#SBATCH --partition=bmh
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=melensink@ucdavis.edu

bash
source ~/anaconda3/etc/profile.d/conda.sh
# Activate your conda environment if needed
conda activate slimsims

#Rscript /home/mlensink/slimsimulations/ABCslim/ABC_slim/scripts/generate_parameters.R
snakemake --snakefile Snakefile \
	  --configfile config.yaml \
	  --jobs 200\
	  --cores 200 \
	  --latency-wait 30 \
          --rerun-incomplete \
          --keep-going


