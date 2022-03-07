# ------------------------------------------------------------------------------
# FIG: SVM LOSSES PLOTS
# ------------------------------------------------------------------------------

source("utils.R")
soft_margin_losses_p <- plot_losses(c("01", "hinge"))

ggsave(filename = "../figure/soft_margin_losses.png", plot = soft_margin_losses_p, width = 6, height = 1.6)

######################################################

other_losses_p <- plot_losses(c("01", "hinge", "sqhinge", "huber", "log"))

ggsave(filename = "../figure/other_losses.png", plot = other_losses_p, width = 6, height = 2.2)