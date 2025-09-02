#!/usr/bin/env bash
set -euo pipefail

SBATCH_FILE="/home/mlensink/slimsimulations/ABCslim/ABC_slim/slim_array.sbatch"

submit () {
  local offset=$1
  local array=$2
  echo "Submitting OFFSET=$offset  array=$array%350"
  sbatch --export=ALL,OFFSET="$offset" --array="$array%350" "$SBATCH_FILE"
}

# Waves of 10k each (0-9999)
submit 50000 "0-9999"
submit 60000 "0-9999"
submit 70000 "0-9999"
submit 80000 "0-9999"

# Last big wave trimmed to 9,999 tasks (0-9998)
#submit 90000 "0-9998"

# Reminder: one straggler left (OFFSET=99999)
echo
echo ">>> When you have queue headroom, submit the final single task with:"
echo "sbatch --export=ALL,OFFSET=99999 --array=0-0%350 $SBATCH_FILE"