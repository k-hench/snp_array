#!/usr/bin/env Rscript
#
# run from terminal:
# Rscript --vanilla filter_stretch.R <name.vcf> <n>
# eg:
# Rscript --vanilla filter_stretch.R test.vcf 40
# ===============================================================
#
# This script filters a given vcf for SNPs that are embedded in 
# a stretch of invariant positions of a specified width.
#
# ===============================================================
# args <- c('test.vcf', '40') # just for bug-fixing / development
args <- commandArgs(trailingOnly = FALSE)
# setup -----------------------
library(tidyverse)
library(plyranges)

args <- args[7:length(args)]
# config -----------------------
vcf_file <- as.character(args[1])
buffer_distance <- as.integer(args[2])

data_vcf <- VariantAnnotation::readVcf(vcf_file)

distances <- data_vcf@rowRanges %>% 
  as_tibble() %>% 
  dplyr::select(seqnames, position = start) %>% 
  group_by(seqnames) %>% 
  mutate(dist_before = lead(position) - position,            # compute distance to SNP before
         dist_after = position - lag(position, default = 1), # compute distance to SNP after
         with_invar_stretch = dist_before + dist_after) %>%  # total length of invariant stetch
  ungroup()

# filtering for min distance before and after
distances %>% 
  filter(dist_before >= buffer_distance & dist_after >= buffer_distance) %>% 
  dplyr::select(`#CHROM` = seqnames, position) %>% 
  write_tsv(str_c("snps_before_and_after_", buffer_distance, "bp.tsv"))
