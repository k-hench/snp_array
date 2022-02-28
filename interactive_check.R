# remotes::install_bioc("VariantAnnotation")
# remotes::install("plyranges")

library(tidyverse)
library(plyranges)

test <- VariantAnnotation::readVcf("test.vcf")

distances <- test@rowRanges %>% 
  as_tibble() %>% 
  dplyr::select(seqnames, position = start) %>% 
  group_by(seqnames) %>% 
  mutate(dist_before = lead(position) - position,            # compute distance to SNP before
         dist_after = position - lag(position, default = 1), # compute distance to SNP after
         with_invar_stretch = dist_before + dist_after) %>%  # total length of invariant stetch
  ungroup()

# filtering for total stretch length
distances %>% 
  filter(with_invar_stretch >= 80) %>% 
  dplyr::select(`#CHROM` = seqnames, position) %>% 
  write_tsv("snps_total_distance.tsv")

# filtering for min distance before and after
distances %>% 
  filter(dist_before >= 40 & dist_after >= 40) %>% 
  dplyr::select(`#CHROM` = seqnames, position) %>% 
  write_tsv("snps_before_and_after.tsv")
