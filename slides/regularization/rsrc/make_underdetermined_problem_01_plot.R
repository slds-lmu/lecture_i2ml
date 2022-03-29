# ------------------------------------------------------------------------------
# FIG: UNDER-DETERMINED PROBLEM 01
# ------------------------------------------------------------------------------

library(mlr)
library(mlbench)
library(ggplot2)
library(BBmisc)
library(reshape)
library(viridis)

# DATA -------------------------------------------------------------------------

X <- as.data.frame(matrix(c(0, 1, 1,    0.25, 0,    0.75, 0.75, 0.25,
                            1, 0, 0.75, 0,    0.25, 1,    0.25, 0.75),
                          ncol=2, byrow = FALSE))
colnames(X) <- c("x1", "x2")
X$type <- as.factor(as.character(c(-1, 1, 1, 1, -1, -1, -1, 1)))

# PLOTS ------------------------------------------------------------------------

plot_data <- ggplot(X, aes(x=x1, y=x2)) +
  geom_point(aes(colour=type), size=2) +
  labs(colour="Class") + #theme(legend.position = "bottom") +
  coord_fixed() + theme(legend.margin=margin(t = 0, unit='cm')) +
  xlab(expression(x[1])) +
  ylab(expression(x[2])) +
  annotate("label", x=0.9, y=0.3, label="x^(7)", parse=TRUE, size=2) +
  annotate("label", x=0.4, y=0.8, label="x^(8)", parse=TRUE, size=2) +
  scale_color_viridis(end = 0.9, discrete = TRUE)

dec_bounds <- rbind(data.frame(x = c(-Inf, Inf, -Inf), y = c(-Inf, Inf, Inf), type=-1),
                    data.frame(x = c(-Inf, Inf, Inf), y = c(-Inf, Inf, -Inf), type=1)
)

dec_bounds$type <- as.factor(dec_bounds$type)

plot_dec_bound <- plot_data +
  geom_polygon(data = dec_bounds,
               aes(x,y, fill=type), alpha=0.3) +
  guides(fill=FALSE) +
  scale_fill_viridis(end = 0.9, discrete = TRUE)

p <- grid.arrange(plot_data, plot_dec_bound, ncol=2)

ggsave("../figure/underdetermined_problem_01.png", plot = p, width = 6, height = 2)