# PREREQ -----------------------------------------------------------------------

library(data.table)
library(ggplot2)

# DATA -------------------------------------------------------------------------

tpr <- ppv <- seq(0L, 1L, by = 0.2)

compute_f_1 <- function(ppv, tpr) {
  f_1 <- 2 * ppv * tpr / (ppv + tpr)
  ifelse(is.na(f_1), 0, f_1)}

scores <- data.table::data.table(expand.grid(tpr, ppv))
data.table::setnames(scores, c("tpr", "ppv"))
scores[, f_1 := compute_f_1(ppv, tpr)]

# PLOT -------------------------------------------------------------------------

p <- ggplot2::ggplot(scores, aes(x = ppv, y = tpr, fill = f_1)) +
  geom_tile() +
  geom_text(aes(label = round(f_1, 2L)), color = "white") +
  scale_fill_gradient(
    low = "darkseagreen4",
    high = "black") +
  scale_x_continuous(breaks = ppv) +
  scale_y_continuous(breaks = tpr) +
  xlab(expression(paste(italic(rho[PPV])))) +
  ylab(expression(paste(italic(rho[TPR])))) +
  theme(text = element_text(size = 20L), legend.position = "none")

ggsave("../figure/eval_mclass_roc.pdf", p, height = 4L, width = 4L)
