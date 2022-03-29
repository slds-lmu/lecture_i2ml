# ------------------------------------------------------------------------------
# FIG: CIRCLES PLOTS
# ------------------------------------------------------------------------------
library(dplyr)
library(scatterplot3d)
library(ggplot2)
library(viridis)
set.seed(1242)

# DATA -------------------------------------------------------------------------
circles <- data.frame(x1 = 2*runif(4e2)-1, x2 = 2*runif(4e2)-1) %>%
  mutate(dist = x1^2 + x2^2, 
    group1 = dist > .7 & dist < .9, 
    group2 = dist > .2 & dist < .35,
    group = ifelse(group1, "1", ifelse(group2, "2", NA))) %>%
    filter(!is.na(group))

# PLOTS ------------------------------------------------------------------------
p_circles <- ggplot(circles, aes(x = x1, y = x2, colour = group)) +
  geom_point() +
  guides(color = "none") +
  coord_fixed() +
  scale_color_viridis(end = 0.9, discrete = TRUE)

ggsave("../figure/circles_ds.png", plot = p_circles, width = 3, height = 3)

############################################################################
png(filename = "../figure/circles_feature_map.png", units = "in", width = 10, height = 4, res = 300)
par(mar = c(1,0,0,0))
viridis_2 <- viridis(2, end = 0.9)
layout(t(1:2))
scatterplot3d(circles$x1, circles$x2, circles$dist, color = viridis_2[as.numeric(circles$group)], pch = 19,
  xlab = "x1", ylab = "x2", zlab = "x1^2 + x2^2", angle = 70, asp = 1, zlim = c(0, 1), type = "h")
p <- scatterplot3d(circles$x1, circles$x2, circles$dist, color = viridis_2[as.numeric(circles$group)], pch = 19,
  xlab = "x1", ylab = "x2", zlab = "x1^2 + x2^2", angle = 70, asp = 1, zlim = c(0, 1))
p$plane3d(c(.6, 0, 0), draw_polygon = TRUE)
dev.off()

############################################################################

p_circles_boundary <- p_circles + annotate("path",
   x=sqrt(.5)*cos(seq(0,2*pi,length.out=100)),
   y=sqrt(.5)*sin(seq(0,2*pi,length.out=100)), col = "red")

ggsave(filename = "../figure/circles_boundary.png", plot = p_circles_boundary, width = 3, height = 3)

