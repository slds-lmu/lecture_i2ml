# ------------------------------------------------------------------------------
# FIG: LOG-COSH LOSS
# ------------------------------------------------------------------------------

# DATA -------------------------------------------------------------------------

source("loss_functions.R")

x <- seq(-10L, 10L, length.out = 800L)
y <- logcosh(x)

# PLOTS ------------------------------------------------------------------------

p <- ggplot2::ggplot(data.frame(x, y), aes(x = x, y = y)) +
  ggplot2::geom_line() +
  ggplot2::theme_minimal() +
  ggplot2::theme(text = element_text(size = 20L))

ggplot2::ggsave("../figure/loss_logcosh.png", p, width = 6L, height = 3L)
