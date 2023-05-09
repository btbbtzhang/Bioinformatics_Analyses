# SKATbinary_noPCAs_linear_skat
# 2022-12-20_source
library(SKAT)
library(tidyverse)
library(plyr)
library(tictoc)

home_dir <- "/global/project/hpcg1553/Yang/ESNA/Shrey/FinalCode/SKAT/"
prepro_output_dir <- paste0(home_dir, "outputs/")

rdata_dir <- paste0(home_dir, "inputs/")

plink_f = "merged_child_only_updated_rsid_update_sex1_maf001_filesforSKAT"

File.Bed <- paste0(rdata_dir, plink_f, ".bed")
File.Bim <- paste0(rdata_dir, plink_f, ".bim")
File.Fam <- paste0(rdata_dir, plink_f, ".fam")

## The following is for 914 dynamic tree cutting clutered results
File.SetID <- paste0(rdata_dir, "setIDforSKAT_treecut.txt")
File.SSD <- paste0(rdata_dir, "RecurrentWheeze_SKATbinary_Amirtha_Yang.SSD")
File.Info <- paste0(rdata_dir, "RecurrentWheeze_SKATbinary_Amirtha_Yang.SSD.info")
File.Cov <- paste0(rdata_dir,"covariates_pcs_sex_child_only.txt")

## The following is for preclustered results containing 128 cluters
#File.SetID <- paste0(rdata_dir, "setIDforSKAT_preclustered")
#File.SSD <- paste0(rdata_dir, "RecurrentWheeze_SKATbinary_Amirtha_Yang_precluster.SSD")
#File.Info <- paste0(rdata_dir, "RecurrentWheeze_SKATbinary_Amirtha_Yang_precluster.SSD.info")
#File.Cov <- paste0(rdata_dir,"covariates_pcs_sex_child_only.txt")

Generate_SSD_SetID(File.Bed, File.Bim, File.Fam, File.SetID, File.SSD, File.Info)

FAM <- Read_Plink_FAM_Cov(File.Fam, File.Cov, Is.binary=TRUE, cov_header=TRUE)

FAM[1:5,]

SSD.INFO <- Open_SSD(File.SSD = File.SSD, File.Info = File.Info)

## the following is to add adjusted beta values as weights on SKAT for 914 tree cut (based A1 col, minor allele, beta value is adjusted)
obj.SNPOR <- Read_SNP_WeightFile("/global/project/hpcg1553/Yang/ESNA/Shrey/FinalCode/SKAT/inputs/rsID_beta_treecut_pividori.txt") # 1 col: rsID; 2col: beta

## Using Minor Allel Frequency as weight
#obj.SNPOR <- Read_SNP_WeightFile("/global/project/hpcg1553/Yang/ESNA/Shrey/FinalCode/SKAT/inputs/rsID_MAFweighted_treecut.txt") # 1 col: rsID; 2col: odd ratio

## Using Minor Allel Frequency as weight
#MAFweight = Get_Logistic_Weights_MAF("/global/project/hpcg1553/Yang/ESNA/Shrey/FinalCode/SKAT/inputs/MAFonly_treecut.txt", par1=0.07, par2=150)


## the following is to add OD weights on SKAT for 128 pre cut
#obj.SNPOR <- Read_SNP_WeightFile("/global/project/hpcg1553/Yang/ESNA/Shrey/FinalCode/SKAT/inputs/rsID_OD_precut_public.txt") # 1 col: rsID; 2col: odd ratio

obj.null.COVsex <- SKAT_Null_Model(Phenotype ~ Sex.y+PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10, out_type="D", data=FAM, Adjustment=FALSE)

out.skatbinary.noPCAs.linear.skat <- SKATBinary.SSD.All(SSD.INFO, obj.null.COVsex, obj.SNPWeight = obj.SNPOR, kernel="linear.weighted", method="SKAT") #obj.SNPWeight = obj.SNPOR  kernel= "2wayIX"	weights= MAFweight  kernel="linear.weighted"

save(out.skatbinary.noPCAs.linear.skat, file = paste0(rdata_dir, "out.skat_adjustedBeta_treecut_Pividori.Rda"))
Close_SSD()


#load(file = paste0(rdata_dir, "out.skatbinary.noPCAs.linear.skat.Rda"))

0.05/914     
0.05/128



out.skatbinary.noPCAs.linear.skat$results %>% arrange(P.value)
#"

#"

# EOF
