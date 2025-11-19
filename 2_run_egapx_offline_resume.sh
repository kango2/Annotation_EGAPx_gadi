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

#Copy the content of resume.sh here, the first line #!/bin/bash is not needed
#The command in resume.sh should look something like below
NXF_WORK=work nextflow -C /g/data/xl04/jc4878/skink_reference_assembly/egapx/egapx_config/slurm.config,/g/data/xl04/jc4878/skink_reference_assembly/egapx/ui/assets/config/default.config -log /g/data/xl04/jc4878/skink_reference_assembly/PUBLISHED/BASDU/annotation_egapx/annotation/nextflow/nextflow.log run /g/data/xl04/jc4878/skink_reference_assembly/egapx/ui/../nf/ui.nf --output /g/data/xl04/jc4878/skink_reference_assembly/PUBLISHED/BASDU/annotation_egapx/annotation -with-report /g/data/xl04/jc4878/skink_reference_assembly/PUBLISHED/BASDU/annotation_egapx/annotation/nextflow/run.report.html -with-timeline /g/data/xl04/jc4878/skink_reference_assembly/PUBLISHED/BASDU/annotation_egapx/annotation/nextflow/run.timeline.html -with-dag /g/data/xl04/jc4878/skink_reference_assembly/PUBLISHED/BASDU/annotation_egapx/annotation/nextflow/run.dag.dot -with-trace /g/data/xl04/jc4878/skink_reference_assembly/PUBLISHED/BASDU/annotation_egapx/annotation/nextflow/run.trace.txt -params-file /g/data/xl04/jc4878/skink_reference_assembly/PUBLISHED/BASDU/annotation_egapx/annotation/nextflow/run_params.yaml -resume
