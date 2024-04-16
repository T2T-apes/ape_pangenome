import argparse
import gzip
import pandas
import subprocess
import sys


def read_seq_from_maf(maf, hap):
    with gzip.open(maf, 'r') as fin:
        for i, line in enumerate(fin):
            # sys.stdout.write("Processing MAF line %d\n" % i)
            text = line[:100].decode("utf-8")
            if text[0] == "s":
                if text.find(hap) > 0:
                    sys.stdout.write("Found %s\n" % hap)

                    text = line.decode("utf-8")
                    words = text.split()
                    nam = words[1]
                    seq = words[-1]

                    return [nam, seq]
    
    sys.stdout.write("%s not found!\n" % hap)


def read_seq_from_fasta(fasta, hap):
    with open(fasta, 'r') as fin:
        found = False
        for line in fin:
            if line[0] == ">":
                if found:
                    return [nam, seq]
                if line.find(hap) > 0:
                    sys.stdout.write("Found %s\n" % line)
                    nam = line[1:].split()[0]
                    seq = ""
                    found = True
            elif line[0] == "=":
                # MUGSY MAF 2 FAS conversion
                if found:
                    return [nam, seq]
            else:
                if found:
                    seq += line.strip()

    if found:
        return [nam, seq]
    
    sys.stdout.write("%s not found!\n" % hap)


def not_nucleotide(ch):
    if (ch == "-") or (ch == "?") or (ch == "N"):
        return True
    return False


def compute_binned_div(seq1, seq2, fout,
                       nam1="NA", nam2="NA", xchr="NA", bsize=1000000):
    npos1 = len(seq1)
    npos2 = len(seq2)
    if npos1 != npos2:
        sys.exit("Sequences are not the same length %d vs %d!" % (npos1, npos2))

    binned_div = []

    bins = [x for x in range(0, npos1, bsize)]
    for s in bins:
        sys.stdout.write("Processing chr %s bin %d / %d\n" % (xchr, s, npos1))
        e = s + bsize

        nmr = 0
        nbg = 0
        n1g = 0
        n2g = 0
        ndf = 0
        nsm = 0

        for c1, c2 in zip(seq1[s:e], seq2[s:e]):
            x1 = c1.upper()
            x2 = c2.upper()
            not1 = not_nucleotide(x1)
            not2 = not_nucleotide(x2)

            if not1 and not2:
                nbg += 1
            elif not1:
                n1g += 1
            elif not2:
                n2g += 1
            else:
                if x1 != x2:
                    ndf += 1
                else:
                    nsm += 1

        bnsz = len(seq1[s:e])
        gapb = nbg / bnsz  # Should always be 0; unless there are N's in Ref
        gap1 = n1g / bnsz  # Should always be 0; unless there are N's in Ref
        gap2 = n2g / bnsz
        nnuc = (ndf + nsm)
        gap0 = nnuc / bnsz
        if nnuc > 0:
            diff = str("%f" % (ndf / nnuc))
            same = str("%f" % (nsm / nnuc))
        else:
            diff = "NA"
            same = "NA"

        fout.write("%s,%s,%s,%d,%d,%d,%f,%f,%f,%f,%s,%s\n" % \
                   (nam1, nam2, xchr, s + 1, e, bnsz, gapb, gap1, gap2, gap0, diff, same))


def run_same_species(mafpath, base, hap1, hap2, maxchr):
    output = "basic-div-" + base + "-" + hap1 + "-vs-" + hap2 + "-autosomes.csv"
    with open(output, 'w') as fout:
        fout.write("NAME_REF,NAME_OTHER,CHR,BIN_START,BIN_END,BIN_SIZE,GAP_BOTH,GAP_REF,GAP_OTHER,GAP_NONE,DIFF,SAME\n")
        for xchr in range(1, maxchr + 1):
            command = "ls " + mafpath + "/" + base + "/" + base + "#chr" + str(xchr) + "_*.filtered10Mb.maf.gz"
            maf = subprocess.check_output(command, shell=True, text=True)
            maf = maf.strip()

            [nam1, seq1] = read_seq_from_maf(maf, hap1)
            [nam2, seq2] = read_seq_from_maf(maf, hap2)

            compute_binned_div(seq1, seq2, fout, nam1=nam1, nam2=nam2, xchr=str(xchr), bsize=1000000)


def run_diff_species(mafpath, base, hap1, hap2, maxchr):
    output = "basic-div-" + base + "-" + hap1 + "-vs-" + hap2 + "-autosomes.csv"
    with open(output, 'w') as fout:
        fout.write("NAME_REF,NAME_OTHER,CHR,BIN_START,BIN_END,BIN_SIZE,GAP_BOTH,GAP_REF,GAP_OTHER,GAP_NONE,DIFF,SAME\n")
        for xchr in range(1, maxchr + 1):
            command = "ls " + mafpath + "/" + base + "/" + base + "#chr" + str(xchr) + "_*.filtered10Mb.maf.gz"
            maf = subprocess.check_output(command, shell=True, text=True)
            maf = maf.strip()

            [nam1, seq1] = read_seq_from_maf(maf, hap1)
            [nam2, seq2] = read_seq_from_maf(maf, hap2)

            compute_binned_div(seq1, seq2, fout, nam1=nam1, nam2=nam2, xchr=str(xchr), bsize=1000000)

def run_diff_species_X(mafpath, base, hap1, hap2, maxchr):
    output = "basic-div-" + base + "-" + hap1 + "-vs-" + hap2 + "-X.csv"
    with open(output, 'w') as fout:
        fout.write("NAME_REF,NAME_OTHER,CHR,BIN_START,BIN_END,BIN_SIZE,GAP_BOTH,GAP_REF,GAP_OTHER,GAP_NONE,DIFF,SAME\n")
        command = "ls " + mafpath + "/" + base + "/" + base + "#chrX_*.filtered10Mb.maf.gz"
        maf = subprocess.check_output(command, shell=True, text=True)
        maf = maf.strip()

        [nam1, seq1] = read_seq_from_maf(maf, hap1)
        [nam2, seq2] = read_seq_from_maf(maf, hap2)

        compute_binned_div(seq1, seq2, fout, nam1=nam1, nam2=nam2, xchr="X", bsize=1000000)

def run_diff_species_Y(mafpath, base, hap1, hap2, maxchr):
    output = "basic-div-" + base + "-" + hap1 + "-vs-" + hap2 + "-Y.csv"
    with open(output, 'w') as fout:
        fout.write("NAME_REF,NAME_OTHER,CHR,BIN_START,BIN_END,BIN_SIZE,GAP_BOTH,GAP_REF,GAP_OTHER,GAP_NONE,DIFF,SAME\n")
        command = "ls " + mafpath + "/" + base + "/" + base + "#chrY_*.filtered10Mb.maf.gz"
        maf = subprocess.check_output(command, shell=True, text=True)
        maf = maf.strip()

        [nam1, seq1] = read_seq_from_maf(maf, hap1)
        [nam2, seq2] = read_seq_from_maf(maf, hap2)

        compute_binned_div(seq1, seq2, fout, nam1=nam1, nam2=nam2, xchr="Y", bsize=1000000)


def main(args):
    mafpath = args.mafpath
    runset = set(args.runlist)

    # Process hg002M vs. hg002P (through hg002M; can't include X or Y)
    if 0 in runset:
        run_same_species(mafpath, "hg002#M", "hg002#M", "hg002#P", 22)

    # Process mPanTro3#1 vs. mPanTro3#2 (through mPanTro3#1; can't include X or Y)
    if 1 in runset:
        run_same_species(mafpath, "mPanTro3#1", "mPanTro3#1", "mPanTro3#2", 23)

    # Process mPanPan1#M vs. mPanPan1#P (through mPanTro3#1; can't include X or Y)
    if 2 in runset:
        run_same_species(mafpath, "mPanPan1#M", "mPanPan1#M", "mPanPan1#P", 23)

    # Process mGorGor1#M vs. mGorGor1#P (through mPanTro3#1; can't include X or Y)
    if 3 in runset:
        run_same_species(mafpath, "mGorGor1#M", "mGorGor1#M", "mGorGor1#P", 23)

    # Process mPonAbe1#1 vs. mPonAbe1#2 (through mPonAbe1#1; can't include X or Y)
    if 4 in runset:
        run_same_species(mafpath, "mPonAbe1#1", "mPonAbe1#1", "mPonAbe1#2", 23)

    nextrun = 5
    mhaps = ["mPanTro3#1", "mPanPan1#M", "mGorGor1#M", "mPonAbe1#1"]
    phaps = ["mPanTro3#2", "mPanPan1#P", "mGorGor1#P", "mPonAbe1#2"]

    for mhap, phap in zip(mhaps, phaps):
        if nextrun in runset:
            run_diff_species(mafpath, "hg002#M", "hg002#M", mhap, 22)
            run_diff_species_X(mafpath, "hg002#M", "hg002#M", mhap, 22)
            run_diff_species_Y(mafpath, "hg002#P", "hg002#P", phap, 22)
        nextrun += 1

        if nextrun in runset:
            run_diff_species(mafpath, mhap, mhap, "hg002#M", 23)
            run_diff_species_X(mafpath, mhap, mhap, "hg002#M", 23)
            run_diff_species_Y(mafpath, phap, phap, "hg002#P", 23)

        nextrun += 1


# module load Python3/3.10.10


if __name__=="__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument("-r", "--runlist", type=int, nargs="+",
                        help="List of jobs to run",
                        required=True)

    parser.add_argument("-p", "--mafpath", type=str, 
                        help="Path to MAF files",
                        required=True)

    main(parser.parse_args())
