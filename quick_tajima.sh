#!/bin/bash

# Directory containing VCF files
VCF_DIR="data/vcf"

# Output directory for Tajima's D results
OUTPUT_DIR="data/tajima"

# Create the output directory if it doesn't already exist
mkdir -p ${OUTPUT_DIR}

# Export variables to be available in the parallel environment
export VCF_DIR OUTPUT_DIR

# Use parallel to run vcftools for each VCF file
parallel --jobs 0 --env VCF_DIR,OUTPUT_DIR 'vcftools --vcf {} --out ${OUTPUT_DIR}/$(basename {} .vcf) --TajimaD 100' ::: ${VCF_DIR}/*.vcf