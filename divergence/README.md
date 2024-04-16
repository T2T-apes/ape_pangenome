# SNV and gap divergence
------------------------

**Step 1:** Download data into directories as described [here](download.md).

**Step 2:** Submit jobs to compute basic SNV and gap divergence with [this script](basic-div/submit_basic.sh).

```
cd basic-div
bash submit_basic.sh
```

**Step 3:** Make plots
```
Rscript plot_gap_divergence.R
Rscript plot_snv_divergence.R
```

**RESULTS:** 
SNV and gap divergence were computed using pairwise alignments, estimated with wfmash v 0.13. In the graphs below, the second haplotype listed was aligned to the first. Importantly, "x vs. y" and "y vs. x" are different pairwise alignments. The former includes the entire x haplotype (no gaps) and the latter includes the entire y haplotype (no gaps). For each pairwise alignment, SNV divergence and gap divergence was computed for 1MB segments across the genome. **SNV divergence** is the fraction of positions in the genome where the two haplotypes are in different nucleotide states (and neither haplotype is a gap state or a missing state). **Gap divergence** is the fraction of positions in the genome where the second haplotype is a gap state (and the first haplotype is a nucleotide state; note that the first haplotype is never in a gap state but it can be in a missing state because of masking). 

The plot below shows 1MB segments binned by SNV divergence (note that density, rather than counts, are shown; normalized height histograms are also shown).
The density plots are broken down according to whether the segments come from an autosome, the X chromosome, or the Y chromosome.
The mean SNV divergence is reported for these cases (numeric values).
![SNV divergence](basic-div/snp_divergence.png)

The plot below shows 1MB segments binned by gap divergence (note that density, rather than counts, are shown). The density plots are broken down according to whether the segments come from an autosome, the X chromosome, or the Y chromosome. The mean SNV divergence is reported for these cases (numeric values).
![Gap divergence](basic-div/gap_divergence.png)

This plot is the same as the plot above but zoomed in.
![Gap divergence](basic-div/gap_divergence_zoomed.png)