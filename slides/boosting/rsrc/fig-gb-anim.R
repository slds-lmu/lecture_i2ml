# ------------------------------------------------------------------------------
# FIG: TREE-BASED GRADIENT BOOSTING ANIMATION
# ------------------------------------------------------------------------------

# Purpose: visualize tree-based gb with running animation

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
set.seed(122L)
y <- sin(x) + rnorm(length(x), mean = 0L, sd = sqrt(0.01))

# FUNCTIONS --------------------------------------------------------------------

# Define function that conducts animation for increasing m

anim <- function(X, 
                 y, 
                 n_baselearners, 
                 minsplit = 3L, 
                 demo = FALSE, 
                 data_all_iterations = TRUE) {
  
  # Initialize values
  
  n <- length(y)
  x_1 <- X[, 1L]
  
  intercept <- mean(y)
  
  models <- vector("list", n_baselearners)
  betas <- numeric(n_baselearners)
  if(data_all_iterations) traces <- vector("list", n_baselearners)
  
  # Define predictive function
  
  predict_additive <- function(m) {
    
    if (m == 0L) return(rep(intercept, n))
    
    p <- sapply(seq_len(m), function(i) predict(models[[i]], newdata = X))
    p %*% betas[seq_len(m)] + intercept
    
  }
  
  # Define loss function
  
  compute_loss <- function(y_hat) (y - y_hat)
  
  # Define line search (actually unnecessary and stupid for L2 loss...)
  
  conduct_line_search <- function(y_hat, r_hat) {
    
    objective <- function(beta) crossprod(y - (y_hat + beta * r_hat))
    opt <- optimize(objective, interval = c(0L, 10000L))
    
    if (demo) print(opt)
    
    opt$minimum
    
  }

  # Iterate
  
  for (m in seq_len(n_baselearners)) {
    
    if (demo) messagef("Iteration: %i", m)
    
    # Compute pseudo-residuals
    
    y_hat <- predict_additive(m - 1L)
    r <- compute_loss(y_hat)
    
    # Fit model to pseudo-residuals
    
    r_data <- data.frame(X, r = r)
    
    model <- rpart::rpart(
      r ~ ., 
      data = r_data, 
      maxdepth = 1L, 
      minsplit = minsplit, 
      minbucket = minsplit, 
      xval = 0L)
    
    models[[m]] <- model
    r_hat <- predict(model, newdata = X)
    
    trace <- data.frame(
      x_1 = x_1, y = y, y_hat = y_hat, r = r, r_hat = r_hat)
    
    if (demo) print(trace)
    if (data_all_iterations) traces[[m]] <- trace
    
    beta <- conduct_line_search(y_hat, r_hat)
    betas[[m]] <- beta
    
    if (demo) plot_model(j - 1L, y_hat, r, r_hat, beta)
    if (demo) pause()
    
  }
  
  output <- list(models = models, betas = betas, intercept = intercept)
  if (data_all_iterations) {
    output <- append(output, list(traces))
    names(output)[4L] <- "traces"}
  
  output

}

# Define function that plots data + model and residuals + b^m side by side

plot_model <- function(m, x, y_hat, r, r_hat, beta) {
  
  d <- c(0L, (x[-1L] - x[-length(x)]) / 2L, 0L)
  
  x_grid <- rbind(
    x - d[seq_len(length(x))], 
    x + d[seq_len(length(x)) + 1L])
  
  y_hat_grid <- rep(y_hat, each = 2L)
  r_hat_grid <- rep(r_hat, each = 2L)
  
  p_1 <- ggplot2::ggplot() +
    ggplot2::geom_point(aes(x = x, y = y)) +
    ggplot2::geom_step(aes(x = x_grid, y = y_hat_grid), col = "blue") +
    ggplot2::xlab("x") +
    ggplot2::ggtitle(
      label = NULL , 
      subtitle = sprintf("m = %i: data and model ", m)) +
    ggplot2::theme_minimal() +
    ggplot2::theme(text = ggplot2::element_text(16L))
  
  p_2 <- ggplot2::ggplot() +
    ggplot2::geom_point(aes(x = x, y = r)) +
    ggplot2::geom_step(aes(x = x_grid, y = r_hat_grid), col = "blue") +
    ggplot2::ggtitle(
      label = NULL , 
      subtitle = expression(r^{"[m]"} ~ "and" ~ beta * b^{"[m]"})) +
    ggplot2::ylim(c(-1L, 1L)) +
    ggplot2::theme_minimal() +
    ggplot2::theme(text = ggplot2::element_text(16L))
  
  gridExtra::grid.arrange(p_1, p_2, nrow = 1L)
  
}

# PLOTS ------------------------------------------------------------------------

# Plot data & initial constant model

p_1 <- ggplot2::ggplot() + 
  ggplot2::geom_point(aes(x = x, y = y)) +
  ggplot2::theme_minimal() +
  ggplot2::theme(text = element_text(size = 12L))

p_2 <- p_1 +
  ggplot2::geom_hline(aes(yintercept = mean(y)), col = "blue")

ggplot2::ggsave("../figure/gbm_anim_data.png", p_1, width = 4L, height = 3.4)
ggplot2::ggsave("../figure/gbm_anim_init.png", p_2, width = 4L, height = 3.4)

# Run animation

z <- anim(X = X, y = y, n_baselearners = 100L)

for (iteration in c(seq_len(6L), 51L)) {
  
  options(warnings = -1L)
  
  assign(
    sprintf("p_%i", iteration), 
    plot_model(
      iteration - 1L,
      x = x,
      y_hat = z$traces[[iteration]]$y_hat, 
      r = z$traces[[iteration]]$r,
      r_hat = z$traces[[iteration]]$r_hat,
      beta = z$betas[[iteration]]))
  
  ggplot2::ggsave(
    sprintf("../figure/gbm_anim_%02i.png", iteration), 
    get(sprintf("p_%i", iteration)), 
    height = 4L, 
    width = 6.2L)
  
}

# TABLES -----------------------------------------------------------------------

data <- data.table::data.table(
  x = x, 
  y = y, 
  f_hat = mean(y),
  r = z$traces[[1]]$r,
  b_hat = z$traces[[1]]$r_hat)
data[, names(data) := lapply(.SD, round, digits = 2L), .SDcols = names(data)]
data.table::setkey(data, x)
data[, row_id := .I]
data.table::setcolorder(data, "row_id")
data

knitr::kable(data[c(1L:3L, nrow(data)), .(x, y, f_hat)], format = "latex")
knitr::kable(data[c(1L:3L, nrow(data))], format = "latex")
