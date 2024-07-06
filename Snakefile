import pandas as pd

# Load the parameter CSV file
params = pd.read_csv("data/prior_parameters.csv")

# Function to create output filenames
def create_output(wildcards):
    return "data/vcf/"str(wildcards.ID) + ".vcf"

rule all:
    input:
        expand("data/vcf/{ID}.vcf", ID=params['ID'])

rule run_slim_simulation:
    output:
        sim_output = create_output
    params:
        # Extract parameters by ID
        gmu = lambda wildcards: params.loc[params['ID'] == int(wildcards.ID), 'gmu'].values[0],
        imu = lambda wildcards: params.loc[params['ID'] == int(wildcards.ID), 'imu'].values[0],
        gd = lambda wildcards: params.loc[params['ID'] == int(wildcards.ID), 'gd'].values[0],
        id = lambda wildcards: params.loc[params['ID'] == int(wildcards.ID), 'id'].values[0],
        gdfe = lambda wildcards: params.loc[params['ID'] == int(wildcards.ID), 'gdfe'].values[0],
        idfe = lambda wildcards: params.loc[params['ID'] == int(wildcards.ID), 'idfe'].values[0]
    shell:
        """
        slim -d ID={wildcards.ID} -d gmu={params.gmu} -d imu={params.imu} \
        -d gd={params.gd} -d id={params.id} -d gdfe={params.gdfe} -d idfe={params.idfe} /scripts/ABC.slim > {output.sim_output}
        """
