# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)

# DATA -------------------------------------------------------------------------

ggd = BBmisc::load2("overtuning-example.RData", "res2.mean")

ggd = reshape2::melt(ggd, 
                     measure.vars = colnames(res2), 
                     value.name = "tuneperf")

colnames(ggd)[1:2] = c("data.size", "iter")
ggd = BBmisc::sortByCol(ggd, c("data.size", "iter"))
ggd$data.size = as.factor(ggd$data.size)

# PLOT -------------------------------------------------------------------------

pdf("../figure/cart_tuning_nestintro_1.pdf", width = 8, height = 3.5)

pl = ggplot(ggd, aes(x = iter, y = tuneperf, col = data.size))
pl =  pl + 
  geom_line() + 
  ylab("Tuning Error") + 
  xlab("Iteration") + 
  labs(colour = "Data Size") +
  scale_color_viridis_d(end = .9)
print(pl)

ggsave("../figure/cart_tuning_nestintro_1.pdf", width = 8, height = 3.5)
dev.off()