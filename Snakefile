import pandas as pd

rule all:
    input:
        expand("data/vcf/{id}.vcf", id=pd.read_csv("data/prior_parameters.csv")['ID'].tolist())

def get_params(wildcards):
    # Load parameters and ensure ID is read as integer
    parameters = pd.read_csv("data/prior_parameters.csv")
    print("Data types in the dataframe:", parameters.dtypes)  # Debug: Check data types
    print("Sample data:", parameters.head())  # Debug: Check first few rows

    # Convert ID in wildcards to integer if necessary
    target_id = int(wildcards.id)
    print("Looking for ID:", target_id)  # Debug: Output the ID being searched

    # Filter for the matching ID
    filtered_params = parameters.loc[parameters['ID'] == target_id]
    if filtered_params.empty:
        raise ValueError(f"No parameters found for ID {target_id}")
    return filtered_params.to_dict('records')[0]

rule run_slim:
    input:
        params="data/prior_parameters.csv"
    output:
        vcf="data/vcf/{id}.vcf"
    shell:
        """
        params=$(awk -F, '$1 == "{wildcards.id}" {{print $0}}' {input.params})
        ID=$(echo $params | cut -d, -f1)
        gmu=$(echo $params | cut -d, -f2)
        imu=$(echo $params | cut -d, -f3)
        gd=$(echo $params | cut -d, -f4)
        igd=$(echo $params | cut -d, -f5)
        gdfe=$(echo $params | cut -d, -f6)
        idfe=$(echo $params | cut -d, -f7)
        
        mkdir -p data/vcf
        slim -d "ID=$ID" -d "gmu=$gmu" -d "imu=$imu" -d "gd=$gd" \
             -d "igd=$igd" -d "gdfe=$gdfe" -d "idfe=$idfe" /scripts/ABC.slim > {output.vcf}
        """
