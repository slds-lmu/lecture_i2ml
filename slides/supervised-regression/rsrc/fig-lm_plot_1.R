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

# PLOTS ------------------------------------------------------------------------

p_1 <- ggplot(data = data.frame(x_1, x_2, y), aes(x_1, y)) +
    theme_bw() +
    labs(x = expression(x[1])) +
    geom_point(shape = 4, col = "darkgray") + 
    geom_smooth(method = "lm", se = FALSE, col = "black") +
    geom_vline(xintercept = 0, color = "gray", linetype = "dashed") +
    geom_segment(
        mapping = aes(x = 0, y = 0, xend = 0, yend = coeffs[1]),
        linetype = "dashed",
        color = "blue"
    ) +
    geom_segment(
        mapping = aes(x = 2, y = mylm(1), xend = 2, yend = mylm(2)),
        linetype = "dashed",
        color = "blue"
    ) +
    geom_segment(
        mapping = aes(x = 1, y = mylm(1), xend = 2, yend = mylm(1)),
        linetype = "dashed"
    ) +
    geom_text(
        mapping = aes(x = 0.2, y = coeffs[1], label = "{theta[0]}"),
        color = "blue",
        vjust = 2,
        parse = TRUE
    ) +
    geom_text(
        mapping = aes(x = 2.2, y = mylm(2), label = "{theta[1]}"),
        color = "blue",
        vjust = 2,
        parse = TRUE
    ) +
    geom_text(
        mapping = aes(x = 1.5, y = mylm(1), label = "1 unit"), vjust = 2,
    )

ggsave("../figure/reg_lm_plot.pdf", p_1, width = 3, height = 2)

highlight <- data.frame(x_1, x_2, y)[33, ]
p_2 <- ggplot(data = data.frame(x_1, x_2, y), aes(x_1, y)) +
    theme_bw() +
    labs(x = expression(x[1])) +
    geom_point(shape = 4, col = "darkgray") +
    geom_smooth(method = "lm", se = FALSE, col = "black") +
    geom_hline(yintercept = mean(y)) +
    geom_point(highlight, mapping = aes(x_1, y), col = "red", size = 3) +
    geom_text(
        mapping = aes(x = -1, y = mean(y), label = "{bar(y)}"),
        vjust = 2,
        parse = TRUE
    ) +
    geom_rect(
        mapping = aes(
            xmax = highlight$x_1,
            xmin = highlight$x_1 - (highlight$y - mylm(highlight$x_1)),
            ymin = highlight$y,
            ymax = mylm(highlight$x_1),
        ),
        alpha = 0.01,
        col = "blue",
        fill = "blue",
    )

ggsave("../figure/reg_lm_sse.pdf", p_2, width = 3, height = 2.5)
