# ------------------------------------------------------------------------------
# FIG: IRIS SCATTER
# ------------------------------------------------------------------------------

library("ggplot2")
library("viridis")

theme_set(theme_minimal())

# DATA -------------------------------------------------------------------------

data(iris)

# only select petal variable
iris_sub <- iris[c("Petal.Length", "Petal.Width", "Species")]

# PLOTS ------------------------------------------------------------------------

scatter <- ggplot(data=iris_sub, aes(x = Petal.Length, y = Petal.Width, colour = Species)) +
  geom_point(size = 2) +
  xlab("Petal Width") +
  ylab("Petal Length") +
  xlim(0, 7.5) +
  ylim(0, 3) +
  scale_color_viridis(end=0.9, discrete = TRUE) +
  theme(text = element_text(size = 15),
        legend.position="bottom",
        legend.direction="horizontal")

ggsave("../figure/iris_scatter.png", scatter, width = 8L, height = 4L)
