library(plyr)
library(dplyr)

## Stage data, which is annoaying because didn't think it through when generating CSVs

# Primate vs. Same Primate
intra_df1 <- read.csv("../basic-div-hg002#M-hg002#M-vs-hg002#P-autosomes.csv",
                header=TRUE, row.names=NULL, sep=',')
intra_df1$NAME = "hg002"

intra_df2 <- read.csv("../basic-div-mPanTro3#1-mPanTro3#1-vs-mPanTro3#2-autosomes.csv",
                header=TRUE, row.names=NULL, sep=',')
intra_df2$NAME = "PanTro3"

intra_df3 <- read.csv("../basic-div-mPanPan1#M-mPanPan1#M-vs-mPanPan1#P-autosomes.csv",
                header=TRUE, row.names=NULL, sep=',')
intra_df3$NAME = "PanPan1"

intra_df4 <- read.csv("../basic-div-mGorGor1#M-mGorGor1#M-vs-mGorGor1#P-autosomes.csv",
                header=TRUE, row.names=NULL, sep=',')
intra_df4$NAME = "GorGor1"

intra_df5 <- read.csv("../basic-div-mPonAbe1#1-mPonAbe1#1-vs-mPonAbe1#2-autosomes.csv",
                header=TRUE, row.names=NULL, sep=',')
intra_df5$NAME = "PonAbe1"

intra_df6 <- read.csv("../basic-div-mPonPyg2#1-mPonPyg2#1-vs-mPonPyg2#2-autosomes.csv",
                header=TRUE, row.names=NULL, sep=',')
intra_df6$NAME = "mPonPyg2"

# Human vs. Chimp
df1a <- read.csv("../basic-div-hg002#M-hg002#M-vs-mPanTro3#1-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df1x <- read.csv("../basic-div-hg002#M-hg002#M-vs-mPanTro3#1-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df1y <- read.csv("../basic-div-hg002#P-hg002#P-vs-mPanTro3#2-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df1 = rbind(df1a, df1x, df1y)
df1$NAME = "hg002 vs. PanTro3"

# Chimp vs. Human
df2a <- read.csv("../basic-div-mPanTro3#1-mPanTro3#1-vs-hg002#M-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df2x <- read.csv("../basic-div-mPanTro3#1-mPanTro3#1-vs-hg002#M-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df2y <- read.csv("../basic-div-mPanTro3#2-mPanTro3#2-vs-hg002#P-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df2 = rbind(df2a, df2x, df2y)
df2$NAME = "PanTro3 vs. hg002"

# Human vs. Bonobo
df3a <- read.csv("../basic-div-hg002#M-hg002#M-vs-mPanPan1#M-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df3x <- read.csv("../basic-div-hg002#M-hg002#M-vs-mPanPan1#M-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df3y <- read.csv("../basic-div-hg002#P-hg002#P-vs-mPanPan1#P-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df3 = rbind(df3a, df3x, df3y)
df3$NAME = "hg002 vs. PanPan1"

# Bonobo vs. Human
df4a <- read.csv("../basic-div-mPanPan1#M-mPanPan1#M-vs-hg002#M-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df4x <- read.csv("../basic-div-mPanPan1#M-mPanPan1#M-vs-hg002#M-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df4y <- read.csv("../basic-div-mPanPan1#P-mPanPan1#P-vs-hg002#P-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df4 = rbind(df4a, df4x, df4y)
df4$NAME = "PanPan1 vs. hg002"

# Human vs. Gorilla
df5a <- read.csv("../basic-div-hg002#M-hg002#M-vs-mGorGor1#M-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df5x <- read.csv("../basic-div-hg002#M-hg002#M-vs-mGorGor1#M-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df5y <- read.csv("../basic-div-hg002#P-hg002#P-vs-mGorGor1#P-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df5 = rbind(df5a, df5x, df5y)
df5$NAME = "hg002 vs. GorGor1"

# Gorilla vs. Human
df6a <- read.csv("../basic-div-mGorGor1#M-mGorGor1#M-vs-hg002#M-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df6x <- read.csv("../basic-div-mGorGor1#M-mGorGor1#M-vs-hg002#M-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df6y <- read.csv("../basic-div-mGorGor1#P-mGorGor1#P-vs-hg002#P-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df6 = rbind(df6a, df6x, df6y)
df6$NAME = "GorGor1 vs. hg002"

# Human vs. S. Orang
df7a <- read.csv("../basic-div-hg002#M-hg002#M-vs-mPonAbe1#1-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df7x <- read.csv("../basic-div-hg002#M-hg002#M-vs-mPonAbe1#1-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df7y <- read.csv("../basic-div-hg002#P-hg002#P-vs-mPonAbe1#2-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df7 = rbind(df7a, df7x, df7y)
df7$NAME = "hg002 vs. PonAbe1"

# S. Orang vs. Human
df8a <- read.csv("../basic-div-mPonAbe1#1-mPonAbe1#1-vs-hg002#M-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df8x <- read.csv("../basic-div-mPonAbe1#1-mPonAbe1#1-vs-hg002#M-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df8y <- read.csv("../basic-div-mPonAbe1#2-mPonAbe1#2-vs-hg002#P-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df8 = rbind(df8a, df8x, df8y)
df8$NAME = "PonAbe1 vs. hg002"

# Human vs. B. Orang
df9a <- read.csv("../basic-div-hg002#M-hg002#M-vs-mPonPyg2#1-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df9x <- read.csv("../basic-div-hg002#M-hg002#M-vs-mPonPyg2#1-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df9y <- read.csv("../basic-div-hg002#P-hg002#P-vs-mPonPyg2#2-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df9 = rbind(df9a, df9x, df9y)
df9$NAME = "hg002 vs. mPonPyg2"

# B. Orang vs. Human
df10a <- read.csv("../basic-div-mPonPyg2#1-mPonPyg2#1-vs-hg002#M-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df10x <- read.csv("../basic-div-mPonPyg2#1-mPonPyg2#1-vs-hg002#M-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df10y <- read.csv("../basic-div-mPonPyg2#2-mPonPyg2#2-vs-hg002#P-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df10 = rbind(df10a, df10x, df10y)
df10$NAME = "mPonPyg2 vs. hg002"

# Adding S. Orang vs. B. Orang
df11a <- read.csv("../basic-div-mPonAbe1#1-mPonAbe1#1-vs-mPonPyg2#1-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df11x <- read.csv("../basic-div-mPonAbe1#1-mPonAbe1#1-vs-mPonPyg2#1-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df11y <- read.csv("../basic-div-mPonAbe1#2-mPonAbe1#2-vs-mPonPyg2#2-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df11 = rbind(df11a, df11x, df11y)
df11$NAME = "mPonAbe1 vs. mPonPyg2"

# Adding B. Orang vs. S. Orang
df12a <- read.csv("../basic-div-mPonPyg2#1-mPonPyg2#1-vs-mPonAbe1#1-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df12x <- read.csv("../basic-div-mPonPyg2#1-mPonPyg2#1-vs-mPonAbe1#1-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df12y <- read.csv("../basic-div-mPonPyg2#2-mPonPyg2#2-vs-mPonAbe1#2-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df12 = rbind(df12a, df12x, df12y)
df12$NAME = "mPonPyg2 vs. mPonAbe1"

# Adding Chimp vs. Bonobo
df13a <- read.csv("../basic-div-mPanTro3#1-mPanTro3#1-vs-mPanPan1#M-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df13x <- read.csv("../basic-div-mPanTro3#1-mPanTro3#1-vs-mPanPan1#M-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df13y <- read.csv("../basic-div-mPanTro3#2-mPanTro3#2-vs-mPanPan1#P-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df13 = rbind(df13a, df13x, df13y)
df13$NAME = "mPanTro3 vs. PanPan1"

# Adding Bonobo vs. Chimp
df14a <- read.csv("../basic-div-mPanPan1#M-mPanPan1#M-vs-mPanTro3#1-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df14x <- read.csv("../basic-div-mPanPan1#M-mPanPan1#M-vs-mPanTro3#1-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df14y <- read.csv("../basic-div-mPanPan1#P-mPanPan1#P-vs-mPanTro3#2-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df14 = rbind(df14a, df14x, df14y)
df14$NAME = "PanPan1 vs. mPanTro3"

# Combine data
df = rbind(intra_df1, intra_df2, intra_df3, intra_df4, intra_df5, intra_df6, 
           df1, df2, df3, df4, df5,
           df6, df7, df8, df9, df10,
           df11, df12,
           df13, df14)
df$CHRGRP <- "A"
df$CHRGRP[df$CHR == "X"] <- "X"
df$CHRGRP[df$CHR == "Y"] <- "Y"

names <- c("hg002", "PanTro3", "PanPan1", "GorGor1", "PonAbe1", "mPonPyg2",
           "hg002 vs. PanTro3", "PanTro3 vs. hg002",
           "hg002 vs. PanPan1", "PanPan1 vs. hg002",
           "hg002 vs. GorGor1", "GorGor1 vs. hg002",
           "hg002 vs. PonAbe1", "PonAbe1 vs. hg002",
           "hg002 vs. mPonPyg2", "mPonPyg2 vs. hg002",
           "mPonAbe1 vs. mPonPyg2", "mPonPyg2 vs. mPonAbe1",
           "mPanTro3 vs. PanPan1", "PanPan1 vs. mPanTro3")

df$NAME <- factor(df$NAME, levels=names)

# Now table stuff
keep <- df %>%
        group_by(NAME, CHRGRP, .add = TRUE) %>%
        summarise_at(vars(GAP_OTHER, DIFF), funs(mean(., na.rm=TRUE)))
write.csv(keep,"mean_summary.csv", row.names = FALSE)
