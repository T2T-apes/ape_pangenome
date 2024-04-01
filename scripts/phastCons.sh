#!/bin/bash

PHASTCONS=$1
PATH_COMBINATIONS=$2
CHR=$3
DIR_OUTPUT=$4
MAF=$5

combinations=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $PATH_COMBINATIONS)

IFS=" " read len <<< $combinations

tcs=($(seq 0 0.05 1))
for tc in "${tcs[@]}"; do
    echo "$PHASTCONS --most-conserved $DIR_OUTPUT/ELEMENTS/$CHR.conserved.$tc.$len.bed --target-coverage $tc --expected-length $len --rho 0.3 --msa-format MAF $MAF $DIR_OUTPUT/$CHR.4d.mod > /dev/null"
    $PHASTCONS --most-conserved $DIR_OUTPUT/ELEMENTS/$CHR.conserved.$tc.$len.bed --target-coverage $tc --expected-length $len --rho 0.3 --msa-format MAF $MAF $DIR_OUTPUT/$CHR.4d.mod > /dev/null #TO SAVE SPACE: | gzip > $DIR_OUTPUT/SCORES/$CHR.scores.$tc.$len.wig.gz
done
