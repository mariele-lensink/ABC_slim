import pandas as pd

rule all:
    input:
        expand("data/vcf/{id}.vcf", id=pd.read_csv("data/prior_parameters.csv")['ID'].tolist())

def get_params(wildcards):
    parameters = pd.read_csv("data/prior_parameters.csv")
    params = parameters.loc[parameters['ID'] == wildcards.id].to_dict('records')[0]
    return params

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
