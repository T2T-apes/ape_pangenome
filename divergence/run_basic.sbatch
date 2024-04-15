#!/bin/bash
#SBATCH --qos=high
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=64gb
#SBATCH --account=cbcb
#SBATCH --partition=cbcb
#SBATCH --time=02:00:00
#SBATCH --constraint=EPYC-7313

TOOLDIR="/fs/cbcb-lab/ekmolloy/group/data/t2t_primate/data/tools"
MAFDIR="/fs/cbcb-lab/ekmolloy/group/data/t2t_primate/data/mafs"

module load Python3/3.10.10

python3 $TOOLDIR/compute_basic_div.py -r $RUN -p $MAFDIR 

