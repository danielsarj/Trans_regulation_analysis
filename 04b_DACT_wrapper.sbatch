#!/bin/sh
#SBATCH --time=36:00:00
#SBATCH --mem=8G
#SBATCH --job-name subDACT
#SBATCH --output subDACT.out
#SBATCH --error subDACT.err
#SBATCH --partition=caslake
#SBATCH --account=pi-xuanyao

cd /project/xuanyao/daniel/Trans_regulation_analysis
bash 04a_submit_DACT.sh
