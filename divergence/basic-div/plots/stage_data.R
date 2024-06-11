## Stage data, which is annoaying because didn't think it through when generating CSVs

# Primate vs. Same Primate
df1 <- read.csv("../basic-div-hg002#M-hg002#M-vs-hg002#P-autosomes.csv",
                header=TRUE, row.names=NULL, sep=',')
df1$NAME = "hg002"

df2 <- read.csv("../basic-div-mPanTro3#1-mPanTro3#1-vs-mPanTro3#2-autosomes.csv",
                header=TRUE, row.names=NULL, sep=',')
df2$NAME = "PanTro3"

df3 <- read.csv("../basic-div-mPanPan1#M-mPanPan1#M-vs-mPanPan1#P-autosomes.csv",
                header=TRUE, row.names=NULL, sep=',')
df3$NAME = "PanPan1"

df4 <- read.csv("../basic-div-mGorGor1#M-mGorGor1#M-vs-mGorGor1#P-autosomes.csv",
                header=TRUE, row.names=NULL, sep=',')
df4$NAME = "GorGor1"

df5 <- read.csv("basic-div-mPonAbe1#1-mPonAbe1#1-vs-mPonAbe1#2-autosomes.csv",
                header=TRUE, row.names=NULL, sep=',')
df5$NAME = "PonAbe1"

# Human vs. Chimp
df6a <- read.csv("../basic-div-hg002#M-hg002#M-vs-mPanTro3#1-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df6x <- read.csv("../basic-div-hg002#M-hg002#M-vs-mPanTro3#1-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df6y <- read.csv("../basic-div-hg002#P-hg002#P-vs-mPanTro3#2-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df6 = rbind(df6a, df6x, df6y)
df6$NAME = "hg002 vs. PanTro3"

# Chimp vs. Human
df7a <- read.csv("../basic-div-mPanTro3#1-mPanTro3#1-vs-hg002#M-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df7x <- read.csv("../basic-div-mPanTro3#1-mPanTro3#1-vs-hg002#M-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df7y <- read.csv("../basic-div-mPanTro3#2-mPanTro3#2-vs-hg002#P-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df7 = rbind(df7a, df7x, df7y)
df7$NAME = "PanTro3 vs. hg002"

# Human vs. Bonobo
df8a <- read.csv("../basic-div-hg002#M-hg002#M-vs-mPanPan1#M-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df8x <- read.csv("../basic-div-hg002#M-hg002#M-vs-mPanPan1#M-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df8y <- read.csv("../basic-div-hg002#P-hg002#P-vs-mPanPan1#P-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df8 = rbind(df8a, df8x, df8y)
df8$NAME = "hg002 vs. PanPan1"

# Bonobo vs. Human
df9a <- read.csv("../basic-div-mPanPan1#M-mPanPan1#M-vs-hg002#M-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df9x <- read.csv("../basic-div-mPanPan1#M-mPanPan1#M-vs-hg002#M-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df9y <- read.csv("../basic-div-mPanPan1#P-mPanPan1#P-vs-hg002#P-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df9 = rbind(df9a, df9x, df9y)
df9$NAME = "PanPan1 vs. hg002"

# Human vs. Gorilla
df10a <- read.csv("../basic-div-hg002#M-hg002#M-vs-mGorGor1#M-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df10x <- read.csv("../basic-div-hg002#M-hg002#M-vs-mGorGor1#M-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df10y <- read.csv("../basic-div-hg002#P-hg002#P-vs-mGorGor1#P-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df10 = rbind(df10a, df10x, df10y)
df10$NAME = "hg002 vs. GorGor1"

# Gorilla vs. Human
df11a <- read.csv("../basic-div-mGorGor1#M-mGorGor1#M-vs-hg002#M-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df11x <- read.csv("../basic-div-mGorGor1#M-mGorGor1#M-vs-hg002#M-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df11y <- read.csv("../basic-div-mGorGor1#P-mGorGor1#P-vs-hg002#P-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df11 = rbind(df11a, df11x, df11y)
df11$NAME = "GorGor1 vs. hg002"

# Human vs. Orang
df12a <- read.csv("../basic-div-hg002#M-hg002#M-vs-mPonAbe1#1-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df12x <- read.csv("../basic-div-hg002#M-hg002#M-vs-mPonAbe1#1-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df12y <- read.csv("../basic-div-hg002#P-hg002#P-vs-mPonAbe1#2-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df12 = rbind(df12a, df12x, df12y)
df12$NAME = "hg002 vs. PonAbe1"

# Orang vs. Human
df13a <- read.csv("../basic-div-mPonAbe1#1-mPonAbe1#1-vs-hg002#M-autosomes.csv",
                 header=TRUE, row.names=NULL, sep=',')
df13x <- read.csv("../basic-div-mPonAbe1#1-mPonAbe1#1-vs-hg002#M-X.csv",
                 header=TRUE, row.names=NULL, sep=',')
df13y <- read.csv("../basic-div-mPonAbe1#2-mPonAbe1#2-vs-hg002#P-Y.csv",
                 header=TRUE, row.names=NULL, sep=',')
df13 = rbind(df13a, df13x, df13y)
df13$NAME = "PonAbe1 vs. hg002"

# Combine data
df = rbind(df1, df2, df3, df4, df5, df6, df7, df8, df9, df10, df11, df12, df13)
df$CHRGRP <- "A"
df$CHRGRP[df$CHR == "X"] <- "X"
df$CHRGRP[df$CHR == "Y"] <- "Y"

names <- c("hg002", "PanTro3", "PanPan1", "GorGor1", "PonAbe1",
           "hg002 vs. PanTro3", "PanTro3 vs. hg002",
           "hg002 vs. PanPan1", "PanPan1 vs. hg002",
           "hg002 vs. GorGor1", "GorGor1 vs. hg002",
           "hg002 vs. PonAbe1", "PonAbe1 vs. hg002")
df$NAME <- factor(df$NAME, levels=names)

