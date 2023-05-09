#!/bin/sh 
#SBATCH --job-name=preprocessing_genome_wide
#SBATCH --mail-type=ALL 
#SBATCH --mail-user=17yz85@queensu.ca 
#SBATCH --account=con-hpcg1553 
#SBATCH --partition=reserved  
#SBATCH --mem 256g 
#SBATCH -t 1-10:00:00 
#SBATCH -e ./logs/%j-%N-%x.err 
#SBATCH -o ./logs/%j-%N-%x.out 

module load plink/1.9b_5.2-x86_64
module load python/3.7.4

################### Running on the platform of Centre for Advanced Computing (CAC): username@login.cac.queensu.ca
### SET PARAMETERS ####################################################
job_name="preprocessing_genome_wide" 
printf "job ${job_name} started at $(date) \n"
time1=$(date +%s)

# change LD pruning r^2 value
rsq="6"

# record a condensed job log
cond_job_log_fname="./outputs/${job_name}_LDr0${rsq}_log.txt"
printf "${job_name}_r0${rsq}_log \n" > ${cond_job_log_fname}
printf "LD pruning r^2 = 0.${rsq} \n\n" | tee -a ${cond_job_log_fname}

# static directories
CHILD_raw_data_dir="/global/project/hpcg1553/QC_GWAS/transfer_central/preprocessed/MAF005/"
GLIDE_dir="/global/project/hpcg1553/CHILD_glide/GLIDE_dir/"
prep_output_dir="/global/project/hpcg1553/Yang/ESNA/Shrey/glide/outputs/"

plink_fname="child_only_qced_maf005_filtered"

### PLINK PREPROCESSING ###############################################
printf "generate LD pruning files... \n" | tee -a ${cond_job_log_fname}
plink --bfile ${CHILD_raw_data_dir}${plink_fname} \
      --indep-pairwise 250 5 0.${rsq} \
      --out ${prep_output_dir}${plink_fname}"_w250s5r0"${rsq}

printf "extracting pruned in SNPs and output plink files... \n" | tee -a ${cond_job_log_fname}
plink --bfile ${CHILD_raw_data_dir}${plink_fname} \
      --extract ${prep_output_dir}${plink_fname}"_w250s5r0"${rsq}".prune.in" \
      --make-bed \
      --out ${prep_output_dir}${plink_fname}"_prunedInLD0"${rsq}


printf "add phenotype... remove individuals with missing phenotype... \n" | tee -a ${cond_job_log_fname}
pheno_fname="pheno_yang2022_recoded"
plink --bfile ${prep_output_dir}${plink_fname}"_prunedInLD0"${rsq} \
      --allow-no-sex \
      --pheno ${prep_output_dir}${pheno_fname} \
      --pheno-name RecurrentWheeze \
      --prune \
      --make-bed \
      --out ${prep_output_dir}${plink_fname}"_prunedInLD0"${rsq}"_phenoAdded_noMissings"


### CONVERT PLINK --> GLIDEinput #######################################
printf "convert plink to GLIDE input files... \n" | tee -a ${cond_job_log_fname}
plink_final_fname="${plink_fname}_prunedInLD0"${rsq}"_phenoAdded_noMissings"
python ${GLIDE_dir}GLIDE_plink2glide_py3.py ${prep_output_dir}${plink_final_fname}

# remove minor allele at end of SNP rsIDs
printf "remove minor allele at end of SNP rsIDs... \n\n" | tee -a ${cond_job_log_fname}
snpNames_fname="${plink_final_fname}.snpNames"
snpNames_NoMA_fname="${snpNames_fname}NoMA"
sed 's/..$//' ${prep_output_dir}${snpNames_fname} > ${prep_output_dir}${snpNames_NoMA_fname}

# add missing newline after last SNP
printf "\n" >> ${prep_output_dir}${snpNames_NoMA_fname}


### COUNT nSUBJ AND nSNPS #############################################
nsubj="$(wc -l ${prep_output_dir}${plink_final_fname}.pheno | awk '{print $1}')"
nsnps="$(wc -l ${prep_output_dir}${snpNames_NoMA_fname} | awk '{print $1}')"
printf "number of subjects = ${nsubj} \n" | tee -a ${cond_job_log_fname}
printf "number of SNPs = ${nsnps} \n\n" | tee -a ${cond_job_log_fname}


### SANITY CHECKS #####################################################
# check any duplicate SNP IDs
nsnps_bim="$(wc -l ${prep_output_dir}${plink_final_fname}.bim | awk '{print $1}')"
uniq_snps_snpNamesNoMA="$(sort -u ${prep_output_dir}${snpNames_NoMA_fname} | wc -l)"
printf "number of SNPs in .bim file = ${nsnps_bim} \n" | tee -a ${cond_job_log_fname}
printf "number of unique SNPs in .snpNamesNoMA file = ${uniq_snps_snpNamesNoMA} \n\n" | tee -a ${cond_job_log_fname}


time2=$(date +%s)
secs=$((time2-time1))
printf "job ${job_name} ended at "$(date)
printf 'job took %dd:%dh:%dm:%ds\n' $(($secs/86400)) $(($secs%86400/3600)) $(($secs%3600/60)) $(($secs%60)) | tee -a ${cond_job_log_fname}
