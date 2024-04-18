

| CSV Column Name   | Meaning |
| -------- | ------- |
| NAME_REF  | Name of reference or target haplotype (meaning the other haplotype is aligned to the target) |
| NAME_OTHER | Name of other haplotype |
| CHR    | chromosome information |
| BIN_START | start position of bin / window |
| BIN_END | end position of bin / window |
| BIN_SIZE | `BIN_END - BIN_START + 1` (should be 1Mb except at end of chrosome) |
| GAP_BOTH | fraction of positions in window where BOTH haplotypes are in state `N`, `?`, or `-` (note that the `REF` haplotype should not be in state `-` because of the alignment procedure)  |
| GAP_REF | fraction of positions in window where ONLY the `NAME_REF` is in state `N`, `?`, or `-` (note that the `REF` haplotype should never be in state `-` based on the alignment procedure) |
| GAP_OTHER | fraction of positions in window where ONLY `NAME_OTHER` is in state `N`, `?`, or `-` |
| GAP_NONE | fraction of positions in window where BOTH haplotypes are NOT in state `N`, `?`, or `-` |
| DIFF | fraction of positions in window where BOTH haplotypes are NOT in state `N`, `?`, or `-` AND the haplotypes are in DIFFERENT states  |
| SAME | fraction of positions in window where BOTH haplotypes are NOT in state `N`, `?`, or `-` AND the haplotypes are in the SAME states  |
