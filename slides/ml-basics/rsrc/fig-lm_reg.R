library(ggplot2)

# DATA -------------------------------------------------------------------------

set.seed(pi)

x = 1:5
y = x + rnorm(5, 0, 2)
m = lm(y ~ x)

# FUNCTIONS --------------------------------------------------------------------

colBlue = function(alpha) { rgb(135, 206, 255, alpha, maxColorValue = 255) }
colGreen = function(alpha) { rgb(188, 238, 104, alpha, maxColorValue = 255) }

data_plot = function(x, y) {
  
  plot(x, 
       y, 
       ylim = c(-2, 6), 
       xlim = c(0, 8), 
       cex = 2, 
       pch = 4, 
       las = 1, 
       ann = "false")
  
  grid()
  
}

add_lm = function(coef, color, coef_label) {
  
  abline(coef = coef, col = color(255), lwd = 3)
  coef <- round(coef, 1)
  
  text(x = coef_label[1], 
       y = coef_label[2], 
       labels = bquote(theta == "("~.(coef[1])~","~.(coef[2])~")"),
       col = color(255))
  
}

add_errors = function(x, y, coef, color, sse_label) {
  
  hat_y = cbind(1, x) %*% coef
  w = abs(y - hat_y)
  
  rect(xleft = x, 
       ybottom = y, 
       xright = x + w, 
       ytop = hat_y, 
       col = color(90),
       border = color(120), 
       lwd = 2)
  
  text(x = sse_label[1], 
       y = sse_label[2], 
       labels = bquote(R[emp] == ~ .(sum(round(w^2, 2)))), #paste0("SSE: ", sum(round(w^2, 2))),
       col = color(255))
  
  points(x, y, cex = 2, pch = 4, lwd = 2)
  
}

sse = function(c1, c2, x, y) {
  
  hat_y = cbind(1, x) %*% c(c1, c2)
  w = abs(y - hat_y)
  sum(w^2)
  
}

frame_plot = function(x, y, coef, color, coef_label, sse_label) {
  
  data_plot(x, y)
  add_lm(coef, color, coef_label)
  add_errors(x, y, coef, color, sse_label)
  
}

surface_plot = function (z = sse_surf,
                         error_type = "\n$\\mathcal{R}_{\\textrm{emp}}$", 
                         title = NULL,
                         palette = clrs_ramp[clrs],
                         ...) {
  
  persp(x = c1_grid, 
        y = c2_grid,
        z = z,
        theta = -130,
        phi = 10, 
        ticktype = "detailed", 
        xlab = "\nIntercept", 
        ylab = "\nSlope", 
        zlab = error_type, 
        main = title,
        col = palette, 
        border = rgb(0, 0, 0,.5))
  
}

pdf("../figure/lm_reg1.pdf", height = 3, width = 4)
coef1 <- c(0.3, 0)
frame_plot(x, y, coef1, colBlue, c(2, 5.5), c(x = 6.5, y = -0.5))
dev.off()

pdf("../figure/lm_reg2.pdf", height = 3, width = 4)
frame_plot(x, y, coef(m), colGreen, c(2, 5.5), c(x = 6.5, y =  -0.5))
dev.off()


pdf("../figure/lm_reg3.pdf", height = 3, width = 4)
data_plot(x,y) 
num_lines <- 6
offset <- 3
set.seed(234)
cl <- rainbow(offset+num_lines)
for(i in 1:num_lines){
  abline( coef = runif(2,-5,5), lwd=1, col=cl[offset+i], lty=i)
}
dev.off()

library(knitr)
library(ggplot2)
library(tidyverse)
library(tikzDevice)

options(tikzMetricPackages = c("\\usepackage[utf8]{inputenc}",
                               "\\usepackage[T1]{fontenc}", 
                               "\\usetikzlibrary{calc}",
                               "\\usepackage{amssymb}"))
#pdf("../figure/reg_lm_plot_36.pdf", width = 4.5, height = 5.5)
fname = "lm_reg4"
tex_fname = paste0(fname, ".tex")
pdf_fname = paste0(fname, ".pdf")
dest_pdf =  paste0("../figure/", pdf_fname)

# In order to get mathcal fonts to work system-independently we create a 
# temporary tex-file. For more information see 
# https://yihui.org/en/2011/04/produce-authentic-math-formulas-in-r-graphics/
tikz(tex_fname, width = 4, height = 4, standAlone = TRUE,
     packages = c("\\usepackage{tikz}",
                  "\\usepackage[active,tightpage,psfixbb]{preview}",
                  "\\PreviewEnvironment{pgfpicture}",
                  "\\setlength\\PreviewBorder{0pt}",
                  "\\usepackage{amssymb}"))


gridlength <- 30
c1_grid = seq(-2, 2, l = gridlength)
c2_grid = seq(0, 1.5, l = gridlength)

sse_surf = outer(c1_grid, c2_grid, Vectorize(sse, c("c1", "c2")), x = x, y = y)
clrs_ramp = scales::alpha(colorRampPalette(viridisLite::plasma(5))(200), .5)

clrs = sse_surf[-1, -1] + sse_surf[-1, -gridlength] + 
  sse_surf[-gridlength, -1] + sse_surf[-gridlength, -gridlength]

clrs = cut(clrs, length(clrs_ramp))

p = surface_plot(zlim = range(sse_surf))

points_3d = 
  trans3d(x = cbind(coef1, coef(m))[1, ], 
          y = cbind(coef1, coef(m))[2, ], 
          z = c(sse(coef1[1], coef1[2], x, y), 
                sse(coef(m)[1], coef(m)[2], x, y)),
          pmat = p)

points(points_3d,
       col = c(colBlue(255), 
               colGreen(255)), 
       pch = 16, cex = 2)

points(points_3d, col = "black", pch = 1, cex = 2, lwd = 2)

dev.off()
tools::texi2pdf(tex_fname, clean = TRUE)
unlink(dest_pdf)
file.copy(pdf_fname, dest_pdf)

# clean-up
unlink(pdf_fname)
unlink(tex_fname)  



