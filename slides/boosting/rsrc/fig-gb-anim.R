# ------------------------------------------------------------------------------
# FIG: TREE-BASED GRADIENT BOOSTING ANIMATION
# ------------------------------------------------------------------------------

# Purpose: visualize tree-based gb with running animation

library(BBmisc)
library(rpart)
library(gridExtra)
library(ggplot2)
library(knitr)
library(data.table)

# DATA -------------------------------------------------------------------------

set.seed(122L)
n <- 50L
x <- sort(10L * runif(n))
X <- data.frame(x_1 = x)
y <- sin(x) + rnorm(length(x), mean = 0L, sd = sqrt(0.01))

# FUNCTIONS --------------------------------------------------------------------

# Define function that plots data + model and residuals + b^m side by side

plot_model <- function(m, x_1, y_hat, r, r_hat, beta) {
  
  d <- c(0L, (x_1[-1L] - x_1[-length(x_1)]) / 2L, 0L)
  
  x_grid <- rbind(
    x_1 - d[seq_len(length(x_1))], 
    x_1 + d[seq_len(length(x_1)) + 1L])
  
  y_hat_grid <- rep(y_hat, each = 2L)
  r_hat_grid <- rep(r_hat, each = 2L)
  
  p_1 <- ggplot2::ggplot() +
    ggplot2::geom_point(aes(x = x_1, y = y), alpha = 0.5) +
    ggplot2::geom_steps(aes(x = x_grid, y = y_hat_grid)) +
    ggplot2::ggitle(
      label = NULL , 
      subtitle = sprintf("m = %i: data and model ", m))
  
  p_2 <- ggplot2::ggplot() +
    ggplot2::geom_point(aes(x = x_1, y = r), alpha = 0.5) +
    ggplot2::geom_steps(aes(x = x_grid, y = r_hat_grid)) +
    ggplot2::ggitle(
      label = NULL , 
      subtitle = expression(r^{"[m]"} ~ "and" ~ beta * b^{"[m]"}))
  
  gridExtra::grid.arrange(p_1, p_2, nrow = 1L)
  
}

# PLOTS ------------------------------------------------------------------------

# Plot data & initial constant model

p_1 <- ggplot2::ggplot() + 
  ggplot2::geom_point(aes(x = x, y = y)) +
  ggplot2::theme_minimal() +
  ggplot2::theme(text = element_text(size = 15L))

p_2 <- p_1 +
  ggplot2::geom_hline(aes(yintercept = mean(y)), col = "blue")

ggplot2::ggsave("../figure/gbm_anim_data.png", p_1, width = 4L, height = 3.5)
ggplot2::ggsave("../figure/gbm_anim_init.png", p_2, width = 4L, height = 3.5)

# TABLES -----------------------------------------------------------------------

data <- data.table::data.table(x = (x), y = y, f_hat = mean(y))
data[, names(data) := lapply(.SD, round, digits = 2L), .SDcols = names(data)]
data.table::setkey(data, x)
data[, row_id := .I]
data.table::setcolorder(data, "row_id")
data

knitr::kable(data[c(1L:3L, nrow(data))], format = "latex")
