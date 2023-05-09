#!/bin/bash
#SBATCH --job-name=glide_gw_LD06_p2000_T3
#SBATCH --mail-type=ALL
#SBATCH --mail-user=username@queensu.ca
#SBATCH --account=gpu-hpcg1553
#SBATCH --qos=avin
#SBATCH --partition=gpu-vin

#SBATCH --gres gpu:1
#SBATCH --cpus-per-task=10
#SBATCH --mem 128g
#SBATCH -t 6-00:00:00
#SBATCH -o ./logs1/%j-%N-%x.out 
#SBATCH -e ./logs1/%j-%N-%x.err 

module load cuda/10.0.130

### SET PARAMETERS ####################################################
job_name="glide_gw_LD06_p2000_T3"
printf "job ${job_name} started at $(date) \n"
time1=$(date +%s)

plink_fname="child_only_qced_maf005_filtered" # change initial plink filename
rsq="6" # change LD pruning r^2 value
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
printf "number of subjects = ${nsubj} \n"
printf "number of SNPs = ${nsnps} \n\n"


### RUN GLIDE #########################################################
#f1: sample.glideIn (genotype)
#f2: sample.glideIn (genotype)
#fp: sample.pheno 
#n: number of subjects
#m: number of SNPs for the first geno
#m2: number of SNPs for the second geno
#p: partition size
#t: tscore threshold
#o: output
#g: gpu device

${GLIDE_dir}GLIDE -f1 ${glideIn_f} \
                  -f2 ${glideIn_f} \
                  -fp ${pheno_f} \
                  -n ${nsubj} \
                  -m ${nsnps} \
                  -m2 ${nsnps} \
                  -p 2000 \
                  -t ${tscore} \
                  -o "./outputs1/"${GLIDEinput_rootName_short}"_T"${tscore}"glideout" \
                  -g 0


time2=$(date +%s)
secs=$((time2-time1))
printf "job ${job_name} ended at $(date) \n"
printf 'job took %dd:%dh:%dm:%ds\n' $(($secs/86400)) $(($secs%86400/3600)) $(($secs%3600/60)) $(($secs%60))

