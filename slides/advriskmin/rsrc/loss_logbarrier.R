# ------------------------------------------------------------------------------
# FIG: LOG-BARRIER LOSS
# ------------------------------------------------------------------------------

library(ggplot2)

# DATA -------------------------------------------------------------------------

source("loss_functions.R")
source("constant_model.R")

x <- seq(-3L, 3L, length.out = 800L)
y <- log_barrier(x)

set.seed(3L)
x_2 <- runif(50, -2, 2)
df <- data.frame(x = x_2, y = rnorm(50, mean = 0, sd = 0.8))

# PLOTS ------------------------------------------------------------------------

p_1 <- ggplot2::qplot(
  x = x, 
  y = y, 
  geom = "line",
  xlab = expression(y - f(x)),
  ylab = expression(L(y, f(x)))) +
  ylim(c(0L, 15L))

p_1 <- p_1 + theme_light()
p_1 <- p_1 + theme(text = element_text(size = 20L))

ggplot2::ggsave(
  "../figure/loss_logbarrier_1.png", 
  p_1, 
  width = 10L, 
  height = 4L)

p_2 <- plotConstantModel(df, loss_type = c("L1", "L2", "log_barrier"), a = 1) + 
  scale_color_viridis_d(
    end = 0.9, 
    name = "Loss", 
    labels = c("L1", "L2", "log-barrier")) + 
  ggtitle(bquote("Not feasible for " ~ epsilon ~ "=" ~ 1)) + 
  theme_minimal() +
  theme(text = element_text(size = 20L))

p_3 <- plotConstantModel(df, loss_type = c("L1", "L2", "log_barrier"), a = 2) + 
  scale_color_viridis_d(end = 0.9) + 
  ggtitle(bquote("Feasible for " ~ epsilon ~ "=" ~ 2)) + 
  theme_minimal() +
  theme(text = element_text(size = 20L))

p_4 <- ggpubr::ggarrange(
  p_2, 
  p_3, 
  nrow = 1L, 
  common.legend = TRUE, 
  legend = "bottom")

ggplot2::ggsave(
  "../figure/loss_logbarrier_2.png", 
  p_4, 
  width = 10L, 
  height = 4L)
