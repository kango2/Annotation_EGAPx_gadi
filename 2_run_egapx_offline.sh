#!/bin/bash
#PBS -N run_EGAPx_offline
#PBS -l ncpus=1
#PBS -l mem=40GB
#PBS -l walltime=48:00:00
#PBS -l storage=gdata/xl04+scratch/xl04+gdata/if89
#PBS -j oe


#Load modules
module use /g/data/if89/apps/modulefiles
module load egapx/0.4.1-alpha
module load nextflow/25.04.6

#Run EGAPx
cd /path/to/output/directory

egapx.py -e nci-gadi \
-lc /path/to/store/download/files \
/path/to/input_new.yaml \
-o /path/to/output/directory
