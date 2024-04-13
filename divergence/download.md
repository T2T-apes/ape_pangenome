# Download information
----------------------

Download data from [AWS](https://garrisonlab.s3.amazonaws.com/index.html?prefix=t2t-primates/wfmash-v0.13.0/mafs/).

Download alignments (PAFs).
```
mkdir alignments
cd alignments
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/alignments/chm13#1.p70.aln.paf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/alignments/hg002#P.p70.aln.paf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/alignments/mPonAbe1#1.p70.aln.paf.gz .
cd ..
```

Download chains.
```
mkdir chains
cd chains
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/chains/chm13#1.p70.aln.chain.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/chains/hg002#P.p70.aln.chain.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/chains/mPonAbe1#1.p70.aln.chain.gz .
cd ..
```

Download mappings.
```
mkdir mappings
cd mappings 
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mappings/chm13#1.p70.map.paf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mappings/hg002#P.p70.map.paf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mappings/mPonAbe1#1.p70.map.paf.gz .
cd ..
```


Download MAFs.
```
mkdir mafs
cd mafs
```

```
mkdir chm13#1
cd chm13#1
for i in `seq 1 22`; do
    aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/chm13#1#chr${i}.maf.gz .
done
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/chm13#1#chrX.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/chm13#1#chrY.maf.gz .
cd ..
```

```
mkdir hg002#M
cd hg002#M
for i in `seq 1 22`; do
    aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/hg002#M#chr${i}_MATERNAL.maf.gz .
done
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/hg002#M#chrX_MATERNAL.maf.gz .
cd ..

mkdir hg002#P
cd hg002#P
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/hg002#P#chrY_PATERNAL.maf.gz .
cd ..
```

```
mkdir mPonAbe1#1
cd mPonAbe1#1
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr1_hap1_hsa1.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr2_hap1_hsa3.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr3_hap1_hsa4.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr4_hap1_hsa5.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr5_hap1_hsa6.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr6_hap1_hsa7.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr7_hap1_hsa8.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr8_hap1_hsa10.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr9_hap1_hsa11.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr10_hap1_hsa12.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr11_hap1_hsa2b.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr12_hap1_hsa2a.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr13_hap1_hsa9.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr14_hap1_hsa13.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr15_hap1_hsa14.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr16_hap1_hsa15.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr17_hap1_hsa18.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr18_hap1_hsa16.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr18_hap1_hsa16_random_utig4-1074.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr18_hap1_hsa16_random_utig4-1076.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr18_hap1_hsa16_random_utig4-3743.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr18_hap1_hsa16_random_utig4-3745.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr19_hap1_hsa17.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr20_hap1_hsa19.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr21_hap1_hsa20.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr22_hap1_hsa21.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chr23_hap1_hsa22.maf.gz .
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#1#chrX_hap1_hsaX.maf.gz .
cd ..

mkdir mPonAbe1#2
cd mPonAbe1#2
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#2#chrY_hap2_hsaY.maf.gz .
cd ..
```
