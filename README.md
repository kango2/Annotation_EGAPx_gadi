# Running EGAPx on gadi offline
EGAPx stands for Eukaryotic Genome Annotation Pipeline - External, and is used by NCBI to annotate genome. This is the [link](https://github.com/ncbi/egapx) to their github page. The pipeline uses nextflow to manage each tasks.  
What you need before running:
- **Genome assembly** (fasta format)
- **taxID of the organism** (get from [NCBI Taxonomy page](https://www.ncbi.nlm.nih.gov/taxonomy))
- **RNAseq data** (paths to the fastq/fastq.gz files if local, or the SRR accession number if they are on SRA)  
  
The genome assembly needs to have titles for each seqID or the run could fail (this is a bug), the title can be as simple as something like `>scaffold_1 title`. you can add a title with this command:
```
sed '/^>/ s/$/ title/' /path/to/your/genome.fasta \
> /path/to/temporary_genome.fasta
```
and use the output genome fasta file for annotation temporarily. This temporary genome file can be deleted afterward.
  
**NOTE:** there are multiple ways to set up the SRR accession for download, check their github page if interested.  
  
# Part 1 - Downloading files
When you submit jobs to the normal queue on NCI gadi, it will **NOT** have internet access, therefore you need to download the neccessary files before running EGAPx offline.  
This script template [1_prepare_download_for_offline.sh](https://github.com/kango2/Annotation_EGAPx_gadi/blob/main/1_prepare_download_for_offline.sh) will download all neccessary lineage, database and SRA dataset files (if SRR is supplied in input.yaml) needed to run annotation on your species genome, the main command within this script is:
```
egapx.py -e nci-gadi \
--force -dl \
-lc /path/to/store/download/files \
/path/to/input.yaml
```
**NOTE:**
- The example script [1_prepare_download_for_offline.sh](https://github.com/kango2/Annotation_EGAPx_gadi/blob/main/1_prepare_download_for_offline.sh) submits job to the copyq queue, which **DOES** have internet access but is limited to 10 hours walltime.
- Include all SRR accession numbers of the SRA dataset you want to use in input.yaml, and also the paths to all the local RNAseq fastq/fastq.gz files you want to use. Example `input.yaml` file [here](https://github.com/kango2/Annotation_EGAPx_gadi/blob/main/input.yaml)
- SRA dataset needs to be downloaded using egapx, if you downloaded them with other methods and point to them as paths, it will not work offline. (this is a bug)
- The --force option is only needed if there are more than 20 SRA datasets to download.  

# Part 2 - Running EGAPx offline
Now you are ready to run EGAPx offline, check out this script template [2_run_egapx_offline.sh](https://github.com/kango2/Annotation_EGAPx_gadi/blob/main/2_run_egapx_offline.sh), the main command within this script is:
```
cd /path/to/output/directory

egapx.py -e nci-gadi \
-lc /path/to/store/download/files \
/path/to/input.yaml \
-o /path/to/output/directory
```
**NOTE:**
- This will make a `work` directory in your current directory, hence the cd before executing. I think it can also be set with -w but haven't tested yet.
- If the job fails due to insufficient walltime, you can resume the run with command generated in `/path/to/output/directory/nextflow/resume.sh`, simply make a new script and replace the old egapx.py command with the one in `resume.sh`, example resume script here [2_run_egapx_offline_resume.sh](https://github.com/kango2/Annotation_EGAPx_gadi/blob/main/2_run_egapx_offline_resume.sh).
- Their github page also has guide on preparing the annotation for submission.
