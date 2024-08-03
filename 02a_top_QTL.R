library(data.table)
library(tidyverse)
"%&%" <- function(a,b) paste(a,b, sep = "")
setwd('/project/xuanyao/daniel/DACT_analysis')

# retrieve gene list
gene_df <- fread('example/gene_position.txt') %>%
  filter(type %in% c('lincRNA', 'protein_coding'),
         Chromosome %in% c('chrY','chrX','chrM') == F) %>%
  select(Chromosome, start, end, gene_name) %>%
  rename(chr=Chromosome) %>% mutate(topeQTL='A', beta=0)

# for every gene
for (i in 1:nrow(gene_df)){
  start_time <- Sys.time()
  working_gene <- gene_df[i,]
  print(working_gene$gene_name %&% ' - START')
  
  file_to_read <- list.files(pattern=working_gene$chr%&%'_eQTLs.txt.gz')
  # read file, find cis-SNPs, and keep the one with highest absolute beta
  qtls <- fread(file_to_read) %>% filter(GENPOS>=working_gene$start-1e6 &
                                         GENPOS<=working_gene$end+1e6) %>%
    slice_max(abs(BETA), with_ties=F)
    
  # confirm there are QTLs
  if (nrow(qtls)>0){
    gene_df$topeQTL[i] <- qtls$ID
    gene_df$beta[i] <- qtls$BETA
  } else {
    print('No QTLs present')
  }
  
  print(working_gene$gene_name %&% ' - END')
  print(i/nrow(gene_df) * 100)
  end_time <- Sys.time()
  print(end_time - start_time)
}

# filter genes w/o QTLs
gene_df <- gene_df %>% filter(topeQTL!='A' & beta!=0)

# save
fwrite(gene_df, 'genes_w_topeQTL.txt', quote=F, sep=' ')