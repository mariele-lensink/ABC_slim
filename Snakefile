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
        expand("data/vcf/{ID}.vcf", ID=all_ids),
        expand("data/tajima/{ID}.Tajima.D", ID=all_ids) 

rule run_slim_simulation:
    input:
        param_file = params_file
    output:
        sim_output = "data/vcf/{ID}.vcf"
    log: "logs/{ID}.log"
    run:
        import pandas as pd
        import os 

        params = pd.read_csv(input.param_file)
        row = params.loc[params["ID"].astype(str) == str(wildcards.ID)].squeeze()
        id_int = int(row.ID)

        try:
            shell(f"""
                slim -d ID={id_int} -d gmu={row.gmu} -d imu={row.imu} \
                  -d gd={row.gd} -d id={row.id} -d gdfe={row.gdfe} -d idfe={row.idfe} \
                   /home/mlensink/slimsimulations/ABCslim/ABC_slim/scripts/ABC.slim > {log}
            """)
            if not os.path.exists(output.sim_output):
                raise RuntimeError("SLiM did not produce output VCF")
        except:
            with open("failed_ids.txt", "a") as f:
                f.write(f"{wildcards.ID}\n")

rule run_tajima:
    input:
        vcf_file="data/vcf/{ID}.vcf"
    output:
        tajima_output="data/tajima/{ID}.Tajima.D"
    params:
        out_prefix=lambda wildcards: f"data/tajima/{wildcards.ID}"
    run:
        import os
        if not os.path.exists(input.vcf_file):
            print(f"Skipping {input.vcf_file}: file does not exist.")
        else:
            shell("""
                vcftools --vcf {input.vcf_file} --out {params.out_prefix} --TajimaD 100
            """)