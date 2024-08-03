#!/bin/bash

# Path to your TSV file
TSV_FILE="/project/xuanyao/daniel/DACT_analysis/genes_w_topeQTL.txt"

# Column number containing gene names (1-based index)
GENE_COLUMN=4

# Log file to keep track of submitted genes
LOG_FILE="/project/xuanyao/daniel/DACT_analysis/DACT_submitted_genes.log"

# Function to count currently running jobs
count_running_jobs() {
    squeue -u $USER | grep " caslake " | wc -l
}

# Initialize the log file if it doesn't exist
if [ ! -f $LOG_FILE ]; then
    touch $LOG_FILE
fi

# Read the TSV file and process each gene name
awk -v col=$GENE_COLUMN 'NR > 1 {print $col}' $TSV_FILE | while read -r GENE; do
    # Check if the gene has already been processed
    if grep -q "^$GENE$" $LOG_FILE; then
        echo "Job for gene $GENE has already been submitted. Skipping..."
        continue
    fi
    
    # Check the number of running jobs and wait if it's 100 or more
    while [ $(count_running_jobs) -ge 100 ]; do
        echo "Waiting for jobs to finish. Currently running: $(count_running_jobs)"
        sleep 600  # Wait for 10 seconds before checking again
    done
      
    # Submit the job using batch
    sbatch <<-EOF
#!/bin/sh
#SBATCH --time=36:00:00
#SBATCH --mem=8G
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

    # Log the submitted gene
    echo $GENE >> $LOG_FILE
done