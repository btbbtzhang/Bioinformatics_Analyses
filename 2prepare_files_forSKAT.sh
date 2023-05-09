#!/bin/sh 
#SBATCH --job-name=preprocessing_genome_wide
#SBATCH --mail-type=ALL 
#SBATCH --mail-user=17yz85@queensu.ca 
#SBATCH --account=con-hpcg1553 
#SBATCH --partition=reserved  
#SBATCH --mem 266g
#SBATCH -t 1-10:00:00 
#SBATCH -e ./logs/%j-%N-%x.err 
#SBATCH -o ./logs/%j-%N-%x.out 

module load plink/1.9b_5.2-x86_64

### SET PARAMETERS ####################################################
job_name="preprocessing_genome_wide_forSKAT" 
printf "job ${job_name} started at $(date) \n"
time1=$(date +%s)

cond_job_log_fname="./outputs/${job_name}_byPLINK_log.txt"

# static directories
CHILD_raw_data_dir="/global/project/hpcg1553/Child_imputation_2018/Michigan/CHILD_only/"
GLIDE_dir="/global/project/hpcg1553/CHILD_glide/GLIDE_dir/"
prep_output_dir="/global/project/hpcg1553/Yang/ESNA/Shrey/FinalCode/SKAT/outputs/"
plink_fname="merged_child_only_updated_rsid_update_sex1_maf001"
pheno_dir="/global/project/hpcg1553/Yang/ESNA/Shrey/glide/outputs/"
pheno_fname="pheno_yang2022_recoded"


### PLINK PREPROCESSING ###############################################
printf "getting the files for SKAT through PLINK... \n" | tee -a ${cond_job_log_fname}
plink --bfile ${CHILD_raw_data_dir}${plink_fname} \
      --allow-no-sex \
      --pheno ${pheno_dir}${pheno_fname} \
      --pheno-name RecurrentWheeze \
      --make-bed \
      --out ${prep_output_dir}${plink_fname}"_filesforSKAT"


time2=$(date +%s)
secs=$((time2-time1))
printf "job ${job_name} ended at "$(date)
printf 'job took %dd:%dh:%dm:%ds\n' $(($secs/86400)) $(($secs%86400/3600)) $(($secs%3600/60)) $(($secs%60)) | tee -a ${cond_job_log_fname}
