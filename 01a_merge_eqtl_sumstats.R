library(data.table)
library(tidyverse)
library(argparse)
"%&%" <- function(a,b) paste(a,b, sep = "")
setwd('/project/xuanyao/daniel/DACT_analysis')
parser <- ArgumentParser()
parser$add_argument('-c')
args <- parser$parse_args()

# get name of all UKB-PPP folders
folders_vector <- list.dirs('/project/xuanyao/jinghui/pqtl/UKB_PPP_combined')[-1]

# loop through all folders
for (f in folders_vector){
  # find correct chr file
  file_to_read <- list.files(f, pattern='chr'%&% args$c %&%'_', full.names=T)
  # read the file and remove INDELS
  tmp <- fread(file_to_read) %>% filter(ALLELE0 %in% c('A','T','C','G'), 
                                        ALLELE1 %in% c('A','T','C','G')) %>%
    select(CHROM, GENPOS, ID, BETA)
    
    if(exists('final.df')){
      # merge files; if the same SNP is duplicated, keep the largest abs beta
      final.df <- rbind(final.df, tmp) %>%
        arrange(ID, -abs(BETA)) %>%
        filter(duplicated(ID)==F)
    } else {final.df <- tmp}
}

# save
fwrite(final.df, 'chr'%&% args$c %&%'_eQTLs.txt', quote=F, sep=' ')