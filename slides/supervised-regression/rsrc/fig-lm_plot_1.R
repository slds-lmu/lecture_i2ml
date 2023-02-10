# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)

# DATA -------------------------------------------------------------------------

set.seed(123)
x_1 <- rnorm(50, mean = 1, sd = 1)
set.seed(456)
x_2 <- rnorm(50, mean = 1, sd = 1)
y <- 0.5 * x_1 + rnorm(length(x_1), sd = 0.5) + 1
coeffs <- lm(y ~ x_1)$coefficients

mylm <- function(x, theta_vec = coeffs) theta_vec[1] + theta_vec[2] * x

# PLOT -------------------------------------------------------------------------

p <- ggplot(data = data.frame(x_1, x_2, y), aes(x_1, y)) +
    theme_bw() +
    geom_point(color = "gray") + 
    geom_smooth(method = "lm", se = FALSE) +
    geom_vline(xintercept = 0, color = "gray", linetype = "dashed") +
    geom_segment(
        mapping = aes(x = 0, y = 0, xend = 0, yend = coeffs[1]),
        linetype = "dashed",
        color = "red"
    ) +
    geom_segment(
        mapping = aes(x = 2, y = mylm(1), xend = 2, yend = mylm(2)),
        linetype = "dashed",
        color = "red"
    ) +
    geom_segment(
        mapping = aes(x = 1, y = mylm(1), xend = 2, yend = mylm(1)),
        linetype = "dashed"
    ) +
    geom_text(
        mapping = aes(x = 0.2, y = coeffs[1], label = "{theta[0]}"),
        color = "red",
        vjust = 2,
        parse = TRUE
    ) +
    geom_text(
        mapping = aes(x = 2.2, y = mylm(2), label = "{theta[1]}"),
        color = "red",
        vjust = 2,
        parse = TRUE
    ) +
    geom_text(
        mapping = aes(x = 1.5, y = mylm(1), label = "1 unit"), vjust = 2,
    )

ggsave("../figure/reg_lm_plot.pdf", p, width = 3, height = 2)
