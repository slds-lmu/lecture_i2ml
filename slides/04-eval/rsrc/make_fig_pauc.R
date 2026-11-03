# ------------------------------------------------------------------------------
# FIG: PARTIAL AUC
# ------------------------------------------------------------------------------

# https://www.medcalc.org/manual/roc-curve-partial-area.php

library(data.table)
library(ggforce)
library(ggplot2)

# PLOT -------------------------------------------------------------------------

p <- ggplot() +
  geom_arc(aes(x0 = 1, y0 = 0, r = 1, start = -2, end = 0)) +
  xlim(c(0, 1)) +
  ylim(c(0, 1)) +
  geom_rect(
    mapping = aes(xmin = 0.25, xmax = 0.5, ymin = 0, ymax = 1), 
    fill = NA,
    col = "blue") +
  geom_segment(mapping = aes(x = 0, xend = 1, y = 0, yend = 1), linetype = 2) +
  theme_classic() +
  labs(x = "FPR", y = "TPR")

dt <- data.table(
  x = c(rep(0.25, 4), rep(0.5, 4)),
  y = c(0, 0.25, 0.67, 1, 0, 0.5, 0.87, 1), 
  text = c("A", "h", "D", "f", "B", "g", "C", "e")
)
p <- p + geom_label(dt, mapping = aes(x = x, y = y, label = text), col = "blue")

dt <- data.table(
  x = c(0.375, 0.375, 0.375),
  y = c(0.2, 0.6, 0.9), 
  text = c("U", "V", "W")
)
p <- p + geom_label(dt, mapping = aes(x = x, y = y, label = text), col = "red", size=8)

ggsave("../figure/fig_pauc.png", p, height = 4L, width = 4L)


##########################


dt <- data.table(
  x =    c(0.00, 0.10, 0.20, 0.30, 1), 
  y =    c(0.00, 0.80, 0.85, 0.90, 1)
)



p <- ggplot() +
  geom_path(dt, mapping = aes(x = x, y = y)) +
  xlim(c(0, 1)) +
  ylim(c(0, 1)) +
  geom_segment(mapping = aes(x = 0, xend = 1, y = 0, yend = 1), linetype = 2) +
  theme_classic() +
  labs(x = "FPR", y = "TPR")


dt <- data.table(
  x =    c(0.30, 0.00),
  y =    c(0.00, 0.50),
  xend = c(0.30, 0.30),
  yend = c(0.90, 0.50)
)

#p = p + geom_path(dt, mapping = aes(x=x, y=y), linetype = "dotted")
p = p + geom_segment(dt, mapping = aes(x = x, y = y, xend = xend, yend = yend), 
  linetype="dotted")
tsize = 3
p = p + annotate("text", x = 0.2, y = 0.70, label = "TPR>0.5", size=tsize)
p = p + annotate("text", x = 0.2, y = 0.65, label = "AND", size=tsize)
p = p + annotate("text", x = 0.2, y = 0.60, label = "FPR<0.3", size=tsize)
#print(p)
ggsave("../figure/fig_pauc_2way.png", p, height = 4L, width = 4L)


