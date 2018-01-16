#!/bin/bash
# determine_quality_distribution 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://wiki.dnanexus.com/Developer-Portal for tutorials on how
# to modify this file.

main() {

    echo "Value of reads: '$reads'"
    echo "Value of read_mates: '$read_mates'"

    set -x
    
    mkfifo reads.R1.fastq
    mkfifo reads.R2.fastq

    dx download "$reads" -o - | zcat > reads.R1.fastq &
    dx download "$read_mates" -o - | zcat > reads.R2.fastq &

    python /get_quality_distribution.py --reads reads.R1.fastq  --mates reads.R2.fastq --output-mean-file mean.txt --output-stdev-file stdev.txt --output-coverage-file coverage.txt

    mean_pair_qualities=$(cat mean.txt)
    standard_deviation_pair_qualities=$(cat stdev.txt)
    coverage=$(cat coverage.txt)

    dx-jobutil-add-output mean_pair_qualities "$mean_pair_qualities" --class=float
    dx-jobutil-add-output standard_deviation_pair_qualities "$standard_deviation_pair_qualities" --class=float
    dx-jobutil-add-output coverage "$coverage" --class=float
}
