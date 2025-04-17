import pandas as pd

# Load the parameter CSV file
params_file = config["param_file"]
params = pd.read_csv(params_file)
params['ID'] = params['ID'].astype(int)

rule all:
    input:
        expand("data/vcf/{ID}.vcf", ID=params['ID'])


rule run_slim_simulation:
    output:
        sim_output="data/vcf/{ID}.vcf"
    params:
        # Extract parameters by ID
        gmu = lambda wwildcardsc: params.loc[params['ID'] == int(wildcards.ID), 'gmu'].values[0],
        imu = lambda wildcards: params.loc[params['ID'] == int(wildcards.ID), 'imu'].values[0],
        gd = lambda wildcards: params.loc[params['ID'] == int(wildcards.ID), 'gd'].values[0],
        id = lambda wildcards: params.loc[params['ID'] == int(wildcards.ID), 'id'].values[0],
        gdfe = lambda wildcards: params.loc[params['ID'] == int(wildcards.ID), 'gdfe'].values[0],
        idfe = lambda wildcards: params.loc[params['ID'] == int(wildcards.ID), 'idfe'].values[0],

    shell:
        """
        slim -d ID={wildcards.ID} -d gmu={params.gmu(wildcards)} -d imu={params.imu(wildcards)} \
        -d gd={params.gd(wildcards)} -d id={params.id(wildcards)} -d gdfe={params.gdfe(wildcards)} \
        -d idfe={params.idfe(wildcards)} \
        {slim_script} > {output.sim_output}
        """
