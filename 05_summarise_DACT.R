library(data.table)
library(tidyverse)
library(purrr) 
read_the_file <- function(x){
  gene_name <- substr(x, 5, nchar(x)-4)
  d <- fread(x)
  d <- d %>% filter(DACT_pval<(0.05/(length(dact_genes)*2942))) %>% mutate(peri_gene=gene_name)
  return(d)
}
setwd('/project/xuanyao/daniel/DACT_analysis/DACT_results/')

# list of files to read
dact_genes <- list.files('.')

# use map_df to extract data from 
# multiple files in parallel 
sig_dact <- map_df(dact_genes, read_the_file) 

# reorder columns and rows
sig_dact <- sig_dact %>% select(peri_gene, core_gene,
                                em_pval, mo_pval, DACT_pval) %>%
  arrange(DACT_pval)

# print some stuff
print(length(dact_genes))
print(length(dact_genes)*2942)
print(0.05/(length(dact_genes)*2942))

# save results
fwrite(sig_dact, '../DACT_sig_results.txt', quote=F, sep=' ')