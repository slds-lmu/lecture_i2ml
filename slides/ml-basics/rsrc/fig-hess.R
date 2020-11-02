library(knitr)
library(ggplot2)
library(tidyverse)
library(tikzDevice)

options(tikzMetricPackages = c("\\usepackage[utf8]{inputenc}",
                               "\\usepackage[T1]{fontenc}", 
                               "\\usetikzlibrary{calc}",
                               "\\usepackage{amssymb}"))

create_hess_plot <- function(R, name){
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

fname = paste0("hess", name)
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

persp(theta_1, theta_2,  matrix(thetas$R, nrow = d),
              xlab = "\n$\\theta_1$",
              ylab = "\n$\\theta_2$",        
              zlab = "\n$\\mathcal{R}_{\\textrm{emp}}$",
              theta = 150, phi = 50,
              col=colors[z.facet.range],
              border=NA)

dev.off()
tools::texi2pdf(tex_fname, clean = TRUE)
unlink(dest_pdf)
file.copy(pdf_fname, dest_pdf)

# clean-up
unlink(pdf_fname)
unlink(tex_fname)  
}

R <- function(x) (x[1]^2 + 3*x[2]^2)
create_hess_plot(R, "1")
create_hess_plot(function(x) -R(x), "2")

