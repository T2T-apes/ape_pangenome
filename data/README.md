## data

Download assemblies:

```shell
# Primates (release 2023/12/05) from https://genomeark.s3.amazonaws.com/index.html?prefix=species/
wget -c https://s3.amazonaws.com/genomeark/species/Gorilla_gorilla/mGorGor1/assembly_curated/mGorGor1.dip.cur.20231122.fasta.gz
wget -c https://s3.amazonaws.com/genomeark/species/Pan_paniscus/mPanPan1/assembly_curated/mPanPan1.dip.cur.20231122.fasta.gz
wget -c https://s3.amazonaws.com/genomeark/species/Pan_troglodytes/mPanTro3/assembly_curated/mPanTro3.dip.cur.20231122.fasta.gz
wget -c https://s3.amazonaws.com/genomeark/species/Pongo_abelii/mPonAbe1/assembly_curated/mPonAbe1.dip.cur.20231205.fasta.gz
wget -c https://s3.amazonaws.com/genomeark/species/Pongo_pygmaeus/mPonPyg2/assembly_curated/mPonPyg2.dip.cur.20231122.fasta.gz
wget -c https://genomeark.s3.amazonaws.com/species/Symphalangus_syndactylus/mSymSyn1/assembly_curated/mSymSyn1.dip.cur.20231205.fasta.gz

# HG002v1.0.1
wget -c https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/HG002/assemblies/hg002v1.0.1.fasta.gz

# Download chm13v2 and grch38
```

Apply [PanSN-spec](https://github.com/pangenome/PanSN-spec):

```shell
for species in mGorGor1 mPanPan1; do
    zcat $species.dip.cur.20231122.fasta.gz | \
        sed "/^>/ s/chr\(.*\)_\(mat\|pat\)_*/$species##\2##\0/; s/#mat#/M/; s/#pat#/P/" | \
        bgzip -@ 48 -l 9 > $species.fa.gz && samtools faidx $species.fa.gz
done
for species in mPanTro3 mPonPyg2; do
    zcat $species.dip.cur.20231122.fasta.gz  | \
        sed "/^>/ s/chr\(.*\)_\(hap1\|hap2\)_*/$species##\2##\0/; s/#hap1#/1/; s/#hap2#/2/" | \
        bgzip -@ 48 -l 9 > $species.fa.gz && samtools faidx $species.fa.gz
done
for species in mPonAbe1 mSymSyn1; do
    zcat $species.dip.cur.20231205.fasta.gz  | \
        sed "/^>/ s/chr\(.*\)_\(hap1\|hap2\)_*/$species##\2##\0/; s/#hap1#/1/; s/#hap2#/2/" | \
        bgzip -@ 48 -l 9 > $species.fa.gz && samtools faidx $species.fa.gz
done
rm *fasta.gz

zcat hg002v1.0.1.fasta | sed -e 's/^>chr\(.*\)_MATERNAL/>hg002#M#chr\1_MATERNAL/' \
    -e 's/^>chr\(.*\)_PATERNAL/>hg002#P#chr\1_PATERNAL/' \
    -e 's/^>chrEBV/>hg002#P#chrEBV/' \
    -e 's/^>chrM/>hg002#M#chrM/' | bgzip -@ 48 -l 9 > hg002v101.fa.gz && samtools faidx hg002v101.fa.gz
rm hg002v1.0.1.fasta.gz
```

Put all haplotypes together (assumes you already have PanSN-ed CHM13v2 and PanSN-ed GRCh38):

```shell
zcat chm13v2.0.fa.gz grch38.fa.gz hg002v101.fa.gz mGorGor1.fa.gz mPanPan1.fa.gz mPanTro3.fa.gz mPonAbe1.fa.gz mPonPyg2.fa.gz mSymSyn1.fa.gz | bgzip -@ 48 -l 9 > primates16.20231205.fa.gz
samtools faidx primates16.20231205.fa.gz
```

You can find the final FASTA file at https://garrisonlab.s3.amazonaws.com/t2t-primates/primates16.20231205.fa.gz
