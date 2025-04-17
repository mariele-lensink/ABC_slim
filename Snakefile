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
        gmu = lambda wc: params.loc[params['ID'] == int(wc.ID), 'gmu'].values[0],
        imu = lambda wc: params.loc[params['ID'] == int(wc.ID), 'imu'].values[0],
        gd = lambda wc: params.loc[params['ID'] == int(wc.ID), 'gd'].values[0],
        id = lambda wc: params.loc[params['ID'] == int(wc.ID), 'id'].values[0],
        gdfe = lambda wc: params.loc[params['ID'] == int(wc.ID), 'gdfe'].values[0],
        idfe = lambda wc: params.loc[params['ID'] == int(wc.ID), 'idfe'].values[0],
        # Dynamic output filename creation
        output_vcf = lambda wildcards: f"data/vcf/{wildcards.ID}.vcf"
    shell:
        """
        slim -d ID={wildcards.ID} -d gmu={params.gmu} -d imu={params.imu} \
        -d gd={params.gd} -d id={params.id} -d gdfe={params.gdfe} -d idfe={params.idfe} \
        {slim_script} > {params.output_vcf}
        """
