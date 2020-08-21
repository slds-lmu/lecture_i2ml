 
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



scale_c_d <- scale_colour_discrete <- scale_color_discrete <-
  function(...) {
    viridis::scale_color_viridis(..., end = .9, discrete = TRUE, drop = TRUE)
  }

library(plyr)
library(kernlab)

pdf("../figure/cart_splitcriteria_3.pdf", width = 8, height = 2.2)
set.seed(1221)
d = data.frame(prob = c(0.1, 0.7, 0.2), label = 1:3)
pl = ggplot(data = d, aes(x = label, y = prob, fill = label))
pl = pl + geom_bar(stat = "identity")  + theme(legend.position = "none") + scale_c_d()
pl = pl + ylab("Class prob.") + xlab("Label")
print(pl)

ggsave("../figure/cart_splitcriteria_3.pdf", width = 8, height = 2.2)
dev.off()

