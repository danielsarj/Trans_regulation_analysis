#!/bin/bash

# path to genes file
TSV_FILE="/project/xuanyao/daniel/DACT_analysis/genes_w_topeQTL.txt"

# column number containing gene names
GENE_COLUMN=4

# log file to keep track of submitted genes
LOG_FILE="/project/xuanyao/daniel/DACT_analysis/DACT_submitted_genes.log"

# function to count currently running jobs
count_running_jobs() {
    squeue -u $USER | grep " caslake " | wc -l
}

# initialize the log file if it doesn't exist
if [ ! -f $LOG_FILE ]; then
    touch $LOG_FILE
fi

# read the TSV file and process each gene name
awk -v col=$GENE_COLUMN 'NR > 1 {print $col}' $TSV_FILE | while read -r GENE; do
    # check if the gene has already been processed
    if grep -q "^$GENE$" $LOG_FILE; then
        echo "Job for gene $GENE has already been submitted. Skipping..."
        continue
    fi

    # check the number of running jobs and wait if it's 100 or more
    while [ $(count_running_jobs) -ge 100 ]; do
        echo "Waiting for jobs to finish. Currently running: $(count_running_jobs)"
        sleep 600  # wait for 10 minutes before checking again
    done

    # submit the job using batch
    sbatch <<-EOF
#!/bin/sh
#SBATCH --time=36:00:00
#SBATCH --mem=100G
#SBATCH --job-name subDACT
#SBATCH --output subDACT.out
#SBATCH --error subDACT.err
#SBATCH --partition=caslake
#SBATCH --account=pi-xuanyao
module load R
cd /project/xuanyao/daniel/Trans_regulation_analysis
Rscript 03_DACT_per_gene.R -g $GENE
EOF

    echo "Submitted job for gene: $GENE"

    # log the submitted gene
    echo $GENE >> $LOG_FILE
done
