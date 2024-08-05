# Setting up `nfcore/viralrecon` to align and variant-call manuscript samples

`nf-core/viralrecon` is an open-source Nextflow pipeline that performs much of the bioinformatics users with viral amplicon data would want: read quality control, alignment, variant-calling, consensus-sequence calling, lineage classification, etc. Rather than writing our own pipeline to do these things, we simply downloaded and configured `viralrecon` according to the following specifications.

## Compute Infrastructures Used

Depending on what resources were available, we ran `viralrecon` on input FASTQ files on either University of Wisconsin-Madison's Center for High Throughput Computing (CHTC) or on a local Apple Mac Studio owned by David H. O'Connor's lab.

## Setup on the CHTC HPC Cluster

### File Transfers

CHTC maintains a high-performance computing cluster using the Slurm scheduler, which `viralrecon` supports. To run the pipeline on this manuscript's samples there, we first made a directory in the cluster's `scratch` space and downloaded `viralrecon`, like so:

-   First connect to the cluster with `ssh <USERNAME>@spark-login.chtc.wisc.edu`
-   Change into a scratch working directory with `cd /scratch/<USERNAME>/<WORKING_DIR>`
-   Download the `viralrecon` files with `git clone --branch 2.6.0 https://github.com/nf-core/viralrecon.git .`
-   Transfer the files onto the cluster with `rsync -azvP <FASTQ_DIR> <USERNAME>@spark-login.chtc.wisc.edu:/scratch/<USERNAME>/<WORKING_DIR>`.
-   Alongside the FASTQs, We also include a CSV samplesheet that is required as the input for `viralrecon`. This samplesheet must have the following column headers representing the sample identifier, the "R1" FASTQ, and the associated "R2" FASTQ for each sample"

```csv
sample,fastq_1,fastq_2
```

-   Finally, we transferred the BED-formatted file of primer coordinates that is included in the repo `viralrecon_setup` directory.

### Software Setup

### Software Setup

Separately, we also installed `nextflow` and `singularity` in the user's home directory using `conda`. To set up `conda` on a cluster yourself, we recommend following [the official instructions here](https://docs.anaconda.com/miniconda/#quick-command-line-install). In short, download the `miniconda3` installer with:

```bash
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh
```

Then, initialize `conda` with:

```bash
~/miniconda3/bin/conda init bash
```

Make conda available in the command line with:

```bash
echo 'export PATH=$PATH:~/miniconda3/bin' >> ~/.bashrc
```

And finally, use `conda` to install `nextflow` and `singularity`:

```bash
conda install -c bioconda nextflow singularity
```

### `viralrecon` configuration

Being a Nextflow pipeline, `viralrecon` makes heavy use of configuration files. To configure `viralrecon` to run via the slurm scheduler, we used the following configuration file:

```groovy
process {

	// container/environment settings
	singularity.enabled = true
	singularity.cacheDir = "work/singularity/"

	// slurm job settings
	executor = "slurm"
	clusterOptions = "--partition=shared"
	memory = '64 GB'

	// lower iVar threshold settings to retain more low-frequency variants
	withName: 'IVAR_VARIANTS' {
		ext.args = '-t 0.01 -q 20 -m 100'
	}

}
```

This file is also available as `slurm.config` in the repo `viralrecon_setup` directory. Overall, the config file enables the Singularity container engine instead of the default Docker engine, sets the `executor` to Slurm, tells the CHTC cluster to use its shared resources partition, and requests 64 gigabytes of RAM per individual task. We also lower the default variant frequency threshold for the pipeline's variant-caller.

Finally, to run the pipeline on all of the assembled input, we use the following command for Illumina reads:

```bash
nextflow run . \
-config viralrecon-hpc.config \ # <———— USER-PROVIDED FILE
-profile singularity \
--input <SAMPLESHEET_NAME>.csv \ # <———— USER-PROVIDED FILE
--outdir results \
--platform illumina \
--protocol amplicon \
--genome 'MN908947.3' \
--primer_bed DIRECTwithBoosterAprimersfinal.bed \ # <———— USER-PROVIDED FILE
--primer_left_suffix '_LEFT' \
--primer_right_suffix '_RIGHT' \
--skip_assembly
```

And the following for Nanopore reads:

```bash
nextflow run . \
-c run_configs/29759/viralrecon-hpc.config
--input <SAMPLESHEET_NAME>.csv \ # <———— USER-PROVIDED FILE
--outdir results \
--platform nanopore \
--genome 'MN908947.3' \
--primer_set_version 1200 \ # <———— USER-PROVIDED SETTING FOR THE MIDNIGHT PRIMER SET
--fastq_dir <FASTQ_DIR>/ \ # <———— USER-PROVIDED FOLDER
--artic_minion_caller medaka \
--artic_minion_medaka_model r941_min_high_g360 \
```

Note, as per [the `viralrecon` documentation](https://nf-co.re/viralrecon/2.6.0/docs/usage/#samplesheet-format), that the Nanopore samplesheet format is a bit different, e.g.:

```csv
sample,barcode
21X983255,1
70H209408,2
49Y807476,3
70N209581,4
```

## Setup on local Apple Mac Studio Desktop

All the above steps were broadly similar for setup on a Mac Desktop, with a few exceptions:

1. Configuration was much simpler; see the file `mac_studio.config`:

```groovy
process {

	// lower iVar threshold settings to retain more low-frequency variants
	withName: 'IVAR_VARIANTS' {
		ext.args = '-t 0.01 -q 20 -m 100'
	}

}
```

2. We use the Docker container engine instead of Singularity, which must be manually installed on the Desktop.
3. More transferring of input files was performed by hand in the Finder file explorer instead of with the `rsync` command line utility.
4. Only Illumina reads were processed locally.

As such, our `viralrecon` run commands on the Mac Studio looked as follows:

```bash
nextflow run . \
--input <SAMPLESHEET_NAME>.csv \ # <———— USER-PROVIDED FILE
--outdir results \
--platform illumina \
--protocol amplicon \
--genome 'MN908947.3' \
--primer_bed DIRECTwithBoosterAprimersfinal.bed \ # <———— USER-PROVIDED FILE
--primer_left_suffix '_LEFT' \
--primer_right_suffix '_RIGHT' \
--skip_assembly
```
