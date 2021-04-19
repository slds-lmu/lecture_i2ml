# ------------------------------------------------------------------------------
# FIG: QUANTILE LOSS
# ------------------------------------------------------------------------------

# DATA -------------------------------------------------------------------------

set.seed(123L)
x <- runif(50L, 0L, 2L)
y <- x + rnorm(length(x), sd = 0.5)
df_1 <- data.frame(x = x, y = y, diff = y - x)
df_1$plot_neg <- ifelse(df_1$diff < -0.8, 1L, 0L)
df_1$plot_pos <- ifelse(df_1$diff > 0.8, 1L, 0L)

alpha <- 0.7

df_2 <- data.frame(x = seq(-1.5, 1.5, length.out = 800L))
df_2$y <- ifelse(
  df_2$x < 0L,
  (1 - alpha) * abs(df_2$x),
  alpha * df_2$x)

# PLOTS ------------------------------------------------------------------------

add_markers <- function(plot, index, negative = TRUE) {
  
  plot + 
    ggplot2::geom_segment(
      aes(
        x = df_1[index, "x"],
        xend = df_1[index, "x"],
        y = df_1[index, "x"],
        yend = df_1[index, "y"]),
      color = "blue",
      linetype = ifelse(negative, "solid", "longdash")) +
      ggplot2::geom_point(
        mapping = aes(
          x = df_1[index, "x"],
          y = df_1[index, "y"]),
        size = 2L,
        color = "blue")
  
}

p_1 <- ggplot2::ggplot(df_1, aes(x, y)) + 
  geom_point() + 
  geom_abline(intercept = 0L, slope = 1L) +
  ggplot2::annotate(
    "text",
    x = 1.5,
    y = 0L,
    label = bquote(alpha ~ "=" ~ 0.7),
    size = 10L) 

p_1 <- add_markers(p_1, which(df_1$plot_neg > 0L)[1L])
p_1 <- add_markers(p_1, which(df_1$plot_neg > 0L)[2L])
p_1 <- add_markers(p_1, which(df_1$plot_pos > 0L)[1L], negative = FALSE)
p_1 <- add_markers(p_1, which(df_1$plot_pos > 0L)[2L], negative = FALSE)
p_1 <- p_1 + 
  theme_minimal() +
  theme(text = element_text(size = 20L))

add_markers_2 <- function(plot, index, negative = TRUE) {
  
  plot + 
    ggplot2::geom_segment(
      aes(
        x = df_1[index, "diff"],
        xend = df_1[index, "diff"],
        y = 0L,
        yend = ifelse(
          df_1[index, "diff"] < 0L,
          (1 - alpha) * abs(df_1[index, "diff"]),
          alpha * df_1[index, "diff"])),
      color = "blue",
      linetype = ifelse(negative, "solid", "longdash")) +
    ggplot2::geom_point(
      mapping = aes(
        x = df_1[index, "diff"],
        y = ifelse(
          df_1[index, "diff"] < 0L,
          (1 - alpha) * abs(df_1[index, "diff"]),
          alpha * df_1[index, "diff"])),
      size = 2L,
      color = "blue")
  
}

p_2 <- ggplot2::qplot(df_2$x, df_2$y, geom = "line")

p_2 <- add_markers_2(p_2, which(df_1$plot_neg > 0L)[1L])
p_2 <- add_markers_2(p_2, which(df_1$plot_neg > 0L)[2L])
p_2 <- add_markers_2(p_2, which(df_1$plot_pos > 0L)[1L], negative = FALSE)
p_2 <- add_markers_2(p_2, which(df_1$plot_pos > 0L)[2L], negative = FALSE)

p_2 <- p_2 +
  xlab(bquote(y - f(x))) +
  ylab(bquote(L(y, f(x)))) +
  theme_minimal() +
  theme(text = element_text(size = 20L))

# p <- gridExtra::grid.arrange(p_1, p_2, ncol = 2L)
p <- cowplot::plot_grid(p_1, p_2, ncol = 2L, align = "h")

ggplot2::ggsave(
  "../figure/loss_quantile.png",
  p,
  width = 10L,
  height = 4L)
