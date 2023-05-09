import pandas as pd
import dash_bio
from dash import dcc
import matplotlib.pyplot as plt
import numpy as np
import qmplot as qmp
import sys


### load the data
df = pd.read_csv('/Users/yangzhang/Downloads/ESNA/INPUTS/gwas_recurrent_wheeze.assoc.logistic', delim_whitespace=True)
df.shape
df = df.dropna(how="any", axis=0)
df.shape
df = df.drop_duplicates()
df.shape
df = df.reset_index(drop=True)
list(df.columns.values)

database1 = df.iloc[:, [0, 1, 2, 11]]
#database1.to_csv('/Users/yangzhang/Downloads/database_OD.txt', header=None, index=None, sep=' ', mode='a')
database1.columns = ['SNP', 'OD', 'zstat']
database1.shape
database1.head(5)


# Manhattan plot from lib qmplot
if __name__ == "__main__":
    f, ax = plt.subplots(figsize=(12, 12), facecolor='w', edgecolor='k')
    qmp.manhattanplot(data=database1, chrom= 'CHR', snp= "SNP", pv='P', pos='BP',
                      #marker=".",
                      sign_marker_p=5e-8,
                      sign_marker_color="red",
                      highlight_other_SNPs_indcs=highlights,
                      highlight_other_SNPs_color="red",

                      title="Test",
                      xlabel="Chromosome",
                      ylabel=r"$-log_{10}{(P)}$",
                      suggestiveline=1e-5, genomewideline=5e-8,
                      sign_line_cols=["#D62728", "#2CA02C"],
                      hline_kws={"linestyle": "--", "lw": 1.3},
                      is_annotate_topsnp=False,
                      ld_block_size=500000,
                      text_kws={"fontsize": 12,"arrowprops": dict(arrowstyle="-", color="k", alpha=0.6)},
                      #is_show=False,
                      ax=ax)
    plt.savefig("better_manhattan.png", dpi=350)
    plt.close()

sys.getsizeof(database1)



