# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(tidyverse)
library(tikzDevice)

options(tikzMetricPackages = c("\\usepackage[utf8]{inputenc}",
                               "\\usepackage[T1]{fontenc}", "\\usetikzlibrary{calc}",
                               "\\usepackage{amssymb}"))


# DATA -------------------------------------------------------------------------

set.seed(1221)
n = 50
data = data.frame(x = seq(-4 , 2, l = n)) %>% 
  mutate(y = ifelse(x < 0, 
                    2.5 + rnorm(n), 
                    2 - 3 * plogis(x) + .5 * rnorm(n)))

datal = subset(data, x < 0)
datar = subset(data, x > 0)

# PLOT -------------------------------------------------------------------------

fname = "cart_splitcriteria_2"
tex_fname = paste0(fname, ".tex")
pdf_fname = paste0(fname, ".pdf")
dest_pdf =  paste0("../figure/", pdf_fname)

# In order to get mathcal fonts to work system-independently we create a 
# temporary tex-file. For more information see 
# https://yihui.org/en/2011/04/produce-authentic-math-formulas-in-r-graphics/
tikz(tex_fname, width = 8, height = 3, standAlone = TRUE,
     packages = c("\\usepackage{tikz}",
                  "\\usepackage[active,tightpage,psfixbb]{preview}",
                  "\\PreviewEnvironment{pgfpicture}",
                  "\\setlength\\PreviewBorder{0pt}",
                  "\\usepackage{amssymb}"))
p1 = ggplot(data) + 
  geom_point(aes(x, y)) + 
  geom_segment(
    aes(x = min(x), xend = max(x), y = mean(y), yend = mean(y)), col = "red") +
  geom_point(aes(x, y), alpha = .5) + 
  theme_light(base_size = 16) + 
  scale_y_continuous(breaks = mean(data$y), labels = "c", ) +
  scale_x_continuous("$x_j$", 
                     breaks = NULL,
                     minor_breaks = NULL) + 
  theme(axis.text.y = element_text(colour = "red"),
        panel.grid.major = element_line(colour = NA),
        plot.margin = unit(c(3, 3, 1, 1), "lines")) +
  annotation_custom(
    grob = grid::textGrob(label = "$\\mathcal{N}$", 
                          gp = grid::gpar(fontsize = 18)), 
    ymin =  max(data$y) + 1,
    ymax =  max(data$y) + 1,
    xmin = mean(data$x),
    xmax = mean(data$x)) +
  annotation_custom(
    grob = grid::textGrob(label = "$\\Rightarrow$", 
                          gp = grid::gpar(fontsize = 28)), 
    ymin =  mean(data$y),
    ymax =  mean(data$y) ,
    xmin = max(data$x) + 1,
    xmax = max(data$x) + 1)  +
  coord_cartesian(clip = 'off')

p2 = ggplot(data) + 
  geom_point(aes(x, y)) + 
  geom_segment(data = datal, 
               aes(x = min(x), xend = 0, y = mean(y), yend = mean(y)),
               col = "red") +
  geom_segment(data = datar, 
               aes(x = max(x), xend = 0, y = mean(y), yend = mean(y)),
               col = "red") +
  geom_point(aes(x,y), alpha = .5) + 
  theme_light(base_size = 16) + 
  scale_y_continuous(breaks = c(mean(datal$y), mean(datar$y)), 
                     minor_breaks = NULL,
                     labels = c("$c_1$", "$c_2$")) +
  scale_x_continuous("$x_j$", 
                     breaks = NULL) + 
  theme(axis.text.y = element_text(colour = "red"),
        panel.grid.major = element_line(colour = NA),
        plot.margin = unit(c(3, 1, 1, 1), "lines")) +
  annotation_custom(
    grob =  grid::textGrob(label = "$\\mathcal{N}_1$",
                           gp = grid::gpar(fontsize = 18)), 
    ymin =  max(data$y) + 1,
    ymax =  max(data$y) + 1,
    xmin = mean(datal$x),
    xmax = mean(datal$x)) +
  annotation_custom(
    grob = grid::textGrob(label = "$\\mathcal{N}_2$",
                          gp = grid::gpar(fontsize = 18)), 
    ymin =  max(data$y) + 1,
    ymax =  max(data$y) + 1,
    xmin = mean(datar$x),
    xmax = mean(datar$x)) +
  geom_vline(xintercept = 0, lty = 3, alpha = .5) +
  annotation_custom(
    grob = grid::textGrob(label = "t"), 
    ymin =  min(data$y) - .5,
    ymax =  min(data$y) - .5,
    xmin = 0,
    xmax = 0) +
  coord_cartesian(clip = 'off')

gridExtra::grid.arrange(p1, p2, nrow = 1, widths = c(1.2, 1))

dev.off()
tools::texi2pdf(tex_fname, clean = TRUE)
unlink(dest_pdf)
file.copy(pdf_fname, dest_pdf)

# clean-up
unlink(pdf_fname)
unlink(tex_fname)