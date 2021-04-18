# ------------------------------------------------------------------------------
# FIG: EPSILON-INSENSITIVE LOSS
# ------------------------------------------------------------------------------

# DATA -------------------------------------------------------------------------

set.seed(123L)
x <- runif(50L, 0L, 2L)
y <- x + rnorm(length(x), sd = 0.5)
df_1 <- data.frame(x = x, y = y, diff = abs(y - x))

epsilon <- 0.8

df_2 <- data.frame(x = seq(-1.5, 1.5, length.out = 800L))
df_2$y <- ifelse(
  df_2$x < -epsilon,
  abs(df_2$x) - epsilon,
  ifelse(
    df_2$x < epsilon,
    0L,
    df_2$x - epsilon))

# PLOTS ------------------------------------------------------------------------

p_1 <- ggplot2::ggplot(df_1, aes(x, y)) + 
  geom_point() + 
  geom_abline(intercept = 0L, slope = 1L) +
  ggplot2::annotate(
    "text",
    x = 0.5,
    y = 2L,
    label = bquote(epsilon ~ "=" ~ 0.8),
    size = 10L) +
  ggplot2::geom_segment(
    x = df_1[which.max(df_1[, "diff"]), "x"],
    xend = df_1[which.max(df_1[, "diff"]), "x"],
    y = df_1[which.max(df_1[, "diff"]), "x"],
    yend = df_1[which.max(df_1[, "diff"]), "y"],
    color = "blue") +
  ggplot2::geom_point(
    mapping = aes(
      x = df_1[which.max(df_1[, "diff"]), "x"], 
      y = df_1[which.max(df_1[, "diff"]), "y"]),
    size = 2L,
    color = "blue") +
  ggplot2::annotate(
    "text",
    x = df_1[which.max(df_1[, "diff"]), "x"] + 0.75,
    y = df_1[which.max(df_1[, "diff"]), "y"] + 
      0.5 * (df_1[which.max(df_1[, "diff"]), "diff"]),
    label = bquote("|" ~ y - f(x) ~ "|" ~ ">" ~ epsilon),
    size = 7L,
    color = "blue") +
  theme_minimal() +
  theme(text = element_text(size = 20L))

p_2 <- ggplot2::qplot(df_2$x, df_2$y, geom = "line") +
  ggplot2::geom_segment(
    aes(
      x = -df_1[which.max(df_1[, "diff"]), "diff"],
      xend = -df_1[which.max(df_1[, "diff"]), "diff"],
      y = 0L,
      yend = abs(df_1[which.max(df_1[, "diff"]), "diff"]) - epsilon),
    color = "blue") +
  ggplot2::geom_point(
    aes(
      x = -df_1[which.max(df_1[, "diff"]), "diff"],
      y = abs(df_1[which.max(df_1[, "diff"]), "diff"]) - epsilon),
    size = 3L,
    color = "blue") +
  ggplot2::geom_point(
    mapping = aes(
      x = c(-0.6, -0.4, 0.3), y = rep(0L, 3L)),
    size = 3L,
    color = "blue",
    shape = 1L) +
  xlab(bquote(y - f(x))) +
  ylab(bquote(L(y, f(x)))) +
  theme_minimal() +
  theme(text = element_text(size = 20L))

p <- cowplot::plot_grid(p_1, p_2, ncol = 2L, align = "h")

ggplot2::ggsave(
  "../figure/loss_eps_insensitive.png", 
  p, 
  width = 10L, 
  height = 4L)
