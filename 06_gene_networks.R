library(data.table)
library(tidyverse)
library(igraph)
"%&%" <- function(a,b) paste(a,b, sep = "")
setwd('/project/xuanyao/daniel/DACT_analysis')

# read sig dact genes df
sig_dact <- fread('DACT_sig_results.txt') %>% select(peri_gene, core_gene, DACT_pval)

# make direct graph
dact_graph <- graph_from_data_frame(sig_dact, directed=T, vertices=NULL)

# find subgraphs
modules <- decompose(dact_graph)

# plot
for (i in 1:length(modules)){
  pdf('DACT_genes_network'%&%i%&%'.pdf')
  plot(modules[[i]], vertex.size=15, vertex.label.cex=1, 
     edge.width=3, edge.arrow.size=2, layout=layout_with_fr)
  dev.off()
}