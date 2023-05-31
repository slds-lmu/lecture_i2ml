# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)

# DATA -------------------------------------------------------------------------

d = data.frame(prob = c(0.1, 0.7, 0.2), label = 1:3)

# PLOT -------------------------------------------------------------------------

pdf("../figure/cart_splitcriteria_3.pdf", width = 8, height = 2.2)

pl = ggplot(data = d, aes(x = label, y = prob, fill = label))
pl = pl + 
  geom_bar(stat = "identity")  + 
  theme(legend.position = "none") + 
  scale_fill_viridis_c(end = .9)
pl = pl + 
  ylab("Class prob.") + 
  xlab("Label")
print(pl)

ggsave("../figure/cart_splitcriteria_3.pdf", width = 8, height = 2.2)
dev.off()