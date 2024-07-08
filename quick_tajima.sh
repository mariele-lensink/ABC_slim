#!/bin/bash

# Directory containing VCF files
VCF_DIR="data/vcf"

# Output directory for Tajima's D results
OUTPUT_DIR="data/tajima"

# Create the output directory if it doesn't already exist
mkdir -p ${OUTPUT_DIR}

# Loop through each VCF file in the directory
for vcf_file in ${VCF_DIR}/*.vcf; do
    # Extract the ID from the filename
    ID=$(basename ${vcf_file} .vcf)

    # Run vcftools to calculate Tajima's D
    vcftools --vcf ${vcf_file} --out ${OUTPUT_DIR}/${ID} --TajimaD 100
done
