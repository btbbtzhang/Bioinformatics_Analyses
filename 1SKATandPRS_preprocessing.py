import pandas as pd
import dash_bio
from dash import dcc
import matplotlib.pyplot as plt
import numpy as np
import qmplot as qmp
import sys

df = pd.read_csv('/Users/yangzhang/Downloads/ESNA/INPUTS/gwas_recurrent_wheeze.assoc.logistic', delim_whitespace=True)
df.shape
df = df.dropna(how="any", axis=0)
df.shape
df = df.drop_duplicates()
df.shape
df = df.reset_index(drop=True)
list(df.columns.values)

df2 = pd.read_csv('/Users/yangzhang/Downloads/ESNA/INPUTS/ajusted_Pividori_beta.txt', sep='\t')
df2.shape
df2 = df2.dropna(how="any", axis=0)
df2.shape
df2 = df2.drop_duplicates()
df2.shape
list(df2.columns.values)
database = df2.iloc[:, [4, 6, 7]]

df_snp = pd.DataFrame(df['SNP'])
df_snp = df_snp.drop_duplicates()
df2_snp = pd.DataFrame(df2['rsid'])
df2_snp = df2_snp.drop_duplicates()
x1 = pd.DataFrame(df['A1'])
x2 = pd.DataFrame(df2['alt'])
df2_snp.columns = ['SNP']

snpOR = pd.merge(df2_snp, df_snp.reset_index())
snpOR.shape
snpOR = snpOR.dropna(how="any", axis=0)
snpOR = snpOR.drop_duplicates()
snpOR.shape

snpOR1 = pd.merge(df2_snp.reset_index(), df_snp)
snpOR1.shape
snpOR1 = snpOR1.dropna(how="any", axis=0)
snpOR1 = snpOR1.drop_duplicates()
snpOR1.shape

x = pd.merge(snpOR['SNP'].reset_index(), df_snp)
x_1 = pd.merge(snpOR['SNP'].reset_index(), x1)

xx = snpOR.iloc[:, [1]] # for df
xx1= snpOR1.iloc[:, [0]] # for df2

xx = np.array(xx)
xx = np.reshape(xx,(len(xx)))
xx = xx.tolist()
y2 = x2.iloc[xx1, :] # from df2
y1 = x1.iloc[xx,:] # from df
y3=y2
y3.columns =["A1"]
y=y1.reset_index()==y3.reset_index()


snpOR1.loc[snpOR1['SNP']=='rs80293782']
newtable = snpOR1.join(y['A1'])
newtable.rename(columns={'index':'index_pividori'}, inplace=True)
overlapdata = df2.iloc[xx1, :]
overlapdata = overlapdata.reset_index()
idex1 = newtable.A1[newtable.A1 == False].index.tolist()
overlapdata['beta'].iloc[idex1] = -overlapdata['beta'].iloc[idex1]
overlapdata.rename(columns={'index':'index_pividori'}, inplace=True)
overlapdata.to_csv('/Users/yangzhang/Downloads/ESNA/ajusted_Pividori_beta.txt', header=True, index=None, sep='\t', mode='a')
overlapdata.columns.values

database2 = overlapdata.iloc[:, [4, 7]]
database2.columns = ['SNP', 'beta']
database2.shape
database2.head(5)


######### PRS analysis data preparation 
database = df2.iloc[:, [4, 6, 7]]
RSIDs_treecut = pd.read_csv('/Users/yangzhang/Downloads/ESNA/INPUTS/setIDforSKAT_treecut.txt', header=None, sep=' ')
RSIDs_treecut.columns = ['cluster', 'SNP']
RSIDs_treecut.shape
tcluster = RSIDs_treecut.loc[RSIDs_treecut['cluster'] == 'cluster810']
tcluster1 = tcluster.iloc[:, [1]]
## Saving the file

# get the prs file
#database.rename(columns={'rsid':'SNP'}, inplace=True)
x = pd.merge(database.reset_index(), tcluster1)
target = x.iloc[:,[1,2,3]]
target.to_csv('/Users/yangzhang/Downloads/ESNA/INPUTS/cluster1snp_prs.txt', header=True, index=None, sep='\t', mode='a')

# Saving the rsID and beta values into a file for the input of SKAT (treecut)
rsIDs_treecut = RSIDs_treecut.iloc[:, [1]]
rsIDs_treecut.shape
rsIDs_treecut.head(4)
snpOR1 = pd.merge(database2.reset_index(), rsIDs_treecut)
snpOR1.shape
snpOR1 = snpOR1.iloc[:, [1, 2]]

test1 = pd.merge(rsIDs_treecut.reset_index(), snpOR1)
test1.head(4)
test1 = test1.iloc[:, [1, 2]]
test1.to_csv('/Users/yangzhang/Downloads/ESNA/rsID_beta_treecut_pividori.txt', header=None, index=None, sep=' ', mode='a')
