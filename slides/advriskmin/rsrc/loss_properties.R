# ------------------------------------------------------------------------------
# FIG: DISTANCE-BASED, TRANSLATION-INVARIANT, SYMMETRIC LOSSES
# ------------------------------------------------------------------------------

library(ggplot2)
library(dplyr)

# DATA -------------------------------------------------------------------------

set.seed(123L)
x <- sort(runif(50L, 0L, 2L))
y <- x + rnorm(length(x), sd = 0.5)
df_1 <- data.frame(x = x, y = y, diff = y - x)

df_2 <- data.frame(x = seq(-1.5, 1.5, length.out = 800L))
df_2$y <- abs(df_2$x)
df_2$z <- (df_2$x)^2

df_3 <- data.frame(x = seq(-1L, 1L, length.out = 800L))
df_3$y <- (df_3$x)^2

# PLOT 1: DISTANCE-BASED -------------------------------------------------------

add_markers <- function(plot, index, negative = TRUE) {
  
  plot + 
    ggplot2::geom_segment(
      mapping = aes(
        x = df_1[index, "x"],
        xend = df_1[index, "x"],
        y = df_1[index, "x"],
        yend = df_1[index, "y"]),
      color = "blue",
      inherit.aes = FALSE) +
      ggplot2::geom_point(
        mapping = aes(
          x = df_1[index, "x"],
          y = df_1[index, "y"]),
        size = 2L,
        color = "blue")
  
}

add_markers_2 <- function(plot, index, negative = TRUE) {
  
  plot + 
    ggplot2::geom_segment(
      aes(
        x = df_1[index, "diff"],
        xend = df_1[index, "diff"],
        y = 0L,
        yend = abs(df_1[index, "diff"])),
      color = "blue") +
    ggplot2::geom_point(
      mapping = aes(
        x = df_1[index, "diff"],
        y = abs(df_1[index, "diff"])),
      size = 2L,
      color = "blue")
  
}

p_1 <- ggplot2::ggplot(df_1, aes(x, y)) + 
  theme_minimal() +
  geom_point() + 
  geom_abline(intercept = 0L, slope = 1L) +
  theme(axis.title = element_text(size = 15L))
p_1 <- p_1 %>% 
  add_markers(4L) %>% 
  add_markers(45L)

p_2 <- ggplot2::qplot(df_2$x, df_2$y, geom = "line") +
  theme_minimal() +
  xlab("r = y - f(x)") +
  ylab(bquote(paste(psi(r), "= |r|"))) +
  theme(axis.title = element_text(size = 15L))
p_2 <- p_2 %>%
  add_markers_2(4L) %>%
  add_markers_2(45L)

p_3 <- cowplot::plot_grid(
  p_1, 
  p_2, 
  ncol = 2L, 
  align = "h", 
  rel_widths = c(0.4, 0.6))

ggplot2::ggsave(
  "../figure/loss_dist_based.png",
  p_2,
  width = 3.5,
  height = 2.6)

# PLOT 2: TRANSLATION-INVARIANT ------------------------------------------------

p_4 <- ggplot2::qplot(df_2$x, df_2$z, geom = "line") +
  theme_minimal() +
  xlab("(y + a) - (f(x) + a))") +
  ylab(bquote(((y + a) - (f(x) + a))**2)) +  
  theme(axis.title = element_text(size = 15L))

ggplot2::ggsave(
  "../figure/loss_transl_inv.png",
  p_4,
  width = 3.5,
  height = 3.2)

# PLOT 3: SYMMETRIC ------------------------------------------------------------

p_5 <- ggplot2::qplot(df_3$x, df_3$y, geom = "line") +
  theme_minimal() +
  xlab(bquote(pi(x) - y)) +
  ylab(bquote((pi(x) - y)**2)) +  
  theme(axis.title = element_text(size = 15L))

p_6 <- ggplot2::qplot(df_3$x, df_3$y, geom = "line") +
  theme_minimal() +
  xlab(bquote(y - pi(x))) +
  ylab(bquote((y - pi(x))**2)) +  
  theme(axis.title = element_text(size = 15L))

p_7 <- cowplot::plot_grid(p_5, p_6, ncol = 2L, align = "h")

ggplot2::ggsave(
  "../figure/loss_symmetric.png",
  p_7,
  width = 5L,
  height = 3L)
