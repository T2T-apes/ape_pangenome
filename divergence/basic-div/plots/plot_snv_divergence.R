library(tidyverse)
library(ggridges)
library(ggplot2)
library(dplyr)

source("stage_data.R")

# Plot A -- Look at SNP divergence
p <-  ggplot(df, aes(x=DIFF, y=NAME, color=CHRGRP, fill=CHRGRP))
p <- p + geom_density_ridges(scale=0.85)
p <- p + geom_density_ridges(scale=0.85, stat="binline", bins=100)

#p <- ggplot(df)
#p <- p + geom_density_ridges(
#            aes(x=DIFF, y=NAME, color=CHRGRP, fill=CHRGRP), 
#            scale=1.0,
#            quantile_lines=T, quantile_fun=mean)

p <- p + scale_y_discrete(expand = c(0, 0))

p <- p + labs(x = "SNV divergence in 1Mb segment", 
              y = "", colour = "", title = "", subtitle = "")

p <- p + scale_fill_manual(values = c( "#673AB750", "#D55E0050", "#0072B250"), labels = c("autosomes", "X", "Y"))
p <- p + scale_color_manual(values = c("#673AB7",   "#D55E00",   "#0072B2"), guide = "none")
p <- p + coord_cartesian(clip = "off")
#p <- p + theme_ridges()
p <- p + theme_classic()
p <- p + theme(legend.title=element_blank())


meanpts <- c()
meanys <- c()
meanxs <- c()

medianpts <- c()
medianys <- c()
medianxs <- c()

xs <- c()
ys <- c()
cs <- c()
labs <- c()
base <- 1
for (name in names) {
    xdf <- df[df$NAME == name, ]
    shift <- base + 0.2
    for (chrgrp in c("Y", "X", "A")) {
        ydf <- xdf[xdf$CHRGRP == chrgrp, ]

        # Update xs
        xs <- append(xs, 0.25)

        # Update ys
        ys <- append(ys, shift)
        shift <- shift + 0.3
        meanys <- append(meanys, base)
        medianys <- append(medianys, base)

        cs <- append(cs, chrgrp)

        # Update mean and median markers
        mymean <- mean(ydf$DIFF,  na.rm=TRUE)
        mymedian <- median(ydf$DIFF,  na.rm=TRUE)

        meanxs <- append(meanxs, mymean)
        medianxs <- append(medianxs, mymedian)
        if (is.nan(mymean)) {
            labs <- append(labs, "")
            meanpts <- append(meanpts, "")
            medianpts <- append(medianpts, "")
        } else {
            labs <- append(labs, sprintf("%f", mymean))
            meanpts <- append(meanpts, "o")
            medianpts <- append(medianpts, "|")
        }
    }
    base <- base + 1
}

annotation <- data.frame(
   x = xs,
   y = ys,
   label = labs,
   CHRGRP = cs
)

meandf <- data.frame(
   y = meanys,
   x = meanxs,
   label = meanpts,
   CHRGRP = cs
)

mediandf <- data.frame(
   y = medianys,
   x = medianxs,
   label = medianpts,
   CHRGRP = cs
)

#p <- p + geom_text(data=meandf, aes(x=x, y=y, label=label), size=2.5, fontface="bold")

#p <- p + geom_text(data=mediandf, aes(x=x, y=y, label=label), size=2.5, fontface="bold")

p <- p + geom_text(data=annotation, aes(x=x, y=y, label=label), size=2.5, fontface="bold") 

p <- p + xlim(0.0, 0.3)


print(p)
ggsave("snv_divergence-v2.png", dpi=300)
