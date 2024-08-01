#mamba activate snakemake
import os
import time
import subprocess
import pandas as pd

# function to count the number of running jobs
def count_running_jobs():
    result = subprocess.check_output(['squeue', '-u', 'daraujo'])
    return len(result.splitlines())-1  #subtract the header line

# function to submit jobs
def submit_jobs():
    max_jobs = 100
    submitted_jobs = 0

    while submitted_jobs < len(genes_ls):
        running_jobs = count_running_jobs()
        available_slots = max_jobs - running_jobs
        
        if available_slots > 0:
            for i in range(min(available_slots, len(genes_ls) - submitted_jobs)):
                gene = genes_ls[submitted_jobs]
                job_name = f'{gene}_job'
                cmd = f"sbatch --time=36:00:00 --mem=120G --partition=caslake --account=pi-xuanyao --wrap='snakemake /project/xuanyao/daniel/DACT_analysis/DACT_results/LDL_{gene}.txt --cores 1' --job-name={job_name}"
                subprocess.call(cmd, shell=True)
                submitted_jobs += 1
                print(f'Submitted job for {gene}')
        
        # wait before checking again
        time.sleep(600)

# get gene list
genes_ls = pd.read_csv('/project/xuanyao/daniel/DACT_analysis/genes_w_topeQTL.txt', sep=' ')['gene_name'].tolist()

# rule to control the job submission
rule all:
    input:
        expand('/project/xuanyao/daniel/DACT_analysis/DACT_results/LDL_{gene}.txt', gene=genes_ls)

# rule to perform the analysis on a single gene
rule analyze_gene:
    input:
        script = '/project/xuanyao/daniel/Trans_regulation_analysis/03_DACT_per_gene.R'
    output:
        '/project/xuanyao/daniel/DACT_analysis/DACT_results/LDL_{gene}.txt'
    params:
        gene = '{gene}'
    shell:
        'module load R && Rscript {input.script} -g {params.gene}'

if __name__ == "__main__":
    submit_jobs()