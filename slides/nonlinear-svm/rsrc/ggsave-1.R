
library(dplyr)
set.seed(1242)
circles = data.frame(x1 = 2*runif(4e2)-1, x2 = 2*runif(4e2)-1) %>% 
  mutate(dist = x1^2 + x2^2, 
    group1 = dist > .7 & dist < .9, 
    group2 = dist > .2 & dist < .35,
    group = ifelse(group1, "1", ifelse(group2, "2", NA))) %>%
    filter(!is.na(group)) 
(p_circles = ggplot(circles, aes(x = x1, y = x2, colour = group)) + geom_point() + guides(color = FALSE) + coord_fixed())


############################################################################

library(scatterplot3d)
par(mar = c(1,0,0,0))
layout(t(1:2))
scatterplot3d(circles$x1, circles$x2, circles$dist, color = pal_2[as.numeric(circles$group)], pch = 19, 
  xlab = "x1", ylab = "x2", zlab = "x1^2 + x2^2", angle = 70, asp = 1, zlim = c(0, 1), type = "h")
p <- scatterplot3d(circles$x1, circles$x2, circles$dist, color = pal_2[as.numeric(circles$group)], pch = 19, 
  xlab = "x1", ylab = "x2", zlab = "x1^2 + x2^2", angle = 70, asp = 1, zlim = c(0, 1))
p$plane3d(c(.5, 0, 0), draw_polygon = TRUE)  

############################################################################


p_circles + annotate("path",
   x=sqrt(.5)*cos(seq(0,2*pi,length.out=100)),
   y=sqrt(.5)*sin(seq(0,2*pi,length.out=100)), col = "red")


############################################################################

load("data/mnist_svm_mixed.RData")

    pl_df = mnist_test_mmce_mixed[,c("mmce", "degree")]
    pl_df = pl_df[complete.cases(pl_df),]
    
    ggplot(pl_df, aes(x=degree, y=mmce)) +
      geom_point(size=2) +
      geom_line() +
      scale_x_continuous(breaks = pl_df$degree) +
      xlab("degree d")


############################################################################

    load("data/mnist_svm_mixed.RData")
    
    d = 1:5
    p = 16*16
    num_monomials = choose(p + d, p)-1
    
    df_mon = data.frame(degree = d, num_monomials = num_monomials)
    
    ggplot(df_mon, aes(x=d, y=num_monomials)) +
      geom_point(size=2) +
      geom_line() +
      scale_x_continuous(breaks = d) +
      scale_y_continuous(trans = "log10") +
      xlab("degree d") +
      ylab("Number of monomials")


############################################################################

