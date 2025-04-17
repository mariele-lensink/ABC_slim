import pandas as pd

configfile:"config.yaml"
# Define the parameter file path from config
params_file = config["param_file"]

##for unlock issues
##all_params = pd.read_csv("data/prior_parameters_april9.csv")
##params_file = pd.read_csv("data/prior_parameters_april9.csv")

# Load all the IDs
all_params = pd.read_csv(params_file)
all_params["ID"] = all_params["ID"].astype(int)
all_ids = all_params["ID"].tolist()

slim_script = config["slim_script"]


rule all:
    input:
        expand("data/vcf/{ID}.vcf", ID=all_ids)

rule run_slim_simulation:
    input:
        param_file = params_file
    output:
        sim_output = "data/vcf/{ID}.vcf"
    params:
        output_vcf = lambda wildcards: f"data/vcf/{wildcards.ID}.vcf"
    run:
        import pandas as pd
        params = pd.read_csv(input.param_file)
        row = params.loc[params["ID"] == int(wildcards.ID)].squeeze()

        shell("""
            slim -d ID={row.ID} -d gmu={row.gmu} -d imu={row.imu} \
                 -d gd={row.gd} -d id={row.id} -d gdfe={row.gdfe} -d idfe={row.idfe} \
                  /home/mlensink/slimsimulations/ABCslim/ABC_slim/scripts/ABC.slim > {output.sim_output}
        """)
