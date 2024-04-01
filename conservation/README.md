
# Conservation

Set your paths:

```shell
DIR_BASE=/path/to/primates
PATH_PRIMATES16_FASTA=/path/to/primates16.20231205.fa.gz
PATH_PRIMATES16_CLEAN_FASTA=/path/to/primates/conservation/primates16.20231205.clean.fa
PATH_ALL_VS_CHM13_PAF=/path/to/primates/alignment/chm13#1.p70.aln.paf.gz

WGATOOLS=/path/to/wgatools/result/bin/wgatools
MAF_STREAM=/path/to/maf_stream/target/release/maf_stream
MSA_VIEW=/path/to/phast-v1_5/bin/msa_view
PHYLOFIT=/path/to/phast-v1_5/bin/phyloFit
PHASTCONS=/path/to/phast-v1_5/bin/phastCons
```

We need to:

- clean the FASTA file by removing special characters;
- prepare a table to rename sequences (from "sequence name" to "species name")
- download CHM13v2.0 gene annotation

```shell
mkdir -p $DIR_BASE/conservation
cd $DIR_BASE/conservation

# FASTA file without special characters
zcat $PATH_PRIMATES16_FASTA | sed -E  '/^[^>]/ s/[^ATGCNatgcn]/N/g' > $PATH_PRIMATES16_CLEAN_FASTA
samtools faidx $PATH_PRIMATES16_CLEAN_FASTA

# Table to rename sequences (sequence-name -> species-name)
join -1 1 -2 1 <(cat $DIR_BASE/data/genomes_lookup.csv | tr ',' '\t' | sort -k 1,1) <(cut -f 1 /lizardfs/guarracino/pggb-paper/assemblies/primates/primates16.20231205.fa.gz.fai | awk -F'#' -v OFS='\t' '{print $1"#"$2,$0}' | sort -k 1,1) | awk -v OFS='\t' '{print($3,$2)}' > $DIR_BASE/conservation/name2species.tsv

# Gene annotation
mkdir -p $DIR_BASE/data
cd $DIR_BASE/data
wget -c https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/annotation/chm13v2.0_RefSeq_Liftoff_v5.1.gff3.gz
```

From the all-vs-chm13 alignments in PAF format, filter out alignments shorter than 10 megabases (Mb) and convert the remaining alignments to MAF file format:

```shell
NAME=$(basename $PATH_ALL_VS_CHM13_PAF .paf.gz)

cd /scratch
$WGATOOLS filter -f paf -a 10000000 <(zcat $PATH_ALL_VS_CHM13_PAF) -o $NAME.filter10Mb.paf -r -t 48
$WGATOOLS pafpseudo $NAME.filter10Mb.paf -o $NAME.filter10Mb -r -f $PATH_PRIMATES16_CLEAN_FASTA -t 48
rm $NAME.filter10Mb.paf
```

Extract alignments (by taking one haplotype for each species, but considering all sex chromosomes) and rename sequences to match the names in the [primate_tree.nwk](../data/primate_tree.nwk) tree:

```shell 
mkdir -p $DIR_BASE/conservation/$NAME.filter10Mb
ls $NAME.filter10Mb/*.maf | while read MAF; do
    echo "Extract alignments from $MAF and rename sequences"
    REF=$(basename $MAF .maf)

    # Prepare the conversion command only for the sequences in the current MAF (to speed up the sed command)
    replace_cmd=""
    grep -wFf <(cut -f 2 $MAF | sed '1d') $DIR_BASE/conservation/name2species.tsv | while IFS=$'\t' read -r key val; do
        # \b: the word boundary ensures that the match occurs only if the pattern is followed by a non-word character or the end of the line.
        # It avoids that chm13#1#chr1 matches also chm13#1#chr10, chm13#1#chr11, ...
        replace_cmd+="s/$key\b/$val/;"
    done

    head -1 $MAF > $DIR_BASE/conservation/$NAME.filter10Mb/$REF.filtered.maf
    grep -f $DIR_BASE/data/haplotypes_to_consider.txt $MAF | sed $replace_cmd >> $DIR_BASE/conservation/$NAME.filter10Mb/$REF.filtered.maf
done
rm -rf $NAME.filter10Mb
```

Grid-search:

```shell
cd $DIR_BASE/conservation/$NAME.filter10Mb
lens=(1 $(seq 50 50 30000)) # The min. length is 1

for len in "${lens[@]}"; do 
    printf "${len}\n"
done > combinations.txt

ls $DIR_BASE/conservation/$NAME.filter10Mb/*.maf | while read MAF; do
    CHR_WITH_SUFFIX="${MAF##*#chr}"
    CHROMOSOME_NUM="${CHR_WITH_SUFFIX%%.*}"
    CHR="chr${CHROMOSOME_NUM}"
    echo $MAF $CHR

    DIR_OUTPUT=$DIR_BASE/conservation/$NAME.filter10Mb/$CHR
    mkdir -p $DIR_OUTPUT
    cd $DIR_OUTPUT
    zgrep "^$CHR" -w $DIR_BASE/data/chm13v2.0_RefSeq_Liftoff_v5.1.gff3.gz | grep 'exon' | sed "s/$CHR/Homo_sapiens/g" > $DIR_OUTPUT/$CHR.chm13.exon.gff
    sort -k1,1 -k4,4n $DIR_OUTPUT/$CHR.chm13.exon.gff | bedtools merge > $DIR_OUTPUT/$CHR.chm13.exon.bed
    $MSA_VIEW $MAF --in-format MAF --4d --features $DIR_OUTPUT/$CHR.chm13.exon.gff > $DIR_OUTPUT/$CHR.4d-codons.ss
    $MSA_VIEW $DIR_OUTPUT/$CHR.4d-codons.ss --in-format SS --out-format SS --tuple-size 1 > $DIR_OUTPUT/$CHR.4d-sites.ss
    $PHYLOFIT --tree $DIR_BASE/data/primate_tree.nwk --msa-format SS --out-root $DIR_OUTPUT/$CHR.4d $DIR_OUTPUT/$CHR.4d-sites.ss
    
    mkdir -p $DIR_OUTPUT/LOG
    mkdir -p $DIR_OUTPUT/ELEMENTS
    mkdir -p $DIR_OUTPUT/SCORES
    sbatch --partition=tux -x tux06 --array=1-$(wc -l < $DIR_BASE/conservation/$NAME.filter10Mb/combinations.txt)%192 --cpus-per-task=1 --output=$DIR_OUTPUT/LOG/slurm-%A_%a.log $DIR_BASE/scripts/phastCons.sh $PHASTCONS $DIR_BASE/conservation/$NAME.filter10Mb/combinations.txt $CHR $DIR_OUTPUT $MAF | awk '{print $4}' > job.jid
done
```

Collect results:

```shell
(seq 1 22; echo X; echo Y) | while read c; do
    CHR=chr$c
    echo $CHR
    cd $DIR_BASE/conservation/$NAME.filter10Mb/$CHR
    ls ELEMENTS/*bed |  while read BED; do
        len=$(basename $BED .bed | rev | cut -f 1 -d '.' | rev);
        tc=$(basename $BED .bed | rev | cut -f 2,3 -d '.' | rev);
        bedtoolsJaccard=$(bedtools jaccard -a $CHR.chm13.exon.bed -b <(sed "s/chm13#1#$CHR/Homo_sapiens/g" $BED | awk '{print $1"\t"$2"\t"$3}') | tail -n1)
        printf '%s\t' $len $tc ${bedtoolsJaccard[@]}
        printf '\n'
    done > $CHR.jaccards.tsv
done

(echo chr len tc jaccard; (seq 1 22; echo X; echo Y) | while read c; do
    CHR=chr$c
    sort -k 5,5n $CHR/*.jaccards.tsv | tail -n 1 | awk -v OFS='\t' -v chr=$CHR '{print(chr,$1,$2,$5)}'
done) | column -t
```
