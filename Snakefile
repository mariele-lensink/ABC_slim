import os
import pandas as pd

# Ensure the directory exists before running the main rules
if not os.path.exists("data/vcf/"):
    os.makedirs("data/vcf/")

rule all:
    input:
        expand("data/vcf/{id}.vcf", id=pd.read_csv("data/prior_parameters.csv")['ID'].tolist())

def get_params(wildcards):
    # Load parameters and ensure ID is read as integer
    parameters = pd.read_csv("data/prior_parameters.csv")
    # Convert ID in wildcards to integer if necessary
    target_id = int(wildcards.id)
    print("Looking for ID:", target_id)  # Debug: Output the ID being searched

rule run_slim:
    input:
        params="data/prior_parameters.csv"
    output:
        vcf="data/vcf/{id}.vcf"
    shell:
        """
        mkdir -p data/vcf/
        params=$(awk -F, '$1 == "{wildcards.id}" {{print $0}}' {input.params})
        ID=$(echo $params | cut -d, -f1)
        gmu=$(echo $params | cut -d, -f2)
        imu=$(echo $params | cut -d, -f3)
        gd=$(echo $params | cut -d, -f4)
        igd=$(echo $params | cut -d, -f5)
        gdfe=$(echo $params | cut -d, -f6)
        idfe=$(echo $params | cut -d, -f7)
        
        echo "Running SLiM simulation for ID: $ID"
        echo "Command: slim -d \"ID=$ID\" -d \"gmu=$gmu\" -d \"imu=$imu\" -d \"gd=$gd\" -d \"igd=$igd\" -d \"gdfe=$gdfe\" -d \"idfe=$idfe\" /scripts/ABC.slim"
        
        slim -d "ID=$ID" -d "gmu=$gmu" -d "imu=$imu" -d "gd=$gd" -d "igd=$igd" -d "gdfe=$gdfe" -d "idfe=$idfe" /scripts/ABC.slim > {output.vcf}
        """

