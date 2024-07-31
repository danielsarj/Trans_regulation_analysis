library(data.table)
library(tidyverse)
"%&%" <- function(a,b) paste(a,b, sep = "")
setwd('/project/xuanyao/daniel/DACT_analysis')

# retrieve gene list
gene_df <- fread('example/gene_position.txt') %>%
  filter(type %in% c('lincRNA', 'protein_coding'),
         Chromosome %in% c('chrY','chrX','chrM') == F) %>%
  select(Chromosome, start, end, gene_name) %>%
  rename(chr=Chromosome) %>% mutate(topeQTL='A', pval=0)

# read WES GWAS sumstats
sumstats <- fread('/project/xuanyao/daniel/UKB/LDL_GCST90083019_buildGRCh38.tsv.gz')

for (i in 1:nrow(gene_df)){
  start_time <- Sys.time()
  working_gene <- gene_df[i,]
  print(working_gene$gene_name %&% ' - START')
  qtls <- sumstats %>% filter(str_detect(Name, working_gene$gene_name),
                              effect_allele=='M3.1') 
  if (nrow(qtls)>0){
    gene_df$topeQTL[i] <- qtls$effect_allele
    gene_df$pval[i] <- qtls$p_value
  } else {
    print('No QTLs present')
  }
  
  print(working_gene$gene_name %&% ' - END')
  print(i/nrow(gene_df) * 100)
  end_time <- Sys.time()
  print(end_time - start_time)
}

gene_df <- gene_df %>% filter(topeQTL!='A')
fwrite(gene_df, 'genes_WES_topeQTL.txt', quote=F, sep=' ')