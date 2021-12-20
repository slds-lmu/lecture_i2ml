# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

my_df <- data.frame(
  x_1 = -1, 
  x_2 = 1, 
  x_3 = 3, 
  y_1 = 1, 
  y_2 = 0 )

# PLOT -------------------------------------------------------------------------

p <- ggplot(my_df) +
  geom_segment(aes(x = x_1, xend = x_2, y = y_2, yend = y_2), size = 2L) +
  geom_segment(aes(x = x_2, xend = x_2, y = y_1, yend = y_2), size = 2L) +
  geom_segment(aes(x = x_2, xend = x_3, y = y_1, yend = y_1), size = 2L) +
  xlab(as.expression(bquote("[y" != "h(x)]"))) +
  ylab("L(y, h(x))") + 
  scale_y_continuous(breaks = seq(0L, 1L, by = 1L)) +
  scale_x_continuous(breaks = c(1L)) +
  theme(
    axis.text = element_text(size = 30L),
    axis.title = element_text(size = 30L))

ggsave("../figure/zero-one-loss.pdf", p, width = 8, height = 4)
dev.off()
