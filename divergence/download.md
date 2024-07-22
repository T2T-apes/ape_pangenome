# Download information
----------------------

Download and install AWS commandline tools.
```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install --bin-dir ~/.local/bin/ --install-dir ~/.local/aws-cli
aws --version
```

Make an AWS account here: [https://aws.amazon.com/](https://aws.amazon.com/).

Configure your keys in the AWS commandline tools.
```
aws configure 
```
and then enter the keys (first two lines) and then just click enter for others.

Download data from [AWS](https://garrisonlab.s3.amazonaws.com/index.html?prefix=t2t-primates/wfmash-v0.13.0/).
```
NAMES=( "chm13#1" \
        "hg002#M"    "hg002#P" \
        "mPanTro3#1" "mPanTro3#2" \
        "mPanPan1#M" "mPanPan1#P" \
        "mGorGor1#M" "mGorGor1#P" \
        "mPonAbe1#1" "mPonAbe1#2" \
        "mPonPyg2#1" "mPonPyg2#2" )
```

Download alignments (PAFs).
```
mkdir alignments
cd alignments
for NAME in ${NAMES[@]}; do
    aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/alignments/${NAME}.p70.aln.paf.gz .
done
cd ..
```

Download chains.
```
mkdir chains
cd chains
for NAME in ${NAMES[@]}; do
    aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/chains/${NAME}.p70.aln.chain.gz .
done
cd ..
```

Download mappings.
```
mkdir mappings
cd mappings
for NAME in ${NAMES[@]}; do
    aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mappings/${NAME}.p70.map.paf.gz .
done
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
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/ . --recursive  --exclude "*" --include "chm13#1*filtered10Mb.maf.gz"
rm *chrM*
cd ..
```

```
mkdir hg002#M
cd hg002#M
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/ . --recursive  --exclude "*" --include "hg002#M*filtered10Mb.maf.gz"
rm *chrM*
cd ..

mkdir hg002#P
cd hg002#P
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/hg002#P#chrY_PATERNAL.filtered10Mb.maf.gz .
cd ..
```

```
mkdir mPanTro3#1
cd mPanTro3#1
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/ . --recursive  --exclude "*" --include "mPanTro3#1*filtered10Mb.maf.gz"
cd ..

mkdir mPanTro3#2
cd mPanTro3#2
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPanTro3#2#chrY_hap2_hsaY.filtered10Mb.maf.gz .
cd ..
```


```
mkdir mPanPan1#M
cd mPanPan1#M
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/ . --recursive  --exclude "*" --include "mPanPan1#M*filtered10Mb.maf.gz"
cd ..

mkdir mPanPan1#P
cd mPanPan1#P
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPanPan1#P#chrY_pat_hsaY.filtered10Mb.maf.gz .
cd ..
```


```
mkdir mGorGor1#M
cd mGorGor1#M
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/ . --recursive  --exclude "*" --include "mGorGor1#M*filtered10Mb.maf.gz"
cd ..

mkdir mGorGor1#P
cd mGorGor1#P
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mGorGor1#P#chrY_pat_hsaY.filtered10Mb.maf.gz .
cd ..
```

```
mkdir mPonAbe1#1
cd mPonAbe1#1
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/ . --recursive  --exclude "*" --include "mPonAbe1#1*filtered10Mb.maf.gz"
cd ..

mkdir mPonAbe1#2
cd mPonAbe1#2
aws s3 cp s3://garrisonlab/t2t-primates/wfmash-v0.13.0/mafs/mPonAbe1#2#chrY_hap2_hsaY.filtered10Mb.maf.gz .
cd ..
```
