
# mockup SNP filtering for SNP-array

1) Detect SNPs that are embedded in a invariant stretch of a minimum width.
(Check out the `interactive_check.R` for an idea how the scripts works.)

This depends on the R package collection `tidyverse`, as well as on `plyranges` and `VariantAnnotation` (both from [bioconductor](https://bioconductor.org)).

```sh
Rscript --vanilla filter_stretch.R test.vcf 40
```

2) Use `vcftools` to filter based on allele frequencies.

```sh
vcftools --vcf test.vcf \
   --positions snps_before_and_after_40bp.tsv \
	 --maf 0.3 \
	 --stdout \
	 --recode > snps_af_filtered.vcf
```

3) Use `bedtools` to filter for *within exon* only SNPs.

```sh
bedtools intersect -a snps_af_filtered.vcf -b test.gff
```
