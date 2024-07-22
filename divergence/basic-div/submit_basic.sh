#!/bin/bash

for RUN in `seq 0 19`; do
    echo "Processing $RUN"
    sbatch \
        --job-name="div.$RUN" \
        --output="div.$RUN.%j.out" \
        --error="div.$RUN.%j.err" \
        --export=RUN="$RUN" \
       run_basic.sbatch
done

