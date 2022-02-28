
# mock-up SNP filtering for SNP-array

The whole thing is run from the command line - for the genome-wide data it might make sense to split the data by linkage group /chromosome.

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

---

Each filtering step should remove some SNPs with finally only a single one remaining:

```sh
cat snps_before_and_after_40bp.tsv
#> #CHROM	position
#> one	146
#> one	249
#> two	146
#> two	249
```

```sh
cat snps_af_filtered.vcf | grep -v '^##'
#> #CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	sample_nr1	sample_nr2
#> one	146	.	A	T	100	.	.	GT:DP	0/1:18	0/1:18
#> one	249	.	G	A	100	.	.	GT:DP	0/1:62	0/1:62
#> two	249	.	G	A	100	.	.	GT:DP	0/1:62	0/1:62
```

```sh
bedtools intersect -a snps_af_filtered.vcf -b test.gff
#> two	249	.	G	A	100	.	.	GT:DP	0/1:62	0/1:62
```
