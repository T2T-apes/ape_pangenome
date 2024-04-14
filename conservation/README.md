
# Conservation

Set your paths:

```shell
DIR_BASE=/path/to/primates
PATH_PRIMATES16_FASTA=/path/to/primates16.20231205.fa.gz
PATH_PRIMATES16_CLEAN_FASTA=/path/to/primates/conservation/primates16.20231205.clean.fa
DIR_ALL_VS_TARGET_ALIGNMENTS=/path/to/primates/alignment/chm13#1.p70.aln.paf.gz

WGATOOLS=/path/to/wgatools/result/bin/wgatools
MAF_STREAM=/path/to/maf_stream/target/release/maf_stream
MSA_VIEW=/path/to/phast-v1_5/bin/msa_view
MSA_SPLIT=/path/to/tools/phast-v1_5/bin/msa_split
PHYLOFIT=/path/to/phast-v1_5/bin/phyloFit
PHYLOBOOT=/path/to/phast-v1_5/bin/phyloBoot
PHASTCONS=/path/to/phast-v1_5/bin/phastCons
WIGTOBIGWIG=/path/to/wigToBigWig
```

We need to:

- clean the FASTA file by removing special characters;
- prepare a table to rename sequences (from "sequence name" to "species name")
- prepare chromosome sizes for all haplotypes

```shell
mkdir -p $DIR_BASE/conservation
cd $DIR_BASE/conservation

# FASTA file without special characters
zcat $PATH_PRIMATES16_FASTA | sed -E  '/^[^>]/ s/[^ATGCNatgcn]/N/g' > $PATH_PRIMATES16_CLEAN_FASTA
samtools faidx $PATH_PRIMATES16_CLEAN_FASTA

# Table to rename sequences (sequence-name -> species-name)
join -1 1 -2 1 <(cat $DIR_BASE/data/genomes_lookup.csv | tr ',' '\t' | sort -k 1,1) <(cut -f 1 /lizardfs/guarracino/pggb-paper/assemblies/primates/primates16.20231205.fa.gz.fai | awk -F'#' -v OFS='\t' '{print $1"#"$2,$0}' | sort -k 1,1) | awk -v OFS='\t' '{print($3,$2)}' > $DIR_BASE/conservation/name2species.tsv

# Chromosome sizes
cut -f 1,2 $PATH_PRIMATES16_CLEAN_FASTA.fai > $DIR_BASE/conservation/chrom.sizes
```

From the all-vs-target alignments in PAF format:
- filter out alignments shorter than 10 megabases (Mb)
- convert the remaining alignments to MAF file format:
- extract alignments (by taking one haplotype for each species, but considering all sex chromosomes)
- rename sequences to match the names in the [primate_tree.nwk](../data/primate_tree.nwk) tree

```shell
ls $DIR_ALL_VS_TARGET_ALIGNMENTS/*.p70.aln.paf.gz | grep HPRCy1 -v | while read PATH_ALL_VS_TARGET_PAF; do
    NAME=$(basename $PATH_ALL_VS_TARGET_PAF .paf.gz)

    cd /scratch
    $WGATOOLS filter -f paf -a 10000000 <(zcat $PATH_ALL_VS_TARGET_PAF) -o $NAME.filter10Mb.paf -r -t 48
    $WGATOOLS pafpseudo $NAME.filter10Mb.paf -o $NAME.filter10Mb -r -f $PATH_PRIMATES16_CLEAN_FASTA -t 48
    rm $NAME.filter10Mb.paf

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

        cat $MAF | bgzip -l 9 -@ 96 > $DIR_BASE/conservation/$NAME.filter10Mb/$REF.filtered.all-haplotypes.maf.gz
    done
    rm -rf $NAME.filter10Mb
done
```

## Approach 1

```shell
mkdir -p $DIR_BASE/conservation/approach1
cd $DIR_BASE/conservation/approach1

#PATH_ALL_VS_TARGET_PAF=/lizardfs/guarracino/primates/alignment/chm13#1.p70.aln.paf.gz
PATH_ALL_VS_TARGET_PAF=/lizardfs/guarracino/primates/alignment/grch38#1.p70.aln.paf.gz
NAME=$(basename $PATH_ALL_VS_TARGET_PAF .paf.gz)

ls $DIR_BASE/conservation/$NAME.filter10Mb/*.maf | while read MAF; do
    MAF_NAME=$(basename $MAF .filtered.maf)
    echo $MAF $MAF_NAME

    DIR_OUTPUT=$DIR_BASE/conservation/approach1/$NAME.filter10Mb/$MAF_NAME
    mkdir -p $DIR_OUTPUT
    cd $DIR_OUTPUT

    # Fit the initial model
    $PHYLOFIT --tree $DIR_BASE/data/primate_tree.nwk --msa-format MAF --out-root $DIR_OUTPUT/init $MAF

    # Split the alignments into small fragments
    mkdir $DIR_OUTPUT/CHUNKS
    samtools faidx $PATH_PRIMATES16_CLEAN_FASTA $MAF_NAME > /scratch/$MAF_NAME.fa
    $MSA_SPLIT $MAF --in-format MAF --refseq /scratch/$MAF_NAME.fa --windows 1000000,0 --out-root $DIR_OUTPUT/CHUNKS/$MAF_NAME --out-format SS --min-informative 1000 --between-blocks 5000

    # Estimate parameters for each fragment
    gc=$(awk 'BEGIN {gc=0; seqlen=0} 
        /^>/ {next;} 
        {seqlen += length($0); gc += gsub(/[gcGC]/, "", $0);} 
        END {print gc/seqlen}' /scratch/$MAF_NAME.fa)
    rm /scratch/$MAF_NAME.fa
    echo $MAF_NAME $gc
    mkdir -p $DIR_OUTPUT/TREES $DIR_OUTPUT/LOG  # put estimated tree models here
    for file in $DIR_OUTPUT/CHUNKS/*.*.ss; do 
        root=`basename $file .ss` 
        sbatch -c 2 -p allnodes --wrap "hostname; $PHASTCONS --gc $gc --estimate-trees $DIR_OUTPUT/TREES/$root $file $DIR_OUTPUT/init.mod --no-post-probs"
    done
done

ls $DIR_BASE/conservation/$NAME.filter10Mb/*.maf | while read MAF; do
    MAF_NAME=$(basename $MAF .filtered.maf)
    echo $MAF $MAF_NAME

    DIR_OUTPUT=$DIR_BASE/conservation/approach1/$NAME.filter10Mb/$MAF_NAME
    cd $DIR_OUTPUT

    # Combine the separately estimated parameters by averaging
    ls $DIR_OUTPUT/TREES/*.cons.mod > $DIR_OUTPUT/cons.txt
    ls $DIR_OUTPUT/TREES/*.noncons.mod > $DIR_OUTPUT/noncons.txt
    $PHYLOBOOT --read-mods '*cons.txt' --output-average $DIR_OUTPUT/ave.cons.mod
    $PHYLOBOOT --read-mods '*noncons.txt' --output-average $DIR_OUTPUT/ave.noncons.mod 

    # Predict conserved elements and conservation scores globally using the combined estimates
    mkdir -p $DIR_OUTPUT/ELEMENTS $DIR_OUTPUT/SCORES
    for file in $DIR_OUTPUT/CHUNKS/*.*.ss ; do
        root=`basename $file .ss` 
        sbatch -c 2 -p allnodes --wrap="$PHASTCONS --most-conserved $DIR_OUTPUT/ELEMENTS/$root.bed --score $file $DIR_OUTPUT/ave.cons.mod,$DIR_OUTPUT/ave.noncons.mod > $DIR_OUTPUT/SCORES/$root.wig"
    done
done

# Combine results
ls $DIR_BASE/conservation/$NAME.filter10Mb/*.maf | while read MAF; do
    MAF_NAME=$(basename $MAF .filtered.maf)
    echo $MAF $MAF_NAME

    DIR_OUTPUT=$DIR_BASE/conservation/approach1/$NAME.filter10Mb/$MAF_NAME
    cd $DIR_OUTPUT

    cat $DIR_OUTPUT/ELEMENTS/*-*.bed | sort -k1,1 -k2,2n > $DIR_OUTPUT/ELEMENTS/$MAF_NAME.most_conserved.bed

    # Concatenate WIG files in coordinate order
    cd $DIR_OUTPUT/SCORES
    cat $(ls -1 *-*.wig | awk -F'[.-]' '{print $2"\t"$3"\t"$0}' | sort -nk1 | cut -f 3) > $MAF_NAME.wig
    cd ..

    $WIGTOBIGWIG $DIR_OUTPUT/SCORES/$MAF_NAME.wig $DIR_BASE/conservation/chrom.sizes $DIR_OUTPUT/SCORES/$MAF_NAME.bw
done
```

## Approach 2

Download CHM13v2.0 gene annotation:

```shell
mkdir -p $DIR_BASE/data
cd $DIR_BASE/data
wget -c https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/annotation/chm13v2.0_RefSeq_Liftoff_v5.1.gff3.gz
```

Grid-search:

```shell
mkdir -p $DIR_BASE/conservation/approach2
cd $DIR_BASE/conservation/approach2

lens=(1 $(seq 50 50 30000)) # The min. length can be 1
for len in "${lens[@]}"; do 
    printf "${len}\n"
done > combinations.txt

NAME=chm13#1.p70.aln

ls $DIR_BASE/conservation/$NAME.filter10Mb/*.maf | while read MAF; do
    CHR_WITH_SUFFIX="${MAF##*#chr}"
    CHROMOSOME_NUM="${CHR_WITH_SUFFIX%%.*}"
    CHR="chr${CHROMOSOME_NUM}"
    echo $MAF $CHR

    DIR_OUTPUT=$DIR_BASE/conservation/approach2/$NAME.filter10Mb/$CHR
    mkdir -p $DIR_OUTPUT
    cd $DIR_OUTPUT
    zgrep "^$CHR" -w $DIR_BASE/data/chm13v2.0_RefSeq_Liftoff_v5.1.gff3.gz | grep 'exon' | sed "s/$CHR/Homo_sapiens/g" > $DIR_OUTPUT/$CHR.chm13.exon.gff
    sort -k1,1 -k4,4n $DIR_OUTPUT/$CHR.chm13.exon.gff | bedtools merge > $DIR_OUTPUT/$CHR.chm13.exon.bed

    # chr2 has a too big MAF file, we need to process it differently'
    if [[ "$CHR" == "chr2" ]]; then
        # Chunk the MAF file in blocks 1 Mbp long
        $WGATOOLS chunk -l 1000000 $MAF -o xxx.maf

        # Divide the chunks in separated MAF files
        awk 'BEGIN {file="block00001.maf"} /^a score=/{file=sprintf("block%05d.maf", ++i)} {print > file}' xxx.maf

        # Remove sequences that have only gaps in the block
        ls block*.maf | while read MAF2; do
            PREFIX=$(basename $MAF2 .maf)
            echo $MAF2 $PREFIX

            awk '
                # If line starts with "s" and the sequence is only gaps, skip it
                /^s/ {
                    if ($7 ~ /^-+$/) next;
                }
                # Print all other lines
                { print }
            ' $MAF2 > filtered_$MAF2
        done

        ls filtered_block*.maf | while read MAF2; do
            PREFIX=$(basename $MAF2 .maf)
            echo $MAF2 $PREFIX
            
            $MSA_VIEW $MAF2 --in-format MAF --4d --features $DIR_OUTPUT/$CHR.chm13.exon.gff > $DIR_OUTPUT/$PREFIX.$CHR.4d-codons.ss
            $MSA_VIEW $DIR_OUTPUT/$PREFIX.$CHR.4d-codons.ss --in-format SS --out-format SS --tuple-size 1 > $DIR_OUTPUT/$PREFIX.$CHR.4d-sites.ss
        done
        find . -type f -name "filtered_block*.$CHR.4d-sites.ss" -size 0 -exec rm {} + # To avoid errors for the aggregation because of empty files
        # https://github.com/CshlSiepelLab/phast/issues/10#issuecomment-387370910
        $MSA_VIEW --unordered-ss --out-format SS --aggregate Homo_sapiens,Pongo_abelii,Pan_troglodytes,Pan_paniscus,Symphalangus_syndactylus,Pongo_pygmaeus,Gorilla_gorilla filtered_block*.$CHR.4d-sites.ss > $CHR.4d-sites.ss
    else
        $MSA_VIEW $MAF --in-format MAF --4d --features $DIR_OUTPUT/$CHR.chm13.exon.gff > $DIR_OUTPUT/$CHR.4d-codons.ss
        $MSA_VIEW $DIR_OUTPUT/$CHR.4d-codons.ss --in-format SS --out-format SS --tuple-size 1 > $DIR_OUTPUT/$CHR.4d-sites.ss
    fi
    $PHYLOFIT --tree $DIR_BASE/data/primate_tree.nwk --msa-format SS --out-root $DIR_OUTPUT/$CHR.4d $DIR_OUTPUT/$CHR.4d-sites.ss
    
    mkdir -p $DIR_OUTPUT/LOG
    mkdir -p $DIR_OUTPUT/ELEMENTS
    mkdir -p $DIR_OUTPUT/SCORES
    sbatch --partition=tux -x tux06 --array=1-$(wc -l < $DIR_BASE/conservation/approach2/combinations.txt)%192 --cpus-per-task=1 --output=$DIR_OUTPUT/LOG/slurm-%A_%a.log $DIR_BASE/scripts/phastCons.sh $PHASTCONS $DIR_BASE/conservation/approach2/combinations.txt $CHR $DIR_OUTPUT $MAF | awk '{print $4}' > job.jid
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

# See the winning combinations
(echo chr len tc jaccard; (seq 1 22; echo X; echo Y) | while read c; do
    CHR=chr$c
    sort -k 5,5n $CHR/*.jaccards.tsv | tail -n 1 | awk -v OFS='\t' -v chr=$CHR '{print(chr,$1,$2,$5)}'
done) | column -t
    # chr    len    tc    jaccard
    # chr1   100    0.50  0.119494
    # chr2   50     0.50  0.102332
    # chr3   100    0.50  0.112459
    # chr4   50     0.50  0.0955686
    # chr5   50     0.50  0.0909732
    # chr6   50     0.50  0.109537
    # chr7   100    0.05  0.0909672
    # chr8   50     0.15  0.0940339
    # chr9   1500   0.05  0.103596
    # chr10  200    0.50  0.106136
    # chr11  50     0.50  0.118712
    # chr12  350    0.50  0.129967
    # chr13  25550  0.55  0.143974
    # chr14  50     0.50  0.0949572
    # chr15  50     0.50  0.107186
    # chr16  50     0.05  0.0963623
    # chr17  50     0.25  0.117952
    # chr18  150    0.50  0.0960978
    # chr19  400    0.50  0.160333
    # chr20  1750   0.05  0.103978
    # chr21  29650  0.55  0.170273
    # chr22  50     0.45  0.0971152
    # chrX   200    0.50  0.137221
    # chrY   250    0.35  0.0461294
```

Compute the final tracks:

```shell
ls $DIR_BASE/conservation/$NAME.filter10Mb/*.maf | sort -V | while read MAF; do
    MAF_NAME=$(basename $MAF .filtered.maf)

    CHR_WITH_SUFFIX="${MAF##*#chr}"
    CHROMOSOME_NUM="${CHR_WITH_SUFFIX%%.*}"
    CHR="chr${CHROMOSOME_NUM}"
    echo $MAF $CHR

    DIR_OUTPUT=$DIR_BASE/conservation/approach2/$NAME.filter10Mb/$CHR

    len=$(sort -k 5,5n $DIR_OUTPUT/*.jaccards.tsv | tail -n 1 | cut -f 1)
    tc=$(sort -k 5,5n $DIR_OUTPUT/*.jaccards.tsv | tail -n 1 | cut -f 2)

    sbatch -c 96 -p tux --wrap "hostname; cd $DIR_BASE/conservation/approach2; $PHASTCONS --most-conserved $DIR_OUTPUT/ELEMENTS/$CHR.conserved.$tc.$len.bed --target-coverage $tc --expected-length $len --rho 0.3 --msa-format MAF $MAF $DIR_OUTPUT/$CHR.4d.mod > $DIR_OUTPUT/SCORES/$MAF_NAME.scores.$tc.$len.wig; $WIGTOBIGWIG $DIR_OUTPUT/SCORES/$MAF_NAME.scores.$tc.$len.wig $DIR_BASE/conservation/chrom.sizes $DIR_OUTPUT/SCORES/$MAF_NAME.scores.$tc.$len.bw; bgzip -l 9 -@ 48 $DIR_OUTPUT/SCORES/$MAF_NAME.scores.$tc.$len.wig"
done
```

Combine:

```shell
mkdir -p $DIR_BASE/conservation/approach2/$NAME.filter10Mb/COMBINED
ls $DIR_BASE/conservation/approach2/$NAME.filter10Mb/chr*/SCORES/*wig.gz | sort -V | while read WIG; do
    zcat $WIG
done > $DIR_BASE/conservation/approach2/$NAME.filter10Mb/COMBINED/$NAME.score.wig
$WIGTOBIGWIG $DIR_BASE/conservation/approach2/$NAME.filter10Mb/COMBINED/$NAME.score.wig $DIR_BASE/conservation/chrom.sizes $DIR_BASE/conservation/approach2/$NAME.filter10Mb/COMBINED/$NAME.score.bw

ls $DIR_BASE/conservation/$NAME.filter10Mb/*.maf | sort -V | while read MAF; do
    MAF_NAME=$(basename $MAF .filtered.maf)

    CHR_WITH_SUFFIX="${MAF##*#chr}"
    CHROMOSOME_NUM="${CHR_WITH_SUFFIX%%.*}"
    CHR="chr${CHROMOSOME_NUM}"
    echo $MAF $CHR

    DIR_OUTPUT=$DIR_BASE/conservation/approach2/$NAME.filter10Mb/$CHR

    len=$(sort -k 5,5n $DIR_OUTPUT/*.jaccards.tsv | tail -n 1 | cut -f 1)
    tc=$(sort -k 5,5n $DIR_OUTPUT/*.jaccards.tsv | tail -n 1 | cut -f 2)

    zcat $DIR_OUTPUT/ELEMENTS/$CHR.conserved.$tc.$len.bed
done | bgzip -l 9 -@ 38 > $DIR_BASE/conservation/approach2/$NAME.filter10Mb/COMBINED/$NAME.conserved.bed.gz
```

## Results

Conservation tracks and conserved elements can be found for the
- approach 1 at https://garrisonlab.s3.amazonaws.com/index.html?prefix=t2t-primates/wfmash-v0.13.0/conservation_approach1/
- approach 2 at https://garrisonlab.s3.amazonaws.com/index.html?prefix=t2t-primates/wfmash-v0.13.0/conservation_approach2/
