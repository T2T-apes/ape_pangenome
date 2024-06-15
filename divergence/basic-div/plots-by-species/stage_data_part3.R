library(tidyverse)
library(ggridges)
library(ggplot2)

#exit()

source("stage_data_part1.R")

intra_df <- df[df$NAME != "hg002", ]
intra_df <- intra_df[intra_df$NAME != "hg002 vs. PanTro3", ]
intra_df <- intra_df[intra_df$NAME != "hg002 vs. PanPan1", ]
intra_df <- intra_df[intra_df$NAME != "hg002 vs. GorGor1", ]
intra_df <- intra_df[intra_df$NAME != "hg002 vs. GorGor1", ]
intra_df <- intra_df[intra_df$NAME != "hg002 vs. PonAbe1", ]
intra_df <- intra_df[intra_df$NAME != "PanPan1 vs. hg002", ]
intra_df <- intra_df[intra_df$NAME != "PonAbe1 vs. hg002", ]
intra_df <- intra_df[intra_df$NAME != "GorGor1 vs. hg002", ]
intra_df <- intra_df[intra_df$NAME != "PanTro3 vs. hg002", ]

levels(intra_df$NAME) <- list(PAB="PonAbe1",
                              GGO="GorGor1",
                              PTR="PanTro3",
                              PPA="PanPan1")

intra_df[, "DIV"] <- NA

columns <- colnames(intra_df)
new_intra_df <- data.frame(matrix(nrow=0, ncol=length(columns)))
colnames(new_intra_df) = columns

# Turn one row into three rows
for(i in 1:nrow(intra_df)) {
    print(i)
    #print(nrow(intra_df)) # 12,439
    name <- intra_df[i,]$NAME
    snv_div <- intra_df[i,]$DIFF
    gap_div <- intra_df[i,]$GAP_OTHER

    snv_row <- intra_df[i,]
    snv_row$NAME <- paste(name, "_SNV", sep="")
    snv_row$DIV <- snv_div

    gap_row <- intra_df[i,]
    gap_row$NAME <- paste(name, "_GAP", sep="")
    gap_row$DIV <- gap_div

    new_intra_df[nrow(new_intra_df) + 1,] <- snv_row
    new_intra_df[nrow(new_intra_df) + 1,] <- gap_row
}

write.csv(new_intra_df, file="intraspecies_divergence.csv", row.names=FALSE)
