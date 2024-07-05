def get_ids_from_csv():
    with open('/data/prior_parameters.csv') as f:
        lines = f.read().strip().split('\n')[1:]
    return [line.split(',')[0] for line in lines]

def get_vcf_files():
    ids = get_ids_from_csv()
    return expand("data/vcf/{id}.vcf", id=ids)

rule all:
    input:
        get_vcf_files

rule generate_parameters:
    output:
        csv="/data/prior_parameters.csv"
    shell:
        """
        Rscript /scripts/generate_params.R
        """

rule run_simulation:
    input:
        params="/data/prior_parameters.csv"
    output:
        vcf="/data/vcf/{id}.vcf"
    shell:
        """
        # Extract parameters for the specific simulation ID
        params=$(awk -F, '$1 == "{wildcards.id}" {{print $0}}' {input.params})
        
        ID=$(echo $params | cut -d, -f1)
        gmu=$(echo $params | cut -d, -f2)
        imu=$(echo $params | cut -d, -f3)
        gd=$(echo $params | cut -d, -f4)
        id=$(echo $params | cut -d, -f5)
        gdfe=$(echo $params | cut -d, -f6)
        idfe=$(echo $params | cut -d, -f7)
        
        # Execute SLiM simulation with the extracted parameters
        slim -d "ID=${ID}" -d "gmu=${gmu}" -d "imu=${imu}" -d "gd=${gd}" -d "igd=${id}" -d "gdfe=${gdfe}" -d "idfe=${idfe}" /scripts/ABC.slim
        """