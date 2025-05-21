#!/bin/bash
#SBATCH --array=0-49999%200               # 50k jobs, 200 concurrent
#SBATCH --job-name=slim_array
#SBATCH --output=logs/slim_array_%A_%a.out
#SBATCH --error=logs/slim_array_%A_%a.err
#SBATCH --cpus-per-task=1
#SBATCH --mem=6G
#SBATCH --time=2-00:00:00
#SBATCH --partition=bmm
#SBATCH --account=gmonroegrp
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=melensink@ucdavis.edu

source ~/anaconda3/etc/profile.d/conda.sh
conda activate slimsims

# Load the line corresponding to this task from the parameter file
PARAM_FILE="/home/mlensink/slimsimulations/ABCslim/ABC_slim/data/prior_parameters3_20k-50k.csv"
LINE=$(($SLURM_ARRAY_TASK_ID + 1))  # skip header with +1
data=$(sed -n "${LINE}p" $PARAM_FILE)

IFS=',' read -r ID gmu imu gd id gdfe idfe <<< "$data"

# Set up scratch dir
SCRATCH_DIR="/scratch/mlensink/$SLURM_JOB_ID"
mkdir -p "$SCRATCH_DIR"
SCRATCH_VCF="$SCRATCH_DIR/${ID}.vcf"
SCRATCH_VCF_GZ="$SCRATCH_DIR/${ID}.vcf.gz"

TAJIMA_OUT="/home/mlensink/slimsimulations/ABCslim/ABC_slim/data/tajima/${ID}.Tajima.D"

# CASE 1: Tajima exists but VCF doesn't → both must be redone
if [[ ! -f "$SCRATCH_VCF" && -f "$TAJIMA_OUT" ]]; then
    echo "Tajima D exists but VCF is missing for ID $ID. Deleting Tajima file and rerunning both."
    rm -f "$TAJIMA_OUT"
fi

# Run SLiM if scratch VCF missing
if [[ ! -f "$SCRATCH_VCF" ]]; then
    echo "VCF missing for ID $ID. Running SLiM."
    slim -d ID=$ID \
         -d JOBID=$SLURM_JOB_ID \
         -d gmu=$gmu \
         -d imu=$imu \
         -d gd=$gd \
         -d id=$id \
         -d gdfe=$gdfe \
         -d idfe=$idfe \
         /home/mlensink/slimsimulations/ABCslim/ABC_slim/scripts/ABC.slim

    if [[ ! -f "$SCRATCH_VCF" ]]; then
        echo "SLiM failed to produce output for ID $ID. Logging failure."
        mkdir -p logs/failed/tmp
        echo "$ID" > logs/failed/tmp/${ID}.fail
        exit 1
    fi
else
    echo "VCF already exists for ID $ID in scratch. Skipping SLiM."
fi

# Run TajimaD if output is missing
if [[ ! -f "$TAJIMA_OUT" ]]; then
    echo "Tajima D missing for ID $ID. Running vcftools."
    vcftools --vcf "$SCRATCH_VCF" \
             --out "/home/mlensink/slimsimulations/ABCslim/ABC_slim/data/tajima/${ID}" \
             --TajimaD 100
else
    echo "Tajima D already exists for ID $ID. Skipping."
fi

# Compress VCF and copy to permanent storage
if [[ -f "$SCRATCH_VCF" ]]; then
    echo "Compressing and storing VCF for ID $ID."
    bgzip -c "$SCRATCH_VCF" > "/home/mlensink/slimsimulations/ABCslim/ABC_slim/data/vcf/${ID}.vcf.gz"
    rm -f "$SCRATCH_VCF"
fi

# If last task in array, aggregate failed IDs and clean up
if [[ $SLURM_ARRAY_TASK_ID -eq 49999 ]]; then
    echo "Aggregating failure logs..."
    mkdir -p logs/failed
    cat logs/failed/tmp/*.fail > logs/failed/slim_failed_ids.txt
    rm -f logs/failed/tmp/*.fail
    rmdir logs/failed/tmp
fi
