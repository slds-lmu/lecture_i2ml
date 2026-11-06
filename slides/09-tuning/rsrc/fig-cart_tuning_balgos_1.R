# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)

source("plotTune.R")

# DATA -------------------------------------------------------------------------

set.seed(123)

x_1 = y_1 = seq(-10, 10, length.out = 10)
d_1 = expand.grid(x = x_1, y = y_1)

x_2 = runif(100, -10, 10)
y_2 = runif(100, -10, 10)
d_2 = data.frame(x = x_2, y = y_2)

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/cart_tuning_balgos_1.pdf", width = 8, height = 3.5)

pl = plotTune(d_1)
print(pl)

ggsave("../figure/cart_tuning_balgos_1.pdf", width = 8, height = 3.5)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/cart_tuning_balgos_2.pdf", width = 8, height = 3.5)

pl = plotTune(d_2)
print(pl)

ggsave("../figure/cart_tuning_balgos_2.pdf", width = 8, height = 3.5)
dev.off()