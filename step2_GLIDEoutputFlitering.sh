#!/bin/bash
#SBATCH --job-name=process_GLIDEoutput_LD_06
#SBATCH --mail-type=ALL 
#SBATCH --mail-user=username@queensu.ca 
#SBATCH --account=con-hpcg1553 
#SBATCH --partition=reserved 
#SBATCH -c 8 
#SBATCH --mem 800g 
#SBATCH -t 3-00:00:00 
#SBATCH -o ./logs/%j-%N-%x.out 
#SBATCH -e ./logs/%j-%N-%x.err 

module load r
which R

### SET PARAMETERS ####################################################
job_name="process_GLIDEoutput_LD_06"
printf "job ${job_name} started at $(date) \n"
time1=$(date +%s)

plink_fname="child_only_qced_maf005_filtered" # change initial plink filename
rsq="6" # LD pruning r^2 value
tscore="3"
GLIDEinput_rootName=${plink_fname}"_prunedInLD0"${rsq}"_phenoAdded_noMissings"
GLIDEinput_rootName_short=${GLIDEinput_rootName:0:65}

prep_output_dir="/global/project/hpcg1553/Yang/ESNA/Shrey/glide/outputs/"
GLIDE_dir="/global/project/hpcg1553/CHILD_glide/GLIDE_dir/"

glideIn_f="${prep_output_dir}${GLIDEinput_rootName}.glideIn"
snpNames_f="${prep_output_dir}${GLIDEinput_rootName}.snpNamesNoMA"
pheno_f="${prep_output_dir}${GLIDEinput_rootName}.pheno"

nsubj="$(wc -l ${pheno_f} | awk '{print $1}')"
nsnps="$(wc -l ${snpNames_f} | awk '{print $1}')"

glide_output_dir="./outputs1/"
GLIDEoutput_rootName=${GLIDEinput_rootName_short}"_T"${tscore}"glideout"
# GLIDEoutput_rootName="glideout_test"

chunksize="2000"
blocksize="20"


### ATTACH SNP ID and Pvals #########################################
R --vanilla --args \
	${glide_output_dir}${GLIDEoutput_rootName} \
	${snpNames_f} \
	${snpNames_f} \
	${chunksize} \
	${chunksize} \
	${nsubj} \
	${glide_output_dir}${GLIDEoutput_rootName}"_wSnpIDandPvals" \
	${blocksize} < ${GLIDE_dir}GLIDE_search_snpname_pval.R


### CLEAN UP GLIDE OUTPUT ###########################################
printf "\nget Snp1, Snp2, Tscore columns from "${glide_output_dir}${GLIDEoutput_rootName}"_wSnpIDandPvals... \n"
cut -d " " -f 10-12,16 ${glide_output_dir}${GLIDEoutput_rootName}"_wSnpIDandPvals" \
| sed -n '2,$p' | awk -F $" " '{ t = $1; $1 = $4; $4 = t; print; }' OFS=$" " \
| cut -d" " -f2- > ${glide_output_dir}${GLIDEoutput_rootName}"_wSnpIDandPvals_clean"


### OUTPUT UNIQ SNP LIST ############################################
snpList_output_fname=${GLIDEoutput_rootName}"_snplist"
awk -F " " '{print $1}' ${glide_output_dir}${GLIDEoutput_rootName}"_wSnpIDandPvals_clean" \
| sort -u > ${glide_output_dir}${snpList_output_fname}


### SNP numbers CHECKS ###################################################
num_SNPs="$(cat ${glide_output_dir}${snpList_output_fname} | wc -l)"
printf "total number of SNPs = ${num_SNPs} \n"


time2=$(date +%s)
secs=$((time2-time1))
printf "\njob ${job_name} ended at $(date) \n"
printf 'job took %dd:%dh:%dm:%ds\n' $(($secs/86400)) $(($secs%86400/3600)) $(($secs%3600/60)) $(($secs%60))

