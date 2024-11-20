# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(GGally)

# PLOT -------------------------------------------------------------------------

pdf("../figure/reg_class_task_3.pdf", width = 8, height = 5)

ggpairs(iris, mapping = aes(col = Species))

ggsave("../figure/reg_class_task_3.pdf", width = 8, height = 5)
dev.off()