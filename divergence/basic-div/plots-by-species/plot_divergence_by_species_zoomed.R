library(tidyverse)
library(ggridges)
library(ggplot2)

roundMe <- function(mylist, numbers=3) {
  newlist <- rep(0, length(mylist))
    for (i in 1:length(mylist)) { 
      newlist[i] <- round(mylist[i], 4)   
    }
    return(newlist)
}

inter_df <- read.csv("interspecies_divergence.csv")
intra_df <- read.csv("intraspecies_divergence.csv")

ordered_chrs <- c("A", "X", "Y")
ordered_names <- c("PPA_SNV", "PPA_GAP", 
                   "PTR_SNV", "PTR_GAP", 
                   "GGO_SNV", "GGO_GAP", 
                   "PAB_SNV", "PAB_GAP")
n <- length(ordered_names)

inter_df$CHRGRP <- factor(inter_df$CHRGRP)
inter_df$NAME <- factor(inter_df$NAME, levels=ordered_names)

intra_df$CHRGRP <- factor(intra_df$CHRGRP)
intra_df$NAME <- factor(intra_df$NAME, levels=ordered_names)
intra_df <- intra_df[intra_df$CHRGRP == "A", ]

p <- inter_df |> 
   drop_na(DIV) |>
   ggplot() +
   geom_density(aes(DIV, color=CHRGRP, fill=CHRGRP, group=CHRGRP),
                alpha=0.5, bw=0.01) +
   facet_grid(NAME~.) +
   theme_classic() +
   scale_color_manual(values=c("#673AB7",   "#D55E00",   "#0072B2")) +
   scale_fill_manual(values=c("#673AB7",   "#D55E00",   "#0072B2")) +
   theme(text=element_text(family="Helvetica"),
         strip.text.y=element_text(angle=0),
         axis.text.y=element_blank(), 
         axis.ticks.y=element_blank(),
         plot.title=element_blank(),
         axis.title.x=element_blank(),
         axis.title.y=element_blank(),
         legend.title=element_blank(),
         )

# Zoom in (don't recalculate densities)
p <- p + coord_cartesian(xlim=c(0, 0.3), ylim=c(0, 40))

# Add bar for interspecies divergence mean
colors <- c("#673AB7", "#D55E00", "#0072B2")
ys <- c(32.5, 22.5, 12.5)
for (i in c(1, 2, 3)) {
    chr <- levels(inter_df$CHRGRP)[i]
    color <- colors[i]
    y <- ys[i]

    inter_df_chr <- inter_df[inter_df$CHRGRP == chr, ]
    mean_df <- aggregate(DIV ~ NAME, data=inter_df_chr, FUN=mean)
    mean_df$NAME <- factor(mean_df$NAME, levels=ordered_names)

    bar_df <- data.frame(x=mean_df$DIV,
                         y=rep(1, n),
                         label=rep("|", n),
                         CHRGRP=rep(chr, n),
                         NAME=mean_df$NAME)
    p <- p + geom_text(data=bar_df, 
                       aes(x=x, y=y, group=CHRGRP, label=label), 
                       color=color,
                       size=3.5,
                       fontface="bold",
                       family="Helvetica") + facet_grid(NAME~.)

    label_df <- data.frame(x=rep(0.275, n),
                           y=rep(y, n),
                           label=roundMe(mean_df$DIV),
                           CHRGRP=rep(chr, n),
                           NAME=mean_df$NAME)
    p <- p + geom_text(data=label_df, 
                       aes(x=x, y=y, group=CHRGRP, label=label), 
                       color=color,
                       size=3,
                       #fontface="bold",
                       family="Helvetica") + facet_grid(NAME~.)
}

# Add dashed line for intraspecies divergence mean
mean_df <- aggregate(DIV ~ NAME, data=intra_df, FUN=mean)
mean_df$NAME <- factor(mean_df$NAME, levels=ordered_names)

bar_df <- data.frame(x = mean_df$DIV,
                     y = rep(0, n),
                     CHRGRP = rep("A", n),
                     NAME = mean_df$NAME)
p <- p + geom_segment(data=bar_df, 
                      aes(x=x, xend=x, y=y, yend=y+40), 
                      color = "#000000",
                      linewidth=0.6,
                      lty="dotted")

# Add written words
intra_label_df <- data.frame(x=rep(0.2525, n),
                             y=rep(32.5, n),
                             #label=append("vs.", rep("", n-1)),
                             label=rep("vs", n),
                             CHRGRP = rep("A", n),
                             NAME=mean_df$NAME)
intra_mean_label_df <- data.frame(x=rep(0.23, n),
                                  y=rep(32.5, n),
                                  label=roundMe(mean_df$DIV),
                                  CHRGRP = rep("A", n),
                                  NAME=mean_df$NAME)
dfs <- list(intra_label_df, intra_mean_label_df)
for (df in dfs) {
    p <- p + geom_text(data=df, 
                       aes(x=x, y=y, group=CHRGRP, label=label), 
                       color="#000000",
                       size=3,
                       #fontface="bold",
                       family="Helvetica") + facet_grid(NAME~.)
}

p <- p + scale_x_continuous(n.breaks=9)

ggsave("div-by-species-zoomed.pdf", height=7, width=7, dpi=300)
