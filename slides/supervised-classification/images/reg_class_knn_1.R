setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
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
library(e1071)

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))


plot_lp = function(...){
  plotLearnerPrediction(...) + scale_fill_viridis_d()
}

set.seed(600000)


pdf("reg_class_knn_1.pdf", width = 8, height = 6)
dd = subset(iris, Sepal.Length > 6.1 & Sepal.Length < 6.7 & Sepal.Width > 2.8 & Sepal.Width < 3.3)[,c(1,2,5)]
xnew = c(6.4, 3)
circleFun2 = function(center = c(0,0), diameter = 1, npoints = 100){
  r = diameter / 2
  tt = seq(0,2*pi,length.out = npoints)
  xx = center[1L] + r * cos(tt)
  yy = center[2L] + r * sin(tt)
  return(data.frame(Sepal.Length = xx, Sepal.Width = yy, Species = NA))
}
circle.dat2 = circleFun2(c(6.4,3), 0.24, npoints = 100)
q = ggplot(dd, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point(size = 10) + scale_color_viridis_d()
q = q + geom_polygon(data = circle.dat2, alpha = 0.2, fill = "#619CFF")
q = q + theme(legend.position = c(0.14, 0.82), text = element_text(size = 25))
q = q  + annotate("text", x = xnew[1], y = xnew[2], label = "x[new]", size = 10, parse = TRUE)
q
ggsave("reg_class_knn_1.pdf", width = 8, height = 6)
dev.off()

