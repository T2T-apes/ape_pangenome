library(tidyverse)
library(ggridges)
library(ggplot2)

exit()

source("stage_data_part1.R")

inter_df <- df[df$NAME != "hg002 vs. PanTro3", ]
inter_df <- inter_df[inter_df$NAME != "hg002 vs. PanPan1", ]
inter_df <- inter_df[inter_df$NAME != "hg002 vs. GorGor1", ]
inter_df <- inter_df[inter_df$NAME != "hg002 vs. GorGor1", ]
inter_df <- inter_df[inter_df$NAME != "hg002 vs. PonAbe1", ]
inter_df <- inter_df[inter_df$NAME != "hg002", ]
inter_df <- inter_df[inter_df$NAME != "PanPan1", ]
inter_df <- inter_df[inter_df$NAME != "PonAbe1", ]
inter_df <- inter_df[inter_df$NAME != "GorGor1", ]
inter_df <- inter_df[inter_df$NAME != "PanTro3", ]

# Update row names
levels(inter_df$NAME) <- list(PAB="PonAbe1 vs. hg002",
                              GGO="GorGor1 vs. hg002",
                              PTR="PanTro3 vs. hg002",
                              PPA="PanPan1 vs. hg002")

inter_df[, "DIV"] <- NA

columns <- colnames(inter_df)
new_inter_df <- data.frame(matrix(nrow=0, ncol=length(columns)))
colnames(new_inter_df) = columns

# Turn one row into three rows
for(i in 1:nrow(inter_df)) {
    print(i)
    #print(nrow(inter_df)) # 13,315
    name <- inter_df[i,]$NAME
    snv_div <- inter_df[i,]$DIFF
    gap_div <- inter_df[i,]$GAP_OTHER

    snv_row <- inter_df[i,]
    snv_row$NAME <- paste(name, "_SNV", sep="")
    snv_row$DIV <- snv_div

    gap_row <- inter_df[i,]
    gap_row$NAME <- paste(name, "_GAP", sep="")
    gap_row$DIV <- gap_div

    new_inter_df[nrow(new_inter_df) + 1,] <- snv_row
    new_inter_df[nrow(new_inter_df) + 1,] <- gap_row
}

write.csv(new_inter_df, file="interspecies_divergence.csv", row.names=FALSE)
