library(tidyverse)
library(ggridges)
library(ggplot2)

source("stage_data.R")

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

intra_df <- df[df$NAME != "hg002 vs. PanTro3", ]
intra_df <- intra_df[intra_df$NAME != "hg002 vs. PanPan1", ]
intra_df <- intra_df[intra_df$NAME != "hg002 vs. GorGor1", ]
intra_df <- intra_df[intra_df$NAME != "hg002 vs. GorGor1", ]
intra_df <- intra_df[intra_df$NAME != "hg002 vs. PonAbe1", ]
intra_df <- intra_df[intra_df$NAME != "hg002", ]
intra_df <- intra_df[intra_df$NAME != "PanPan1 vs. hg002", ]
intra_df <- intra_df[intra_df$NAME != "PonAbe1 vs. hg002", ]
intra_df <- intra_df[intra_df$NAME != "GorGor1 vs. hg002", ]
intra_df <- intra_df[intra_df$NAME != "PanTro3 vs. hg002", ]

levels(inter_df$NAME) <- list(PAB="PonAbe1 vs. hg002",
                              GGO="GorGor1 vs. hg002",
                              PTR="PanTro3 vs. hg002",
                              PPA="PanPan1 vs. hg002")

levels(intra_df$NAME) <- list(PAB="PonAbe1",
                              GGO="GorGor1",
                              PTR="PanTro3",
                              PPA="PanPan1")

# Plot A -- Look at gap divergence
p <-  ggplot(inter_df, aes(x=DIFF, y=NAME, color=CHRGRP, fill=CHRGRP))
p <- p + geom_density_ridges(scale=0.9)
#p <- p + geom_density_ridges(scale=1.0, stat="binline", bins=100)
p <- p + scale_y_discrete(expand = c(0, 0))
p <- p + labs(x = "", y = "", colour = "", title = "SNV divergence", subtitle = "")
p <- p + scale_fill_manual(values = c( "#673AB750", "#D55E0050", "#0072B250"), labels = c("autosomes", "X", "Y"))
p <- p + scale_color_manual(values = c("#673AB7",   "#D55E00",   "#0072B2"), guide = "none")
p <- p + coord_cartesian(clip = "off")
#p <- p + theme_ridges()
p <- p + theme_classic()
p <- p + theme(plot.title = element_text(hjust = 0.5))
p <- p + theme(legend.title=element_blank())


# Add inter species annotation
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
ybase <- 1
for (name in levels(inter_df$NAME)) {
    xdf <- inter_df[inter_df$NAME == name, ]
    yshift <- ybase + 0.25
    xbase <- 0.225 
    for (chrgrp in c("Y", "X", "A")) {
        ydf <- xdf[xdf$CHRGRP == chrgrp, ]

        # Update xs
        #xs <- append(xs, 0.35)
        xs <- append(xs, xbase)

        # Update ys
        #ys <- append(ys, yshift)
        #shift <- shift + 0.25
        ys <- append(ys, yshift + 0.4)
        meanys <- append(meanys, ybase)
        medianys <- append(medianys, ybase)

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
            labs <- append(labs, sprintf("%1.3f (%s)", round(round(mymean, 4), 3), chrgrp))
            meanpts <- append(meanpts, "|")
            medianpts <- append(medianpts, "o")
        }
        xbase <- xbase - 0.0375
    }
    ybase <- ybase + 1
}

print(xs)
print(ys)

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

p <- p + geom_text(data=meandf, aes(x=x, y=y, label=label), size=2.75, fontface="bold")
#p <- p + geom_text(data=mediandf, aes(x=x, y=y, label=label), size=2.5, fontface="bold")
p <- p + geom_text(data=annotation, aes(x=x, y=y, label=label), size=2.75, fontface="bold") #,                 , 
           #color="orange", 
           #size=7 , angle=45, fontface="bold" )


# Add intra species annotation
ybase <- 0
intrameans <- c()
labs <- c()
for (name in levels(inter_df$NAME)) {
    xdf <- intra_df[intra_df$NAME == name, ]
    ydf <- xdf[xdf$CHRGRP == "A", ]
    mymean <- mean(ydf$DIFF,  na.rm=TRUE)
    intrameans <- append(intrameans, mymean)
    labs <- append(labs, sprintf("%1.3f (A)", round(round(mymean, 4), 3)))
    meanpts <- append(meanpts, "O")
    ybase <- ybase + 1
}

#testdf <- data.frame(
#   y = c(1, 2, 3, 4),
#   x = intrameans,
#   label = meanpts,
#   CHRGRP = c("A", "A", "A", "A")
#)
#p <- p + geom_text(data=testdf, aes(x=x, y=y, label=label), size=2.75, fontface="bold", color="#000000")

testdf <- data.frame(
   y = c(1.4, 2.4, 3.4, 4.4),
   x = c(0.1500, 0.1500, 0.1500, 0.1500),
   label = labs,
   CHRGRP = c("A", "A", "A", "A")
)

p <- p + geom_text(data=testdf, aes(x=x, y=y, label=label), color="#000000", size=2.75, fontface="bold")
p <- p + geom_text(data=testdf, aes(x=0.11875, y=4.4, label="intra:"), color="#000000", size=2.75, fontface="bold")
p <- p + geom_text(data=testdf, aes(x=0.11875, y=4.65, label="inter:"), color="#000000", size=2.75, fontface="bold")


#print(intrameans)
p <- p + geom_segment(aes(x=intrameans[1], 
                          y=1,
                          xend=intrameans[1],
                          yend=1.85),
                          color="#000000",
                          size=0.6,
                          lty="dotted")

p <- p + geom_segment(aes(x=intrameans[2], 
                          y=2,
                          xend=intrameans[2],
                          yend=2.85),
                          color="#000000",
                          size=0.6,
                          lty="dotted")

p <- p + geom_segment(aes(x=intrameans[3], 
                          y=3,
                          xend=intrameans[3],
                          yend=3.85),
                          color="#000000",
                          size=0.6,
                          lty="dotted")

p <- p + geom_segment(aes(x=intrameans[4], 
                          y=4,
                          xend=intrameans[4],
                          yend=4.85),
                          color="#000000",
                          size=0.6,
                          lty="dotted")

# Save
print(p)

p <- p + xlim(0.0, 0.25)
#ggsave("snv_divergence-final.pdf", width=6, height=3.5, dpi=300)
ggsave("snv_divergence-final.png", width=6, height=3.5, dpi=300)

