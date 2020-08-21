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

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))


getCurrentAspect = function() {
  uy <- diff(grconvertY(1:2,"user","inches"))
  ux <- diff(grconvertX(1:2,"user","inches"))
  uy/ux
}
par(mar = c(4,4,0,0)+.1)
cex = 1.5
pdf("reg_knn_2.pdf", width = 8, height = 7)

plot(x = c(1L,5L), y = c(1L,4L), ylim = c(0,5), xlim = c(0,6), pch = 19, las=1,
     panel.first=grid(col = "lightgray", lty = "solid"),
     xlab = "Dimension 1", ylab = "Dimension 2", cex.lab = cex, cex.axis = cex, bty='l')
lines(x = c(1L,5L), y = c(1L,4L))
text(x = c(1L,5L), y = c(1L,4L), c(expression(x), expression(tilde(x))), adj = c(1.5, 0), cex = cex)
lines(x = c(1L, 5L, 5L, 5L), y = c(1L, 1L, 1L, 4L), col = 2)
legend(x = -0.1, y = 5.1, lty = 1, legend = c("Manhattan", "Euclidean"), col = c(2,1), cex = cex,
       box.lwd = 0, box.col = "white", bg = "white")
text(x = 5, y = 0.9, expression(d(x,tilde(x))~"= |5-1| + |4-1| = 7"), adj = c(1,1), col = 2, cex = cex)
asp = getCurrentAspect()
text(x = 3, y = 2.5, expression(d(x,tilde(x))~"="~sqrt((5-1)^2 + (4-1)^2)~"= 5"),
     adj = c(0.5,0), col = 1, srt = 180/pi*atan(3/4*asp), cex=cex)

ggsave("reg_knn_2.pdf", width = 8, height = 7)
dev.off()