# alignment and chains

Set your paths:

```shell
DIR_BASE=/path/to/primates
PATH_PRIMATES16_FASTA=/path/to/primates16.20240512.fa.gz
WFMASH=/path/to/wfmash/build/bin/wfmash-d7b696087f634f25e4b3de7dd521e1c4bfa3cf0e # wfmash v0.13.0, commit d7b696087f634f25e4b3de7dd521e1c4bfa3cf0e
PAF2CHAIN=/path/to/paf2chain/target/release/paf2chain
```

## primates-vs-primates

### Mapping

To achieve an all-vs-all mapping across the entire set of genomes, we apply an iterative all-vs-one approach. We maps all genomes against a single target genome at a time. This process is repeated for each genome in the dataset. This strategy breaks down the computationally intensive all-vs-all mapping into more manageable all-vs-one steps, enabling efficient parallel processing.

```shell
mkdir -p $DIR_BASE/mapping
cd $DIR_BASE/mapping

cut -f 1,2 $PATH_PRIMATES16_FASTA.fai -d '#' | sort | uniq | while read TARGET; do
    PREFIX="$TARGET#"
    echo $PREFIX

    sbatch -c 48 -p allnodes --job-name "primates-vs-$TARGET-p70-mapping" --wrap "hostname; \
        $WFMASH -t 48 \
        -m \
        -P $PREFIX \
        --one-to-one \
        -Y '#' \
        -n 1 \
        -p 70 \
        -s 5k \
        -c 20k \
        $PATH_PRIMATES16_FASTA \
        > $DIR_BASE/mapping/$TARGET.p70.map.paf \
        2> $DIR_BASE/mapping/$TARGET.p70.map.log"
done
```

We use `mashmap3`, integrated in [`wfmash`](https://github.com/waveygang/wfmash) and invoked with the `-m` parameter. Each iteration works by splitting each query genome into overlapping 5kb segments (`-s`) and mapping each segment to the current target. The mappings are then filtered to keep only those with >70% identity (`-p`) and a cumulative length >20kb (`-c`).

Upload on `garrisonlab` bucket:

```shell
pigz -9
ls *p70*.paf.gz | while read f; do echo $f; aws s3 cp $f s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mapings_fixedSiamang/$f; done
```

### Alignment

We use the mapping PAF files generated in the previous step as input to guide the alignment process in `wfmash`. This results in aligned PAF files for each target sequence which include CIGAR strings (in the same format that can be obtained with `minimap2 --eqx`) usable in `rustybam`, `seqwish`, and other tools.

```shell
mkdir -p $DIR_BASE/alignment
cd $DIR_BASE/alignment

cut -f 1,2 $PATH_PRIMATES16_FASTA.fai -d '#' | sort | uniq | while read TARGET; do
    PREFIX="$TARGET#"
    echo $PREFIX

    sbatch -c 48 -p allnodes --job-name "primates-vs-$TARGET-p70-alignment" --wrap "hostname; \
        $WFMASH -t 48 \
        -i $DIR_BASE/mapping/$TARGET.p70.map.paf \
        -P $PREFIX \
        --one-to-one \
        -Y '#' \
        -n 1 \
        -p 70 \
        -s 5k \
        -c 20k \
        $PATH_PRIMATES16_FASTA \
        > $DIR_BASE/alignment/$TARGET.p70.aln.paf \
        2> $DIR_BASE/alignment/$TARGET.p70.aln.log"
done
```

Upload on `garrisonlab` bucket:

```shell
pigz -9
ls *p70*.paf.gz | while read f; do echo $f; aws s3 cp $f s3://garrisonlab/t2t-primates/wfmash-v0.13.0/alignments_fixedSiamang/$f; done
```

### Chains

We use [`paf2chain`](https://github.com/AndreaGuarracino/paf2chain) to convert aligned PAF files into CHAIN files:

```shell
cd $DIR_BASE/alignment
ls $DIR_BASE/alignment/*.p70.*.paf.gz | while read PAF; do
    NAME=$(basename $PAF .paf.gz)
    echo $NAME

    $PAF2CHAIN --input $PAF | pigz -9 > $NAME.chain.gz
done
```

Upload on `garrisonlab` bucket:

```shell
ls *p70*.chain.gz | while read f; do echo $f; aws s3 cp $f s3://garrisonlab/t2t-primates/wfmash-v0.13.0/chains_fixedSiamang/$f; done
```

## HPRCy1-vs-primates

Prepare:

```shell
cat /lizardfs/erikg/HPRC/year1v2genbank/assemblies/*v2_genbank.fa <(zcat /lizardfs/erikg/HPRC/year1v2genbank/assemblies/HG02080.paternal.f1_assembly_v2_genbank.fa.gz) <(zcat /lizardfs/guarracino/pggb-paper/assemblies/primates/primates16.20240512.fa.gz) | bgzip -l 9 -@ 128 > /lizardfs/guarracino/HPRC/HPRCy1+primates16.fa.gz && samtools faidx /lizardfs/guarracino/HPRC/HPRCy1+primates16.fa.gz
```

### Mapping

```shell
cd $DIR_BASE/mapping

cut -f 1,2 $PATH_PRIMATES16_FASTA.fai -d '#' | sort | uniq | while read TARGET; do
    PREFIX="$TARGET#"
    echo $PREFIX

    for p in 70; do
        sbatch -c 96 -p tux --job-name "HPRCy1-vs-$TARGET-p$p-mapping" --wrap "hostname; \
            \time -v $WFMASH -t 96 \
            -m \
            -P $PREFIX \
            --one-to-one \
            -Y '#' \
            -n 1 \
            -p $p \
            -s 5k \
            -c 20k \
            /lizardfs/guarracino/HPRC/HPRCy1+primates16.fa.gz \
            > $DIR_BASE/mapping/HPRCy1-vs-$TARGET.p$p.map.paf \
            2> $DIR_BASE/mapping/HPRCy1-vs-$TARGET.p$p.map.log"
    done
done
```

Upload on `garrisonlab` bucket:

```shell
pigz -9 *paf
ls HPRCy1-vs-*.paf.gz | while read f; do echo $f; aws s3 cp $f s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mappings_fixedSiamang/$f; done
```

### Alignment

```shell
cd $DIR_BASE/alignment

cut -f 1,2 $PATH_PRIMATES16_FASTA.fai -d '#' | sort | uniq | while read TARGET; do
    PREFIX="$TARGET#"
    echo $PREFIX

    for p in 70; do
        sbatch -c 96 -p tux --job-name "HPRCy1-vs-$TARGET-p$p-alignment" --wrap "hostname; \
            \time -v $WFMASH -t 96 \
            -i $DIR_BASE/mapping/HPRCy1-vs-$TARGET.p$p.map.paf \
            -P $PREFIX \
            --one-to-one \
            -Y '#' \
            -n 1 \
            -p $p \
            -s 5k \
            -c 20k \
            /lizardfs/guarracino/HPRC/HPRCy1+primates16.fa.gz \
            > $DIR_BASE/alignment/HPRCy1-vs-$TARGET.p$p.aln.paf \
            2> $DIR_BASE/alignment/HPRCy1-vs-$TARGET.p$p.aln.log"
    done
done
```

Upload on `garrisonlab` bucket:

```shell
pigz -9 *paf
ls HPRCy1-vs-*.paf.gz | while read f; do echo $f; aws s3 cp $f s3://garrisonlab/t2t-primates/wfmash-v0.13.0/alignments_fixedSiamang/$f; done
```

### Chains

```shell
cd $DIR_BASE/alignment
cut -f 1,2 $PATH_PRIMATES16_FASTA.fai -d '#' | sort | uniq | while read TARGET; do
    PREFIX="$TARGET#"
    echo $PREFIX

    $PAF2CHAIN --input $DIR_BASE/alignment/HPRCy1-vs-$TARGET.p$p.aln.paf | pigz -9 > $DIR_BASE/alignment/HPRCy1-vs-$TARGET.p$p.aln.chain.gz
done
```

Upload on `garrisonlab` bucket:

```shell
ls HPRCy1-vs-*.chain.gz | while read f; do echo $f; aws s3 cp $f s3://garrisonlab/t2t-primates/wfmash-v0.13.0/chains_fixedSiamang/$f; done
```

## Results

You can find:
- the mapping PAF files at https://garrisonlab.s3.amazonaws.com/index.html?prefix=t2t-primates/wfmash-v0.13.0/mappings_fixedSiamang/
- the aligned PAF files at https://garrisonlab.s3.amazonaws.com/index.html?prefix=t2t-primates/wfmash-v0.13.0/alignments_fixedSiamang/ 
- the CHAIN files at https://garrisonlab.s3.amazonaws.com/index.html?prefix=t2t-primates/wfmash-v0.13.0/chains_fixedSiamang/ 
- the MAF files at https://garrisonlab.s3.amazonaws.com/index.html?prefix=t2t-primates/wfmash-v0.13.0/mafs_fixedSiamang/ 
