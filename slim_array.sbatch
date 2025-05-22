#!/bin/bash
#SBATCH --array=0-49999%100               # 50k jobs, 200 concurrent
#SBATCH --job-name=slim_array
#SBATCH --output=logs/slim_array_%A_%a.out
#SBATCH --error=logs/slim_array_%A_%a.err
#SBATCH --cpus-per-task=2
#SBATCH --mem=2G
#SBATCH --time=1-00:00:00
#SBATCH --partition=bmh
#SBATCH --account=gmonroegrp
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=melensink@ucdavis.edu

source ~/anaconda3/etc/profile.d/conda.sh
conda activate slimsims

echo "SLURM_JOB_ID=$SLURM_JOB_ID"
echo "SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID"

# Load the line corresponding to this task from the parameter file
PARAM_FILE="/home/mlensink/slimsimulations/ABCslim/ABC_slim/data/prior_parameters3_20k-50k.csv"
LINE=$(($SLURM_ARRAY_TASK_ID + 2))  # Skip header and align 0-based index with data lines  
# Now that we start at line 2, task ID maps directly to the data line
data=$(sed -n "${LINE}p" $PARAM_FILE)

IFS=',' read -r ID gmu imu gd id gdfe idfe <<< "$data"

# Set up scratch dir
SCRATCH_DIR="/scratch/mlensink/${SLURM_JOB_ID}_${SLURM_ARRAY_TASK_ID}"
mkdir -p "$SCRATCH_DIR"
SCRATCH_VCF="$SCRATCH_DIR/${ID}.vcf"
SCRATCH_VCF_GZ="$SCRATCH_DIR/${ID}.vcf.gz"
SLIM_LOG="$SCRATCH_DIR/${ID}.slim.log"


TAJIMA_OUT="/home/mlensink/slimsimulations/ABCslim/ABC_slim/data/tajima/${ID}.Tajima.D"
FINAL_VCF="/home/mlensink/slimsimulations/ABCslim/ABC_slim/data/vcf/${ID}.vcf.gz"
FINAL_VCF_uncompressed="/home/mlensink/slimsimulations/ABCslim/ABC_slim/data/vcf/${ID}.vcf"


# CASE 1: Tajima exists but VCF doesn't → both must be redone
if [[ ! -f "$SCRATCH_VCF" && ! -f "$FINAL_VCF_uncompressed"&& ! -f "$FINAL_VCF" && -f "$TAJIMA_OUT" ]]; then
    echo "Tajima D exists but VCF is missing for ID $ID. Deleting Tajima file and rerunning both."
    rm -f "$TAJIMA_OUT"
fi

# Run SLiM if VCF missing
if [[ ! -f "$FINAL_VCF" && ! -f "$FINAL_VCF_uncompressed" ]]; then
    echo "VCF missing for ID $ID. Running SLiM."
    slim -d ID=$ID \
         -d JOBID=$SLURM_JOB_ID \
         -d gmu=$gmu \
         -d imu=$imu \
         -d gd=$gd \
         -d id=$id \
         -d gdfe=$gdfe \
         -d idfe=$idfe \
         /home/mlensink/slimsimulations/ABCslim/ABC_slim/scripts/ABC.slim \
         > "$SCRATCH_VCF" 2> "$SLIM_LOG"

    if [[ ! -f "$SCRATCH_VCF" ]]; then
        echo "SLiM failed to produce output for ID $ID. Logging failure."
        mkdir -p logs/failed/tmp
        echo "$ID" > logs/failed/tmp/${ID}.fail
        exit 1
    fi
else
    echo "VCF already exists for ID $ID in scratch. Skipping SLiM."
fi

# Prefer scratch VCF if available
if [[ -f "$SCRATCH_VCF" ]]; then
    echo "Using VCF from scratch for ID $ID."
    VCFCMD="vcftools --vcf $SCRATCH_VCF"
elif [[ -f "$FINAL_VCF_uncompressed" ]]; then
    echo "Using uncompressed VCF from data/vcf for ID $ID."
    VCFCMD="vcftools --vcf $FINAL_VCF_uncompressed"
elif [[ -f "$FINAL_VCF" ]]; then
    echo "Using compressed VCF from data/vcf (streaming) for ID $ID."
    VCFCMD="gunzip -c $FINAL_VCF | vcftools --vcf -"
else
    echo "ERROR: No VCF file found for ID $ID. Cannot run TajimaD."
    mkdir -p logs/failed/tmp
    echo "$ID" > logs/failed/tmp/${ID}.fail
    exit 1
fi

# Run TajimaD if output is missing
if [[ ! -f "$TAJIMA_OUT" ]]; then
    echo "Running Tajima D for ID $ID."
    eval "$VCFCMD --out /home/mlensink/slimsimulations/ABCslim/ABC_slim/data/tajima/${ID} --TajimaD 100"
else
    echo "Tajima D already exists for ID $ID. Skipping."
fi


# Compress VCF and copy to permanent storage
if [[ -f "$SCRATCH_VCF" ]]; then
    echo "Compressing and storing VCF for ID $ID."
    bgzip -c "$SCRATCH_VCF">"$FINAL_VCF"
    # Save SLiM log file to permanent logs directory
    mkdir -p /home/mlensink/slimsimulations/ABCslim/ABC_slim/logs/slim_logs
    cp "$SLIM_LOG" "/home/mlensink/slimsimulations/ABCslim/ABC_slim/logs/slim_logs/${ID}.slim.log"
    rm -rf "$SCRATCH_DIR"
fi

# If last task in array, aggregate failed IDs and clean up
if [[ $SLURM_ARRAY_TASK_ID -eq 49999 ]]; then
    echo "Aggregating failure logs..."
    mkdir -p logs/failed
    cat logs/failed/tmp/*.fail > logs/failed/slim_failed_ids.txt
    rm -f logs/failed/tmp/*.fail
    rmdir logs/failed/tmp
fi
