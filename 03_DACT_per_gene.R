library(data.table)
library(tidyverse)
library(argparse)
library(purrr) 
library(DACT)
"%&%" <- function(a,b) paste(a,b, sep = "")
read_the_file <- function(x){
  gene_name <- x %>% substr(48, which(strsplit(x, '')[[1]]=='_')[3]-1)
  d <- fread(x) %>% filter(ID==wk_gene$topeQTL) %>% select(LOG10P) %>%
    mutate(GENE=gene_name)
  return(d)
}
setwd('/project/xuanyao/daniel/DACT_analysis')
parser <- ArgumentParser()
parser$add_argument('-g')
args <- parser$parse_args()

# get mediator-outcome pvals
sumstats <- fread('genes_WES_topeQTL.txt')

# get gene info 
wk_gene <- fread('genes_w_topeQTL.txt') %>% filter(gene_name==args$g)

# get exposure-mediator pvals
## create a list of file names 
folders_vector <- list.dirs('/project/xuanyao/jinghui/pqtl/UKB_PPP_combined')[-1]
files_to_read <- c()
for (f in folders_vector){
  if (substr(f, 48, which(strsplit(f, '')[[1]]=='_')[3]-1) %in% sumstats$gene_name){
  files_to_read <- c(files_to_read, list.files(f, pattern=wk_gene$chr %&%'_', full.names=T))
  }
}
## use map_df to extract data from 
## multiple files in parallel 
em_pvals <- map_df(files_to_read, read_the_file)
em_pvals$LOG10P <- 10^-(em_pvals$LOG10P)

# merge dfs
merge <- inner_join(em_pvals, sumstats, by=c('GENE'='gene_name')) %>%
  select(GENE, LOG10P, pval) %>% rename(core_gene=GENE, em_pval=LOG10P, mo_pval=pval)

# run DACT
merge <- merge %>% 
  mutate(DACT_pval=DACT(merge$em_pval, merge$mo_pval, correction='JC'))

# save results
fwrite(merge, 'DACT_results/LDL_' %&% args$g %&%'.txt', sep=' ', quote=F)