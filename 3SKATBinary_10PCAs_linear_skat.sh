#!/bin/bash 
#SBATCH --job-name=SKATBinary_n10PCAs_linear_skat
#SBATCH --mail-type=ALL 
#SBATCH --mail-user=17yz85@queensu.ca 
#SBATCH --account=con-hpcg1553 
#SBATCH --partition=reserved 
#SBATCH -c 8 
#SBATCH --mem 256g 
#SBATCH -t 2-00:00:00 
#SBATCH -o ./logs/%j-%N-%x.out 
#SBATCH -e ./logs/%j-%N-%x.err 

job_name="SKATBinary_10PCAs_linear_skat_adjustedbeta" 

echo "job ${job_name} started at "$(date) 
time1=$(date +%s)

module load StdEnv/2020
which R

#Rscript SKATbinary_noPCAs_linear_skat.R
R CMD BATCH 3SKATbinary_10PCAs_linear_skat.R

time2=$(date +%s)
echo "job ${job_name} ended at "$(date) 
echo "job took $(((time2-time1)/60)) minutes $(((time2-time1)%60)) seconds"
