library(knitr)
library(ggplot2)
library(tidyverse)
library(tikzDevice)

options(tikzMetricPackages = c("\\usepackage[utf8]{inputenc}",
                               "\\usepackage[T1]{fontenc}", 
                               "\\usetikzlibrary{calc}",
                               "\\usepackage{amssymb}"))

R <- function(x) (x[1]^2 + 3*x[2]^2)
d_R <- function(x) c(2*x[1], 6*x[2])

  d = 50
  
  theta_1 <- seq(-5, 5, length.out = d)
  theta_2 <- seq(-5, 5, length.out = d)
  thetas <- as.data.frame(expand.grid(x = theta_1, y = theta_2))
  
  thetas$R <- apply(thetas, 1,function(theta) R(theta))
  
  # see https://stackoverflow.com/a/39118422
  z <- matrix(thetas$R, nrow = d)
  # Color palette (100 colors)
  col.pal<-colorRampPalette(c("blue", "green"))
  colors<-col.pal(100)
  # height of facets
  z.facet.center <- (z[-1, -1] + z[-1, -ncol(z)] + z[-nrow(z), -1] + z[-nrow(z), -ncol(z)])/4
  # Range of the facet center on a 100-scale (number of colors)
  z.facet.range<-cut(z.facet.center, 100)
  
fname = "grad_desc1"
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

pmat <- persp(theta_1, theta_2,  matrix(thetas$R, nrow = d),
  xlab = "\n$\\theta_1$",
  ylab = "\n$\\theta_2$",        
  zlab = "\n$\\mathcal{R}_{\\textrm{emp}}$",
  theta = 150, phi = 50,
  col=colors[z.facet.range],
  border=NA)

x_i <- c(4, -4.5)
t_x_i <- trans3d(x_i[1],x_i[2],R(x_i),pmat)
points(t_x_i,pch=19, col="magenta")
text(x = t_x_i$x + 0.1, y = t_x_i$y + 0.02, "$\\theta^{(0)}$", col="magenta", cex = 2)
dev.off()
tools::texi2pdf(tex_fname, clean = TRUE)
unlink(dest_pdf)
file.copy(pdf_fname, dest_pdf)

# clean-up
unlink(pdf_fname)
unlink(tex_fname)  

fname = "grad_desc2"
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

pmat <- persp(theta_1, theta_2,  matrix(thetas$R, nrow = d),
  xlab = "\n$\\theta_1$",
  ylab = "\n$\\theta_2$",        
  zlab = "\n$\\mathcal{R}_{\\textrm{emp}}$",
  theta = 150, phi = 50,
  col=colors[z.facet.range],
  border=NA)

x_i <- c(4, -4.5)
t_x_i <- trans3d(x_i[1],x_i[2],R(x_i),pmat)
points(t_x_i,pch=19, col="magenta")
x_i_n <- x_i - 0.05 * d_R(x_i)
t_x_i_n <- trans3d(x_i_n[1],x_i_n[2],R(x_i_n),pmat)
arrows(x0 = t_x_i$x, y0=t_x_i$y, x1=t_x_i_n$x, y1=t_x_i_n$y, col="magenta", length = 0.15, lwd = 2)
text(x = (t_x_i$x+t_x_i_n$x)/2 + 0.4, y = (t_x_i$y+t_x_i_n$y)/2 + 0.04, "$-\\lambda\\frac{\\partial}{\\partial\\theta}\\mathcal{R}_{\\textrm{emp}}(\\theta^{(0)})$", col="magenta", cex = 2)  

dev.off()
tools::texi2pdf(tex_fname, clean = TRUE)
unlink(dest_pdf)
file.copy(pdf_fname, dest_pdf)

# clean-up
unlink(pdf_fname)
unlink(tex_fname)  

fname = "grad_desc3"
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

pmat <- persp(theta_1, theta_2,  matrix(thetas$R, nrow = d),
  xlab = "\n$\\theta_1$",
  ylab = "\n$\\theta_2$",        
  zlab = "\n$\\mathcal{R}_{\\textrm{emp}}$",
  theta = 150, phi = 50,
  col=colors[z.facet.range],
  border=NA)

x_i <- c(4, -4.5)
t_x_i_n <- trans3d(x_i_n[1],x_i_n[2],R(x_i_n),pmat)
points(t_x_i_n, pch=19, col="magenta")
text(x = t_x_i_n$x + 0.1, y = t_x_i_n$y + 0.02, "$\\theta^{(1)}$", col="magenta", cex = 2)
dev.off()
tools::texi2pdf(tex_fname, clean = TRUE)
unlink(dest_pdf)
file.copy(pdf_fname, dest_pdf)

# clean-up
unlink(pdf_fname)
unlink(tex_fname)  
