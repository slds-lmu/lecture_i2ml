library(ggplot2)

theme_set(theme_bw())

set.seed(1)
df = data.frame(x = runif(10, -2.5, 2.5), type = FALSE)

df$y = 2 * df$x + rnorm(nrow(df))
df = rbind(df, data.frame(x = 0, type = TRUE, y = 2.5))

p = ggplot() + geom_point(data = df[!df$type, ], aes(x = x, y = y), alpha = 0.2, size = 3)
p = p + geom_abline(intercept = 0, slope = 2, colour = "blue", size = 1.2)
p = p + geom_point(data = df[df$type, ], aes(x = x, y = y), size = 3) 

p_1 = p + geom_segment(aes(x = 0, xend = 0, y = 0, yend = 2.5), colour = "orange", arrow = arrow(length = unit(0.03, "npc")))
p_1 = p_1 + annotate("text", x = -0.25, y = 1, label = "r", colour = "orange", parse = TRUE)

ggsave("../figure_man/pseudo_residual_1.png", p_1, width = 3, height = 2)

p_2 = p + geom_segment(
  aes(x = 0L, xend = 0L, y = 0L, yend = 2.5), 
  size = 1.2, 
  col = "blue")
p_2

ggsave("../figure_man/pseudo_residual_2.png", p_2, width = 3, height = 2)
