# Whole-genome sequencing pipeline

Pipeline for the alignment, variant calling, copy number calling and annotation of whole-genome sequencing data, built on top of the [sarek](https://nf-co.re/sarek/3.2.3) Nextflow pipeline. Please refer to its documentation for details.

# Usage
```
run_wgs_pipeline.sh [-g|--genome <arg>] [-h|--help] [--version] <samplesheet> <outdir>
    <samplesheet>: path to the samplesheet CSV file
    <outdir>: path to the output directory where to store the results
    -g, --genome: genome to be used (default: 'GATK.GRCh37')
    -h, --help: Prints help
    --version: Prints version
```
where 
- `samplesheet` is a CSV file
- `outdir` is the path where the results will be stored
- `genome` is the reference genome to be used

For example:
```
run_wgs_pipeline.sh --genome GRCm38 design.csv wgs
```
will run the pipeline on the samples specified in the `design.csv` file, will store the results in the `wgs` folder, and will align the reads to the `GRCm38` genome.

## Structure of the sample sheet

Check the [sarek documentation about the required input](https://nf-co.re/sarek/3.2.3/docs/usage#overview-samplesheet-columns).

An example input file is provided: [test_input.csv](./test_input.csv).

## Available genomes
### Homo sapiens
- GATK.GRCh37 (from Broad Institute)
### Mus musculus
- GRCm38 (from Ensembl)