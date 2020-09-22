 
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


colBlue   = function(alpha) { rgb(135, 206, 255, alpha, maxColorValue = 255) }
colOrange = function(alpha) { rgb(255, 185,  15, alpha, maxColorValue = 255) }
colRed = function(alpha) { rgb(255, 15,  15, alpha, maxColorValue = 255) }
colGreen  = function(alpha) { rgb(188, 238, 104, alpha, maxColorValue = 255) }

set.seed(pi)

x = 1:5
y = x + rnorm(5, 0, 2)

data_plot = function(x, y) {
  plot(x, y, ylim = c(-2, 6), xlim = c(0, 8), cex = 2, pch = 4, las = 1, ann="false")
  grid()
}

add_lm = function(coef, color, coef_label) {
  abline(coef = coef, col = color(255), lwd = 3)
  coef <- round(coef, 1)
  text(x = coef_label[1], y = coef_label[2], 
       labels = bquote(theta == "("~.(coef[1])~","~.(coef[2])~")"),
       col = color(255))
}
add_errors = function(x, y, coef, color, sse_label) {
  hat_y = cbind(1, x) %*% coef
  w = abs(y - hat_y)
  rect(xleft = x, ybottom = y, xright = x + w, ytop = hat_y, col = color(90),
       border = color(120), lwd = 2)
  text(x = sse_label[1], y = sse_label[2], 
       labels =  paste0("SSE: ", sum(round(w^2, 2))),
       col = color(255))
  points(x, y, cex = 2, pch = 4, lwd = 2)
}

frame_plot = function(x, y, coef, color, coef_label, sse_label) {
  data_plot(x, y)
  add_lm(coef, color, coef_label)
  add_errors(x, y, coef, color, sse_label)
}

m = lm(y ~ x)

sse = function(c1, c2, x, y) {
  hat_y = cbind(1, x) %*% c(c1, c2)
  w = abs(y - hat_y)
  sum(w^2)
}
sae = function(c1, c2, x, y) {
  hat_y = cbind(1, x) %*% c(c1, c2)
  w = abs(y - hat_y)
  sum(w)
}

gridlength <- 30
c1_grid = seq(-2, 2, l = gridlength)
c2_grid = seq(0, 1.5, l = gridlength)
sse_surf = outer(c1_grid, c2_grid, Vectorize(sse, c("c1", "c2")), x = x, y = y)
sae_surf = outer(c1_grid, c2_grid, Vectorize(sae, c("c1", "c2")), x = x, y = y)

clrs_ramp = scales::alpha(colorRampPalette(viridisLite::plasma(5))(200), .5)
clrs = sse_surf[-1, -1] + sse_surf[-1, -gridlength] + 
  sse_surf[-gridlength, -1] + sse_surf[-gridlength, -gridlength]
clrs = cut(clrs, length(clrs_ramp))

clrs_sae = sae_surf[-1, -1] + sae_surf[-1, -gridlength] + 
  sae_surf[-gridlength, -1] + sae_surf[-gridlength, -gridlength]
clrs_sae = cut(clrs_sae, length(clrs_ramp))

sse_blank = quote(persp(x = c1_grid, y = c2_grid, sse_surf*NA, theta = -130, phi = 10, 
                        zlim = range(sse_surf),
                        ticktype = "detailed", xlab = "Intercept", ylab = "Slope", zlab = "SSE", 
                        col = "white", border = rgb(1,1,1,0)))


opar <- par(no.readonly = FALSE)
par(mar = opar$mar/2)

coef1 <- c(1.8, .3)
coef2 <- c(1, .1)
coef3 <- c(0.5, .8)

#1st figure of best theta
pdf("../figure/reg_lm_plot_35.pdf", width= 4.5, height = 5.5)

persp(x = c1_grid, y = c2_grid, sse_surf, theta = -130, phi = 10, 
      zlim = range(sse_surf),
      ticktype = "detailed", xlab = "Intercept", ylab = "Slope", zlab = "SSE", 
      col = clrs_ramp[clrs], border = rgb(0,0,0,.5))
ggsave("../figure/reg_lm_plot_35.pdf", width= 4, height = 0.66)

dev.off()

#2nd figure of best theta
pdf("../figure/reg_lm_plot_36.pdf", width= 4.5, height = 5.5)

p <- persp(x = c1_grid, y = c2_grid, sse_surf, theta = -130, phi = 10, 
           zlim = range(sse_surf),
           ticktype = "detailed", xlab = "Intercept", ylab = "Slope", zlab = "SSE", 
           col = clrs_ramp[clrs], border = rgb(0,0,0,.5))
points_3d = 
  trans3d(x = coef(m)[1], 
          y = coef(m)[2], 
          z = sse(coef(m)[1], coef(m)[2], x, y),
          pmat = p)
points(points_3d, col = c(colGreen(255)), 
       pch = 16, cex = 2)
points(points_3d, col = "black", pch = 1, cex = 2, lwd = 2)
ggsave("../figure/reg_lm_plot_36.pdf", width= 4, height = 0.66)

dev.off()

