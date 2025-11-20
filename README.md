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
  
# Part 1 - Downloading files
When you submit jobs to the normal queue on NCI gadi, it will **NOT** have internet access, therefore you need to download the neccessary files before running EGAPx offline.  
This script template [1_prepare_download_for_offline.sh](https://github.com/kango2/Annotation_EGAPx_gadi/blob/main/1_prepare_download_for_offline.sh) will download all neccessary lineage, database and SRA dataset files (if SRR is supplied in input_download.yaml) needed to run annotation on your species genome, the main command within this script is:
```
egapx.py -e nci-gadi \
--force -dl \
-lc /path/to/store/download/files \
/path/to/input_download.yaml
```
**IMPORTANT**
- Only include SRA dataset in `input_download.yaml`, **DO NOT** include any local RNAseq file paths yet or download will fail (bug). Example `input_download.yaml` [here](https://github.com/kango2/Annotation_EGAPx_gadi/blob/main/input_download.yaml)
- SRA dataset needs to be downloaded through egapx, if you downloaded them by other methods and point to them as local paths, offline mode will not work (bug)
  
**NOTE:**
- The example script [1_prepare_download_for_offline.sh](https://github.com/kango2/Annotation_EGAPx_gadi/blob/main/1_prepare_download_for_offline.sh) submits job to the copyq queue, which **DOES** have internet access but is limited to 10 hours walltime.
- There are multiple ways to set up the SRR accession inside `input_download.yaml` for download, check their github page if interested.
- The --force option is only needed if there are more than 20 SRA datasets to download.  

# Part 2 - Running EGAPx offline
Now you need a new yaml file for the actual offline EGAPx run.  
First, make a copy of `input_download.yaml` and name it `input_new.yaml`, then replace the SRR accessions numbers with local file paths, a quick command to get SRA dataset local paths below:
```
ls /path/to/store/download/files/sra_dir/*.fasta | \
awk '{print "  - "$1}'
```
Copy the output and replace the SRR accession numbers in `input_new.yaml`.  
Second, if you have any local non-SRA RNAseq files, append the path of these to `input_new.yaml`. Example of `input_new.yaml` [here](https://github.com/kango2/Annotation_EGAPx_gadi/blob/main/input_new.yaml).  
  
Now you are ready to run EGAPx offline, check out this script template [2_run_egapx_offline.sh](https://github.com/kango2/Annotation_EGAPx_gadi/blob/main/2_run_egapx_offline.sh), the main command within this script is:
```
cd /path/to/output/directory

egapx.py -e nci-gadi \
-lc /path/to/store/download/files \
/path/to/input_new.yaml \
-o /path/to/output/directory
```
**NOTE:**
- This will make a `./work` directory in your current directory, hence the cd command before executing. I think it can also be set with -w but haven't tested yet.
- If the job fails due to insufficient walltime, you can resume the run with command generated in `/path/to/output/directory/nextflow/resume.sh`, simply make a new script and replace the old egapx.py command with the one in `resume.sh`, example resume script here [2_run_egapx_offline_resume.sh](https://github.com/kango2/Annotation_EGAPx_gadi/blob/main/2_run_egapx_offline_resume.sh).
- Their github page also has guide on preparing the annotation for submission.
