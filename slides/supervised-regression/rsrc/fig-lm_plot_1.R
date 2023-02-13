# PREREQ -----------------------------------------------------------------------

library(ggplot2)
source("libfuns_lm.R")

# DATA -------------------------------------------------------------------------

set.seed(123)
x_1 <- rnorm(50, mean = 1, sd = 1)
set.seed(456)
x_2 <- rnorm(50, mean = 1, sd = 1)
y <- 0.5 * x_1 + rnorm(length(x_1), sd = 0.5) + 1
coeffs <- lm(y ~ x_1)$coefficients

# PLOTS ------------------------------------------------------------------------

p_1 <- make_lm_l2_plot(
    x_1, y, coeffs, "black", pcol = "gray", add_squares = FALSE
) +
    geom_vline(xintercept = 0, color = "gray", linetype = "dashed") +
    geom_segment(
        mapping = aes(x = 0, y = 0, xend = 0, yend = coeffs[1]),
        color = "blue"
    ) +
    geom_segment(
        mapping = aes(
            x = 2, 
            y = univariate_lm(1, coeffs), 
            xend = 2, 
            yend = univariate_lm(2, coeffs)
        ),
        color = "blue"
    ) +
    geom_segment(
        mapping = aes(
            x = 1, 
            y = univariate_lm(1, coeffs), 
            xend = 2, 
            yend = univariate_lm(1, coeffs)
        ),
    ) +
    geom_text(
        mapping = aes(x = 0.2, y = coeffs[1], label = "{theta[0]}"),
        color = "blue",
        vjust = 2,
        parse = TRUE
    ) +
    geom_text(
        mapping = aes(
            x = 2.2, y = univariate_lm(2, coeffs), label = "{theta[1]}"
        ),
        color = "blue",
        vjust = 2,
        parse = TRUE
    ) +
    geom_text(
        mapping = aes(
            x = 1.5, y = univariate_lm(1, coeffs), label = "1 unit"
        ), 
        vjust = 2,
    )
ggsave("../figure/reg_lm_plot.pdf", p_1, width = 3, height = 2)

highlight <- data.frame(x_1, x_2, y)[33, ]
p_2 <- make_lm_l2_plot(
    highlight$x_1, highlight$y, coeffs, "blue", pcol = "gray"
) + 
    geom_point(
        data.frame(x_1, y), 
        mapping = aes(x_1, y), 
        col = "gray", 
        size = 3,
        shape = 4
    ) +
    geom_hline(yintercept = mean(y)) +
    geom_point(highlight, mapping = aes(x_1, y), col = "red", size = 3)+
    geom_text(
        mapping = aes(x = -1, y = mean(y) - 1, label = "{bar(y)}"),
        vjust = 1,
        parse = TRUE
    )
ggsave("../figure/reg_lm_sse.pdf", p_2, width = 3, height = 2.6)
