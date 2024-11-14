###############################################################################
# A pure R Battenberg v2.2.9 WGS pipeline implementation.
###############################################################################
library(Battenberg);
library(optparse);

option.list <- list(
    make_option(c('-t', '--tumourname'), type = 'character', default = NULL, help = 'Samplename of the tumour', metavar = 'character'),
    make_option(c('-n', '--normalname'), type = 'character', default = NULL, help = 'Samplename of the normal', metavar = 'character'),
    make_option(c('--tb'), type = 'character', default = NULL, help = 'Tumour BAM file', metavar = 'character'),
    make_option(c('--nb'), type = 'character', default = NULL, help = 'Normal BAM file', metavar = 'character'),
    make_option(c('--sex'), type = 'character', default = NULL, help = 'Sex of the sample', metavar = 'character'),
    make_option(c('-o', '--output'), type = 'character', default = NULL, help = 'Directory where output will be written', metavar = 'character'),
    make_option(c('--skip_allelecount'), type = 'logical', default = FALSE, action = 'store_true', help = 'Provide when alleles don\'t have to be counted. This expects allelecount files on disk', metavar = 'character'),
    make_option(c('--skip_preprocessing'), type = 'logical', default = FALSE, action = 'store_true', help = 'Provide when pre-processing has previously completed. This expects the files on disk', metavar = 'character'),
    make_option(c('--skip_phasing'), type = 'logical', default = FALSE, action = 'store_true', help = 'Provide when phasing has previously completed. This expects the files on disk', metavar = 'character'),
    make_option(c('--cpu'), type = 'numeric', default = 8, help = 'The number of CPU cores to be used by the pipeline (Default: 8)', metavar = 'character'),
    make_option(c('--bp'), type = 'character', default = NULL, help = 'Optional two column file (chromosome and position) specifying prior breakpoints to be used during segmentation', metavar = 'character'),
    make_option(c('--min_ploidy'), type = 'double', default = 1.6, help = 'The minimum ploidy to consider', metavar = 'character'),
    make_option(c('--max_ploidy'), type = 'double', default = 4.8, help = 'The maximum ploidy to consider', metavar = 'character'),
    make_option(c('--min_rho'), type = 'double', default = 0.1, help = 'The minimum cellularity to consider', metavar = 'character'),
    make_option(c('--max_rho'), type = 'double', default = 1.0, help = 'The maximum cellularity to consider', metavar = 'character'),
    make_option(c('--platform_gamma'), type = 'numeric', default = 1, help = 'Platform specific gamma value (0.55 for SNP6, 1 for NGS)', metavar = 'character'),
    make_option(c('--phasing_gamma'), type = 'numeric', default = 1, help = 'Gamma parameter used when correcting phasing mistakes (Default: 1)', metavar = 'character'),
    make_option(c('--segmentation_gamma'), type = 'numeric', default = 10, help = 'The gamma parameter controls the size of the penalty of starting a new segment during segmentation. It is therefore the key parameter for controlling the number of segments (Default: 10)', metavar = 'character'),
    make_option(c('--segmentation_kmin'), type = 'numeric', default = 3, help = 'Kmin represents the minimum number of probes/SNPs that a segment should consist of (Default: 3)', metavar = 'character'),
    make_option(c('--phasing_kmin'), type = 'numeric', default = 1, help = 'Kmin used when correcting for phasing mistakes (Default: 3)', metavar = 'character'),
    make_option(c('--clonality_dist_metric'), type = 'numeric', default = 0, help = 'Distance metric to use when choosing purity/ploidy combinations (Default: 0)', metavar = 'character'),
    make_option(c('--ascat_dist_metric'), type = 'numeric', default = 1, help = 'Distance metric to use when choosing purity/ploidy combinations (Default: 1)', metavar = 'character'),
    make_option(c('--min_goodness_of_fit'), type = 'double', default = 0.63, help = 'Minimum goodness of fit required for a purity/ploidy combination to be accepted as a solution (Default: 0.63)', metavar = 'character'),
    make_option(c('--balanced_threshold'), type = 'double', default = 0.51, help = 'The threshold beyond which BAF becomes uninformative (Default: 0.51)', metavar = 'character'),
    make_option(c('--min_normal_depth'), type = 'numeric', default = 10, help = 'Minimum depth required in the matched normal for a SNP to be considered as part of the wgs analysis (Default: 10)', metavar = 'character'),
    make_option(c('--min_base_qual'), type = 'numeric', default = 20, help = 'Minimum base quality required for a read to be counted when allele counting (Default: 20)', metavar = 'character'),
    make_option(c('--min_map_qual'), type = 'numeric', default = 35, help = 'Minimum mapping quality required for a read to be counted when allele counting (Default: 35)', metavar = 'character'),
    make_option(c('--calc_seg_baf_option'), type = 'numeric', default = 3, help = 'Sets way to calculate BAF per segment: 1=mean, 2=median, 3=ifelse median==0 | 1, mean, median (Default: 3)', metavar = 'character'),
    make_option(c('--data_type'), type = 'character', default = 'wgs', help = 'String that contains either wgs or snp6 depending on the supplied input data (Default: wgs)', metavar = 'character')
    );

opt.parser <- OptionParser(option_list = option.list);
opt <- parse_args(opt.parser);

TUMOURNAME <- opt$tumourname;
NORMALNAME <- opt$normalname;
NORMALBAM <- opt$nb;
TUMOURBAM <- opt$tb;
IS.MALE <- opt$sex == 'male' | opt$sex == 'Male';
RUN.DIR <- opt$output;
SKIP.ALLELECOUNTING <- opt$skip_allelecount;
SKIP.PREPROCESSING <- opt$skip_preprocessing;
SKIP.PHASING <- opt$skip_phasing;
NTHREADS <- opt$cpu;
PRIOR.BREAKPOINTS.FILE <- opt$bp;
MIN.PLOIDY <- opt$min_ploidy;
MAX.PLOIDY <- opt$max_ploidy;
MIN.RHO <- opt$min_rho;
MAX.RHO <- opt$max_rho;
PLATFORM.GAMMA <- opt$platform_gamma;
PHASING.GAMMA <- opt$phasing_gamma;
SEGMENTATION.GAMMA <- opt$segmentation_gamma;
SEGMENTATION.KMIN <- opt$segmentation_kmin;
PHASING.KMIN <- opt$phasing_kmin;
CLONALITY.DIST.METRIC <- opt$clonality_dist_metric;
ASCAT.DIST.METRIC <- opt$ascat_dist_metric;
MIN.GOODNESS.OF.FIT <- opt$min_goodness_of_fit;
BALANCED.THRESHOLD <- opt$balanced_threshold;
MIN.NORMAL.DEPTH <- opt$min_normal_depth;
MIN.BASE.QUAL <- opt$min_base_qual;
MIN.MAP.QUAL <- opt$min_map_qual;
CALC.SEG.BAF.OPTION <- opt$calc_seg_baf_option;
DATA.TYPE <- opt$data_type;

# General static
IMPUTEINFOFILE <- '/opt/battenberg_reference/impute_info.txt';
G1000PREFIX <- '/opt/battenberg_reference/1000_genomes_loci/1000_genomes_allele_index_chr';
G1000PREFIX.AC <- '/opt/battenberg_reference/1000_genomes_loci/1000_genomes_loci_chr';
GCCORRECTPREFIX <- '/opt/battenberg_reference/1000_genomes_gcContent/1000_genomes_GC_corr_chr';
REPLICCORRECTPREFIX <- '/opt/battenberg_reference/battenberg_wgs_replication_timing_correction_1000_genomes/1000_genomes_replication_timing_chr';
IMPUTE.EXE <- 'impute2';

# WGS specific static
ALLELECOUNTER <- 'alleleCounter';
PROBLEMLOCI <- '/opt/battenberg_reference/battenberg_problem_loci/probloci.txt.gz';

# Change to work directory and load the chromosome information
setwd(RUN.DIR);

battenberg(
    tumourname = TUMOURNAME,
    normalname = NORMALNAME,
    tumour_data_file = TUMOURBAM,
    normal_data_file = NORMALBAM,
    ismale = IS.MALE,
    imputeinfofile = IMPUTEINFOFILE,
    g1000prefix = G1000PREFIX,
    g1000allelesprefix = G1000PREFIX.AC,
    gccorrectprefix = GCCORRECTPREFIX,
    repliccorrectprefix = REPLICCORRECTPREFIX,
    problemloci = PROBLEMLOCI,
    data_type = DATA.TYPE,
    impute_exe = IMPUTE.EXE,
    allelecounter_exe = ALLELECOUNTER,
    nthreads = NTHREADS,
    platform_gamma = PLATFORM.GAMMA,
    phasing_gamma = PHASING.GAMMA,
    segmentation_gamma = SEGMENTATION.GAMMA,
    segmentation_kmin = SEGMENTATION.KMIN,
    phasing_kmin = PHASING.KMIN,
    clonality_dist_metric = CLONALITY.DIST.METRIC,
    ascat_dist_metric = ASCAT.DIST.METRIC,
    min_ploidy = MIN.PLOIDY,
    max_ploidy = MAX.PLOIDY,
    min_rho = MIN.RHO,
    max_rho = MAX.RHO,
    min_goodness = MIN.GOODNESS.OF.FIT,
    uninformative_BAF_threshold = BALANCED.THRESHOLD,
    min_normal_depth = MIN.NORMAL.DEPTH,
    min_base_qual = MIN.BASE.QUAL,
    min_map_qual = MIN.MAP.QUAL,
    calc_seg_baf_option = CALC.SEG.BAF.OPTION,
    skip_allele_counting = SKIP.ALLELECOUNTING,
    skip_preprocessing = SKIP.PREPROCESSING,
    skip_phasing = SKIP.PHASING,
    prior_breakpoints_file = PRIOR.BREAKPOINTS.FILE
    );
