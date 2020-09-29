# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(gridExtra)

# FUNCTIONS --------------------------------------------------------------------

myd = function(x, size, p) dbinom(round(x * size), p = p, size = size)

sample_some_errs = function(k) rbinom(k, size = size, p = p) / size

plot_dens_with_errs = function(k) {
  
  minerr = min(d.errs[1:k, "x"])
  label = sprintf("n = %i; #runs = %i; best err = %.2f", size, k, minerr)
  
  pl = ggplot(mapping = aes(x = x, y = y)) + geom_line(data = d.dens)
  pl = pl + geom_point(data = d.errs[1:k,])
  pl = pl + geom_vline(xintercept = minerr, col = "red")
  # pl = pl + geom_label()
  pl = pl + ggtitle(label = label)
  pl = pl + 
    xlab("Test Error") + 
    ylab("Density") + 
    theme(plot.title = element_text(size = 12))
  
  return(pl)
  
}

# DATA -------------------------------------------------------------------------

set.seed(123)

size = 200
p = 0.5

dens.x = seq(0, 1, length.out = 100)
dens.y = myd(dens.x, p = p, size = size)
d.dens = data.frame(x = dens.x, y = dens.y)

errs = sample_some_errs(1000)
d.errs = data.frame(x = errs, y = 0.0)

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/cart_tuning_nestintro_2.pdf", width = 8, height = 3.5)

pl1 = plot_dens_with_errs(k = 1)
pl2 = plot_dens_with_errs(k = 10)
grid.arrange(pl1, pl2, ncol = 2)

ggsave("../figure/cart_tuning_nestintro_2.pdf", width = 8, height = 3.5)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/cart_tuning_nestintro_3.pdf", width = 8, height = 3.5)

pl3 = plot_dens_with_errs(k = 100)
pl4 = plot_dens_with_errs(k = 1000)
grid.arrange(pl3, pl4, ncol = 2)

ggsave("../figure/cart_tuning_nestintro_3.pdf", width = 8, height = 3.5)
dev.off()