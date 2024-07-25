"%&%" <- function(a,b) paste(a,b, sep = "")
wd <- '/project/xuanyao/daniel/DACT_analysis'

for (c in seq(1:22)){
  command_line <- '#!/bin/sh' %&% '\n' %&% '#SBATCH --time=36:00:00' %&%  '\n' %&% 
    '#SBATCH --mem=100G' %&% '\n' %&% '#SBATCH --partition=caslake' %&% '\n' %&% 
    '#SBATCH --account=pi-xuanyao' %&% '\n' %&% '#SBATCH --error=' %&% 
    wd %&% '/chr' %&% c %&% '_eQTLwrapper.error' %&% '\n' %&% 
    '#SBATCH --out=' %&% wd %&% '/chr' %&% c %&% '_eQTLwrapper.out' %&% '\n\n' %&%
    'cd ' %&% wd %&% '\n\n' %&% 'module load R/4.1.0' %&% '\n\n' %&% 
    'Rscript merge_eqtl_sumstats.R -c ' %&% c

  cat(command_line, file='merge_eqtls_chr'%&%c%&%'.sbatch')
  system('sbatch merge_eqtls_chr'%&%c%&%'.sbatch')
  print('submitted: merge_eqtls_chr'%&%c%&%'.sbatch\n')
}