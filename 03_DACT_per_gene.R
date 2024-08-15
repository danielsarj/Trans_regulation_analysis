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
wk_gene <- fread('genes_w_topeQTL.txt') %>% filter(gene_name==g)

# find and remove cis-genes from the WES sumstats
cis_genes <- sumstats %>% filter(chr==wk_gene$chr, 
                                 start >= wk_gene$start-1e6 & end <= wk_gene$end+1e6) %>%
  select(gene_name) %>% pull()
sumstats <- sumstats %>% filter(gene_name%in%cis_genes==F) 

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

# substitute 0s to avoid error in DACT
em_zeros <- which(merge$em_pval==0) %>% as.vector()
for (i in em_zeros){
  merge[i]$em_pval <- 1e-200
}
mo_zeros <- which(merge$mo_zeros==0) %>% as.vector()
for (i in mo_zeros){
  merge[i]$mo_zeros <- 1e-200
}

# run DACT
merge <- merge %>% 
  mutate(DACT_pval=DACT(merge$em_pval, merge$mo_pval, correction='JC'))

# save results
fwrite(merge, 'DACT_results/LDL_' %&% args$g %&%'.txt', sep=' ', quote=F)