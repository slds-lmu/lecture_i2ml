# PREREQ -----------------------------------------------------------------------

library(tidyverse)
library(ggplot2)

# DATA -------------------------------------------------------------------------

set.seed(12322)

tr = BBmisc::load2("tune_example.RData")

ggd = tr$data() %>% 
  as.data.frame() %>% 
  select(iter = batch_nr, auc = classif.auc) %>% 
  mutate(auc = cummax(auc))

# PLOT -------------------------------------------------------------------------

pdf("../figure/cart_tuning_balgos_3.pdf", width = 8, height = 3)

pl = ggplot(ggd, aes(x = iter, y = auc))
pl = pl + geom_line() 
pl = pl + theme_bw()
pl = pl + 
  theme(axis.text = element_text(size = 18), 
        axis.title = element_text(size = 22)) +
  ylab("Maximal AUC") + 
  xlab("Iterations")
print(pl)

ggsave("../figure/cart_tuning_balgos_3.pdf", width = 8, height = 3)
dev.off()