# PREREQ -----------------------------------------------------------------------

library(data.table)
library(ggplot2)

# DATA -------------------------------------------------------------------------

load("holdout-biasvar.RData")

# PLOT 1 -----------------------------------------------------------------------

pl1 = ggplot(ggd[ggd$type == "holdout", ], aes(x = split, y = mce))
pl1 = pl1 + geom_boxplot()
pl1 = pl1 + geom_hline(yintercept = true_performance)
pl1 = pl1 + theme(axis.text.x = element_text(angle = 45))

ggsave("../figure/test-holdout-example.pdf", pl1, width = 8, height = 3.5)  

# PLOT 2 -----------------------------------------------------------------------

pl2 = ggplot(gmse[gmse$type == "holdout", ], aes(x = split, y = mse))
pl2 = pl2 + geom_line()
pl2 = pl2 + scale_y_log10()
pl2 = pl2 + scale_x_continuous(breaks = gmse$split)
pl2 = pl2 + theme(axis.text.x = element_text(angle = 45))

ggsave("../figure/test-holdout-example-2.pdf", pl2, width = 8, height = 3.5)  