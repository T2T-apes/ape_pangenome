# SNV and gap divergence
------------------------

**Step 1:** Download data into directories as described [here](download.md).

**Step 2:** Submit jobs to compute basic SNV and gap divergence.

```
cd basic-div
bash submit_basic.sh
```
which calls [this python script](tools/compute_basic_div.py).

**Step 3:** Make plots.
```
Rscript plot_gap_divergence.R
Rscript plot_snv_divergence.R
```

**RESULTS:** 
SNV divergence and gap divergence were computed from pairwise alignments, estimated with wfmash v 0.13, for 1MB segments across the genome. **SNV divergence** is the fraction of positions in the genome where the two haplotypes are in different *nucleotide* states.
**Gap divergence** is the fraction of positions in the target haplotype that are not aligned to the other haplotype, which could be due to biological processes (e.g., gene loss/gain and insertions/deletions), missing data, or technical problems (e.g. alignment failure).

The plot below shows 1MB segments binned by **SNV divergence** for each pairwise alignment (note that density, rather than counts, are shown).
The second haplotype listed was aligned to the first (note that "x vs. y" and "y vs. x" are different pairwise alignments because the former includes the entire x haplotype with no gaps and the latter includes the entire y haplotype with no gaps).
Density plots are broken down according to whether the segments come from an autosome, the X chromosome, or the Y chromosome. Mean SNV divergence is reported for these three cases (numeric values and circles; medians are `|` characters).
![SNV divergence](basic-div/snv_divergence.png)

The plot below shows 1MB segments are binned by **gap divergence** separated by pairwise alignment (note that density, rather than counts, are shown; height normalized hisograms are also shown). 
![Gap divergence](basic-div/gap_divergence.png)

This plot is the same as the gap divergence plot above but zoomed in.
![Gap divergence](basic-div/gap_divergence_zoomed.png)

IMPORTANT: An issue in making histograms or density plots for the Y chromosome is that there are far fewer segments than for autosomes (~30 vs ~3000 segments for autosomes). Thus, peaks could be driven by 1-2 segments for the Y chromosome.

The data underlying these plots are available in [basic-div](basic-div).
To count the number of missing characters in the first/target haplotype in a pairwise alignment with the example command below.
```
zcat mafs/hg002#M/hg002#M#chr22_MATERNAL.filtered10Mb.maf.gz | head -n2 | tail -n1 | awk '{print $7}' > tmp.txt
wc -c tmp.txt
tr -cd 'N' < tmp.txt | wc -c
```
shows that 5345761 out of 53395393 characters (10%) are `N`.
