library(data.table)
library(tidyverse)
library(argparse)
"%&%" <- function(a,b) paste(a,b, sep = "")
setwd('/project/xuanyao/daniel/DACT_analysis')
parser <- ArgumentParser()
parser$add_argument('-c')
args <- parser$parse_args()

folders_vector <- list.dirs('/project/xuanyao/jinghui/pqtl/UKB_PPP_combined')[-1]

for (f in folders_vector){
  file_to_read <- list.files(f, pattern='chr'%&% args$c %&%'_', full.names=T)
  tmp <- fread(file_to_read) %>% filter(ALLELE0 %in% c('A','T','C','G'), 
                                        ALLELE1 %in% c('A','T','C','G')) %>%
    select(CHROM, GENPOS, ID, BETA)
    
    if(exists('final.df')){
      final.df <- rbind(final.df, tmp) %>%
        arrange(ID, -abs(BETA)) %>%
        filter(duplicated(ID)==F)
    } else {final.df <- tmp}
}

fwrite(final.df, 'chr'%&% args$c %&%'_eQTLs.txt', quote=F, sep=' ')