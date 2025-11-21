#!/bin/bash
#PBS -N download
#PBS -q copyq
#PBS -l ncpus=1,walltime=10:00:00,storage=gdata/if89+gdata/xl04,mem=20GB
#PBS -j oe
#PBS -M z5205618@ad.unsw.edu.au
#PBS -m ae

module use /g/data/if89/apps/modulefiles
module load egapx/0.4.1-alpha
module load nextflow/25.04.6
module load sratoolkit/3.1.1

cd /path/to/store/download/files

egapx.py -e nci-gadi \
--force -dl \
-lc /path/to/store/download/files \
/path/to/input_download.yaml

#If the job is killed due to walltime exceeding limit, resubmit again and it'll continue downloading from where it left off.
