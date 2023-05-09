#!/bin/bash
#SBATCH --job-name=plink_recurrent_wheeze
#SBATCH --mail-type=ALL
#SBATCH --mail-user=17yz85@queensu.ca 
#SBATCH -o gwas_recurrentWheeze.out
#SBATCH --account=con-hpcg1553 
#SBATCH --partition=reserved 
#SBATCH -c 2
#SBATCH --mem=32gb
#SBATCH -t 1-00:00:00

job_name = "GWAS_recurrent_wheeze"

echo "job ${job_name} started at "$(date) 
time1=$(date +%s)

module load nixpkgs/16.09
module load plink/1.9b_5.2-x86_64

### PLINK PREPROCESSING ###############################################
printf "getting the files for GWAS through PLINK... \n"
plink --bfile /global/project/hpcg1553/Child_imputation_2018/Michigan/CHILD_only/merged_child_only_updated_rsid_update_sex1 \
	--logistic hide-covar \
	--covar /global/project/hpcg1553/dysynapsies/covariates_pcs_sex_child_only.txt \
	--maf 0.01 \
	--out /global/project/hpcg1553/Yang/ESNA/Shrey/FinalCode/GWAS/outputs/gwas_recurrent_wheeze \
	--pheno /global/project/hpcg1553/Yang/ESNA/Shrey/glide/outputs/pheno_yang2022_recoded \
	--pheno-name RecurrentWheeze \
	--ci 0.95 \
	--threads 2




time2=$(date +%s)
secs=$((time2-time1))
printf "job ${job_name} ended at "$(date)
printf 'job took %dd:%dh:%dm:%ds\n' $(($secs/86400)) $(($secs%86400/3600)) $(($secs%3600/60)) $(($secs%60)) 
