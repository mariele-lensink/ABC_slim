import pandas as pd

rule all:
    input:
        expand("data/vcf/{id}.vcf", id=pd.read_csv("data/prior_parameters.csv")['ID'].tolist())

def get_params(wildcards):
    # Load parameters and ensure ID is read as integer
    parameters = pd.read_csv("prior_parameters.csv")
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
    params:
        lambda wildcards: get_params(wildcards)
    shell:
        """
        mkdir -p data/vcf
        slim -d "ID={params[ID]}" -d "gmu={params[gmu]}" -d "imu={params[imu]}" -d "gd={params[gd]}" \
             -d "igd={params[id]}" -d "gdfe={params[gdfe]}" -d "idfe={params[idfe]}" /scripts/ABC.slim
        """
