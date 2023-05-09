#!/bin/bash
#SBATCH --job-name=plink_MAF
#SBATCH --mail-type=ALL
#SBATCH --mail-user=17yz85@queensu.ca 
#SBATCH -o plink_MAF.out
#SBATCH --account=con-hpcg1553 
#SBATCH --partition=reserved 
#SBATCH --mem=32gb
#SBATCH -t 1-00:00:00

job_name = "PLINK_MAF"

echo "job ${job_name} started at "$(date) 
time1=$(date +%s)

module load nixpkgs/16.09
module load plink/1.9b_5.2-x86_64

### PLINK PREPROCESSING ###############################################
printf "getting the files for MAF through PLINK... \n"
plink --bfile /global/project/hpcg1553/Child_imputation_2018/Michigan/CHILD_only/merged_child_only_updated_rsid_update_sex1 \
	--freq \
	--out /global/project/hpcg1553/Yang/ESNA/Shrey/FinalCode/GWAS/outputs/gwas_MAF 




time2=$(date +%s)
secs=$((time2-time1))
printf "job ${job_name} ended at "$(date)
printf 'job took %dd:%dh:%dm:%ds\n' $(($secs/86400)) $(($secs%86400/3600)) $(($secs%3600/60)) $(($secs%60)) 
