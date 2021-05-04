library(data.table)
library(mlr)

sigma = 0.3
gamma = 1 / (2 * sigma^2)

dd = data.frame(
  x1 = c(-1, -0.8, -1, -0.5, +1, +1),
  x2 = c(-1, -0.9, +1, +0.6, -1, +1),
  y =  c(-1, -1,   +1, +1,   +1, -1)
)
dd2 = dd; dd2$y = as.factor(dd2$y)
tsk = makeClassifTask(data = dd2, target = 'y')

lrn = makeLearner("classif.svm", cost = 1, gamma = gamma, scale = FALSE)
mod = train(lrn, tsk)
mm = mod$learner.model
dd$a = mm$coefs[,1]
# sv.index = mod$learner.model$index
# print(sv.index)
# df = getTaskData(tsk)
# df = df[ifelse(1:getTaskSize(tsk) %in% sv.index, TRUE, FALSE), ]


plot_points = function(pmat, x1, x2, col = "red", cex = 1.2, alphab = 1) {
  mypoints = trans3d(x1, x2, 0, pmat = pmat)
  col = alpha(col, alphab)
  points(mypoints, pch = 19, col = col, cex = cex)
}

plot_lines = function(pmat, x1, x2, col = "red", lwd, alphab = 1, lty = "dashed") {
  mypoints = trans3d(x1, x2, 0, pmat = pmat)
  col = alpha(col, alphab)
  lines(mypoints, col = col, lwd = lwd, lty = lty)
}

plot_bumps = function(svs, contour = c(0)) {
  x1seq = seq(-2,2,0.2)
  x2seq = seq(-2,2,0.2)
  m = length(x1seq)
  z = matrix(data=0, nrow=m, ncol=m)
  add_bump = function(x, alpha, y, sigma = 1) {
    for (i in 1:m) 
      for (j in 1:m) {
        xx = c(x1seq[i], x2seq[j])
        r = sum((x - xx)^2)
        z[i,j] <<- z[i,j] + y * alpha * exp(-r/(2*sigma^2)) 
      }
  }
  
  for (j in svs) {
    k = mm$index[j]
    bb = dd[k,]
    add_bump(c(bb$x1, bb$x2), y = -1, alpha = mm$coefs[j], sigma = sigma)
  }

  pmat = persp(x1seq, x2seq, z,
              # theta=10, 
              phi=50, 
              # r=2, 
              shade = 0.4, 
              axes = TRUE, 
              scale = TRUE, 
              box = FALSE, 
              # nticks=5, 
              # ticktype="detailed", 
              zlim = c(-3, 3), 
              col = "cyan", xlab = "x1", ylab="x2", zlab="f")
  ee = subset(dd, y == 1)
  plot_points(pmat, ee$x1, ee$x2, col = "red", cex = 0.8)
  ee = subset(dd, y == -1)
  plot_points(pmat, ee$x1, ee$x2, col = "green", cex = 0.8)
  for (j in seq_along(contour)) {
    cl = contourLines(x = x1seq, y = x2seq, z, levels = contour[j])
    for (k in seq_along(cl)) 
      plot_lines(pmat, cl[[k]]$x, cl[[k]]$y, lwd = 3, col = "black", alpha = 0.7)
  }
}



svs = 1:nrow(dd)
for (k in 1:length(svs)) {
  png(file=sprintf("figure_man/non-lin-svm-rbf-as-basis-%i.png", k))
  par(mai=rep(0,4)); par(omi=rep(0,4))
  plot_bumps(svs[1:k], contour = NULL)
  dev.off()
}

png(file="figure_man/non-lin-svm-rbf-as-basis.png")
par(mai=rep(0,4)); par(omi=rep(0,4))
plot_bumps(svs, contour = c(0))
dev.off()






