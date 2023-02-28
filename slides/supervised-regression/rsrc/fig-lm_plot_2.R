# PREREQ -----------------------------------------------------------------------

library(plotly)
library(reshape2)

# DATA -------------------------------------------------------------------------

petal_lm <- lm(Petal.Length ~ 0 + Sepal.Length + Sepal.Width, data = iris)

# PLOTS ------------------------------------------------------------------------

axis_x <- seq(min(iris$Sepal.Length), max(iris$Sepal.Length), by = 0.05)
axis_y <- seq(min(iris$Sepal.Width), max(iris$Sepal.Width), by = 0.05)

petal_lm_surface <- expand.grid(
    Sepal.Length = axis_x, Sepal.Width = axis_y, KEEP.OUT.ATTRS = F
)
petal_lm_surface$Petal.Length <- predict.lm(
    petal_lm, newdata = petal_lm_surface
)
petal_lm_surface <- acast(
    petal_lm_surface, Sepal.Width ~ Sepal.Length, value.var = "Petal.Length"
)
p_1 <- plot_ly(
    iris,
    x = ~Sepal.Length, 
    y = ~Sepal.Width, 
    z = ~Petal.Length,
    type = "scatter3d",
    marker = list(color = "darkgray", symbol = "cross")
) %>% 
    add_trace(
        z = petal_lm_surface,
        x = axis_x,
        y = axis_y,
        type = "surface",
        colorscale = list(c(0, 1), c("blue", "blue")), 
        opacity = 0.7
    )
p_1
