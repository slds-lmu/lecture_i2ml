 
library(knitr)
library(mlbench)
library(mlr)
library(OpenML)

library(ggplot2)
library(viridis)
library(gridExtra)
library(ggrepel)
library(repr)

library(data.table)
library(BBmisc)


library(party)
library(kableExtra)
library(kknn)

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))


set.seed(123)
circleFun = function(center = c(0,0), diameter = 1, npoints = 100){
  r = diameter / 2
  tt = seq(0,2*pi,length.out = npoints)
  xx = center[1L] + r * cos(tt)
  yy = center[2L] + r * sin(tt)
  return(data.frame(x1 = xx, x2 = yy, class = NA))
}
pdf("../figure/reg_knn_1.pdf", width= 8, height = 3)
knn_plot = function(mat, k) {
  n = nrow(mat) - 1
  dists = sort(as.matrix(dist(mat))[n + 1L, ])
  neighbs = as.numeric(names(dists[1:(k + 1)]))
  mat$class = ifelse(1:(n+1) %in% neighbs, 1L, 0L)
  mat[n + 1L, "class"] = 2L
  mat$class = as.factor(mat$class)
  circle.dat = circleFun(c(0, 0), 2.01 * dists[k+1], npoints = 100)
  q = ggplot(mat, aes(x = x1, y = x2, color = class)) + geom_point(size = 2) + scale_color_viridis(discrete = TRUE, option = "D") + scale_fill_viridis(discrete = TRUE)
  q = q + geom_polygon(data = circle.dat, alpha = 0.2, fill = "#619CFF")
  q + theme(legend.position = "none") + labs(subtitle = bquote(k == .(k)))
}

n = 30L
x1 = rnorm(n)
x2 = rnorm(n)
mat = as.data.frame(cbind(x1, x2))
mat = rbind(mat, c(0, 0))

gridExtra::grid.arrange(knn_plot(mat, 15), knn_plot(mat, 7), knn_plot(mat, 3),
                        nrow = 1)

ggsave("../figure/reg_knn_1.pdf", width = 8, height = 3)
dev.off()
