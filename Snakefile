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
    log:
        "logs/slim/{ID}.log"
    resources:
       # mem_mb = 16000  # optional, if you later switch to cluster mode
        #restart_times: 1
    run:
        import pandas as pd
        import os

        params = pd.read_csv(input.param_file)
        row = params.loc[params["ID"] == int(wildcards.ID)].squeeze()
        scratch_dir = f"/scratch/mlensink/{os.environ['SLURM_JOB_ID']}"
        os.makedirs(scratch_dir, exist_ok=True)
        scratch_vcf = os.path.join(scratch_dir, f"{wildcards.ID}.vcf")

        shell(f"""
            slim -d ID={wildcards.ID} \
                 -d gmu={row.gmu} \
                 -d imu={row.imu} \
                 -d gd={row.gd} \
                 -d id={row.id} \
                 -d gdfe={row.gdfe} \
                 -d idfe={row.idfe} \
                 -d 'OUT="{scratch_vcf}"' \
                 /home/mlensink/slimsimulations/ABCslim/ABC_slim/scripts/ABC.slim > {log} 2>&1

            cp {scratch_vcf} {output.sim_output}
            rm -f {scratch_vcf}
        """)

        # Check if output was produced
        if not os.path.exists(output.sim_output):
            # Optional: mark this job as failed
            with open(f"logs/failed/{wildcards.ID}.fail", "w") as f:
                f.write("SLiM failed to produce output.\n")
            raise ValueError(f"SLiM failed for ID {wildcards.ID}")

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