# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

my_df <- data.frame(
  x_1 = -2, 
  x_2 = 0, 
  x_3 = 2, 
  y_1 = 0, 
  y_2 = 1 )

# PLOT -------------------------------------------------------------------------

pdf("../figure/zero-one-loss.pdf", width = 8, height = 4)

ggplot(my_df) +
  geom_segment(aes(x = x_1, xend = x_2, y = y_2, yend = y_2)) +
  geom_segment(aes(x = x_2, xend = x_2, y = y_1, yend = y_2)) +
  geom_segment(aes(x = x_2, xend = x_3, y = y_1, yend = y_1)) +
  xlab("y - h(x)") +
  ylab("L(y - h(x))") + 
  scale_y_continuous(breaks = seq(0, 1, by = 1)) +
  scale_x_continuous(breaks = c(0)) +
  theme(
    axis.text = element_text(size = 30),
    axis.title = element_text(size = 30))

ggsave("../figure/zero-one-loss.pdf", width = 8, height = 4)
dev.off()
