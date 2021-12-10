# ------------------------------------------------------------------------------
# FIG: ENTROPY
# ------------------------------------------------------------------------------

library(ggplot2)
library(gridExtra)


# DATA -------------------------------------------------------------------------

p1 <- c(0.2, 0.2, 0.2, 0.2, 0.2)
p2 <- c(0.1, 0.2, 0.4, 0.2, 0.1)
p3 <- c(0.4, 0.2, 0.2, 0.1, 0.1)
p4 <- c(0.1, 0.1, 0.6, 0.1, 0.1)

# PLOTS ------------------------------------------------------------------------

plot_ent <- function(p) {
  n <- length(p)
  lp <- -log(p)
  lp <- ifelse(p == 0, 0, lp)
  r <- p * lp
  H <- sum(r)
  dd <- data.frame(x = 1:n, p = p, lp = lp, r = r)
  pl <- ggplot(data = dd, aes(x = x)) +
    geom_bar(aes(y = p), stat = "identity") +
    ggtitle(sprintf("Entropy H(p) = %.1f", H)
    )
  return(pl)
}

p <- grid.arrange(grobs = lapply(list(p1, p2, p3, p4), plot_ent), nrow = 2, ncol = 2)
ggsave(filename = "../figure/entropy_plot.png", plot = p, width = 5, height = 3)