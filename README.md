# Running EGAPx on gadi offline
EGAPx (**E**ukaryotic **G**enome **A**nnotation **P**ipeline – e**x**ternal) is the pipeline used by NCBI to annotate eukaryotic genomes.  
Official github: [https://github.com/ncbi/egapx](https://github.com/ncbi/egapx)  
EGAPx uses **Nextflow** to manage workflow execution.
  
This guide explains how to run EGAPx **offline on gadi**, including several extra steps required to work around current **Alpha-stage bugs**.
  
# Requirements
Before running EGAPx, you need:
- **Genome assembly** (fasta format)
- **taxID of the organism**  
  (Find it on [NCBI Taxonomy page](https://www.ncbi.nlm.nih.gov/taxonomy))
- **RNA-seq data**:  
   SRA accession numbers (SRR) if they are on NCBI SRA  
   Path to the fastq/fastq.gz files if they are local

**IMPORTANT - Add a title to each FASTA header**  
  
EAGPx can randomly fail if the FASTA headers do not contain a title (bug).  
Your FASTA headers must look something like:
```
>scaffold1 title
>scaffold2 title
```
You can automatically append "title" to every header using:
```
sed '/^>/ s/$/ title/' /path/to/your/genome.fasta \
> /path/to/temporary_genome.fasta
```
Use this temporary genome file for annotation.  
You can delete it afterward.
  
# Part 1 - Downloading required files
[Back to Top](#Running-EGAPx-on-gadi-offline)  
  
Jobs submitted to the normal Gadi queues do not have internet access.  
So you must pre-download all required files **before running EGAPx offline**.  
  
### 1. Create `input_download.yaml`
This YAML file must include:  
- Path to your genome
- TaxID
- SRA dataset accession numbers (if any)
  
Example:  
[input_download.yaml](https://github.com/kango2/Annotation_EGAPx_gadi/blob/main/input_download.yaml)  
### 2. Submit the download job
Use this script template:  
[1_prepare_download_for_offline.sh](https://github.com/kango2/Annotation_EGAPx_gadi/blob/main/1_prepare_download_for_offline.sh)  
Core command within this script is:
```
egapx.py -e nci-gadi \
--force -dl \
-lc /path/to/store/download/files \
/path/to/input_download.yaml
```
**IMPORTANT NOTES**  
  
**1. DO NOT include local RNA-seq paths in the download YAML**  
  Only include SRA SRR accessions here.  
	Local FASTQ paths will cause failure in downloading any SRA dataset (bug).  
  
**2. You must let EGAPx download SRA datasets itself**  
  if you downloaded the dataset using other methods and point to them as local files, offline mode will not work (bug).  
  
**3. The download script must run in a queue with internet**  
  In the example script, the job is submitted to `copyq`, it has internet but is limited to 1 cpu and 10hrs walltime.  

**4. --force is only needed if you have >20 SRR accession to download**  
  
**KNOWN ISSUE**  
Sometime when downloading the gnomon/2 directory it'll fail randomly with an error message that ends with:
```
ftplib.error_temp: 421 Idle timeout (60 seconds): closing control connection
```
Just ignore it and re-submit the job.  
  
# Part 2 - Running EGAPx offline
[Back to Top](#Running-EGAPx-on-gadi-offline)  
  
Now that all files are downloaded, prepare a new YAML file for the offline run.  
### 1. Create `input_new.yaml`
Start by copying:
```
cp input_download.yaml input_new.yaml
```
Replace the SRR accessions with their corresponding **local FASTA paths**, which are inside a sub-directory `./sra_dir` in the download directory.  
To list them:
```
ls /path/to/store/download/files/sra_dir/*.fasta | \
awk '{print "  - "$1}'
```
Paste the output into `input_new.yaml` to replace the SRRs.  
**If you have additional local RNA-seq files, append them to `input_new.yaml` as well**
  
Example:  
[input_new.yaml](https://github.com/kango2/Annotation_EGAPx_gadi/blob/main/input_new.yaml)

### 2. Run EGAPx offline
Use script template:  
[2_run_egapx_offline.sh](https://github.com/kango2/Annotation_EGAPx_gadi/blob/main/2_run_egapx_offline.sh)  
Core command within this script is:
```
cd /path/to/output/directory

egapx.py -e nci-gadi \
-lc /path/to/store/download/files \
/path/to/input_new.yaml \
-o /path/to/output/directory
```
**NOTE**
- EGAPx creates a `./work` directory in the **current working directory**, which is why the script does `cd` before running.  
  (`-w` might work aswell as an alternative but not yet tested)  
- If your job runs out of walltime:
  - A resume command is saved at:
    `/path/to/output/directory/nextflow/resume.sh`
  - Make a new PBS script and replace the egapx.py command with the resume command.
  
  Example resume script:  
  [2_run_egapx_offline_resume.sh](https://github.com/kango2/Annotation_EGAPx_gadi/blob/main/2_run_egapx_offline_resume.sh)  
- EGAPx GitHub page also includes instruction for preparing annotation submission files.
