import pandas as pd

configfile:"config.yaml"
# Define the parameter file path from config
params_file = config["param_file"]

# Load all the IDs
all_params = pd.read_csv(params_file)
all_params["ID"] = all_params["ID"].astype(int)
all_ids = all_params["ID"].tolist()

rule all:
    input:
        #expand("data/vcf/{ID}.vcf", ID=all_ids),
        expand("data/tajima/{ID}.Tajima.D", ID=all_ids) 

rule run_slim_simulation:
    input:
        param_file = params_file
    output:
        sim_output = "data/vcf/{ID}.vcf"
    log: "logs/{ID}.log"
    run:
        import pandas as pd
        params = pd.read_csv(input.param_file)
        row = params.loc[params["ID"] == int(wildcards.ID)].squeeze()
        id_int = int(row.ID)

        shell(f"""
            slim -d ID={id_int} -d gmu={row.gmu} -d imu={row.imu} \
                 -d gd={row.gd} -d id={row.id} -d gdfe={row.gdfe} -d idfe={row.idfe} \
                  /home/mlensink/slimsimulations/ABCslim/ABC_slim/scripts/ABC.slim > {log}
        """)
rule run_tajima:
    input:
        vcf_file="data/vcf/{ID}.vcf"
    output:
        tajima_output="data/tajima/{ID}.Tajima.D"
    shell:
        """
        vcftools --vcf {input.vcf_file} --out {output.tajima_output} --TajimaD 100
        """