#!/usr/bin/env bash
set -euo pipefail

SBATCH_FILE="/home/mlensink/slimsimulations/ABCslim/ABC_slim/slim_array.sbatch"
WAVE_SIZE=10000                 # tasks per wave (matches 0..9999 in your script)
CONCURRENCY=350                 # percent after the array range
SUBMIT_CAP=50000                # from sacctmgr
BUFFER=1000                     # keep a little headroom

submit_wave () {
  local offset="$1"
  local array_hi=$((WAVE_SIZE-1))
  echo "Submitting OFFSET=$offset  array=0-${array_hi}%${CONCURRENCY}"
  sbatch --export=ALL,OFFSET="$offset" --array="0-${array_hi}%${CONCURRENCY}" "$SBATCH_FILE"
}

# Simple loop: wait until current jobs + new wave < cap, then submit
for OFFSET in 50000 60000 70000 80000 90000; do
  need=$WAVE_SIZE
  while true; do
    cur=$(squeue -u "$USER" -h | wc -l)
    if (( cur + need < SUBMIT_CAP - BUFFER )); then
      submit_wave "$OFFSET"
      break
    fi
    sleep 10
  done
done

echo "All waves submitted."
