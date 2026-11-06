library(mvtnorm)
library(knitr)
library(ggplot2)
library(tidyverse)
library(tikzDevice)

options(tikzMetricPackages = c("\\usepackage[utf8]{inputenc}",
                               "\\usepackage[T1]{fontenc}", 
                               "\\usetikzlibrary{calc}",
                               "\\usepackage{amssymb}"))

d = 50

theta_1 <- seq(-1, 4, length.out = d)
theta_2 <- seq(-1, 4, length.out = d)
thetas <- as.data.frame(expand.grid(x = theta_1, y = theta_2))

R <- function(theta) -(dmvnorm(theta, c(1,1)) + 1.5 * dmvnorm(theta, c(3,3)))
thetas$nl <- apply(thetas, 1,function(theta) R(theta))

# see https://stackoverflow.com/a/39118422
z <- matrix(thetas$nl, nrow = d)
# Color palette (100 colors)
col.pal<-colorRampPalette(c("blue", "green"))
colors<-col.pal(100)
# height of facets
z.facet.center <- (z[-1, -1] + z[-1, -ncol(z)] + z[-nrow(z), -1] + z[-nrow(z), -ncol(z)])/4
# Range of the facet center on a 100-scale (number of colors)
z.facet.range<-cut(z.facet.center, 100)

fname = "err_surf"
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

pmat <- persp(theta_1, theta_2,  matrix(thetas$nl, nrow = d),
      # main="Perspective Plot of a Cone",
      xlab = "\n$\\theta_1$",
      ylab = "\n$\\theta_2$",        
      zlab = "\n$\\mathcal{R}_{\\textrm{emp}}$",
      theta = 150, phi = 50,
      col=colors[z.facet.range],
      border=NA)

points(trans3d(2.5,0,R(c(2.5,0)),pmat),pch=19, col="yellow")
points(trans3d(3,3,R(c(3,3)),pmat),pch=19, col="red")

dev.off()
tools::texi2pdf(tex_fname, clean = TRUE)
unlink(dest_pdf)
file.copy(pdf_fname, dest_pdf)

# clean-up
unlink(pdf_fname)
unlink(tex_fname)      

