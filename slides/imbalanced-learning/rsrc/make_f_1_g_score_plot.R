# PREREQ -----------------------------------------------------------------------

library(data.table)
library(ggplot2)

# DATA -------------------------------------------------------------------------

tpr <- ppv <- seq(0L, 1L, by = 0.2)


# Gscore  -------------------------------------------------------------------------

compute_gscore <- function(ppv, tpr) {
  f_1 <- sqrt(ppv * tpr)
  ifelse(is.na(f_1), 0, f_1)}

scores <- data.table::data.table(expand.grid(tpr, ppv))
data.table::setnames(scores, c("tpr", "ppv"))
scores[, f_1 := compute_gscore(ppv, tpr)]

# PLOT -------------------------------------------------------------------------

p <- ggplot2::ggplot(scores, aes(x = ppv, y = tpr, fill = f_1)) +
  geom_tile() +
  geom_text(aes(label = round(f_1, 2L)), color = "white") +
  scale_fill_gradient(
    low = "darkseagreen4",
    high = "black") +
  scale_x_continuous(breaks = ppv) +
  scale_y_continuous(breaks = tpr) +
  xlab(expression(paste(italic(rho[PPV])))) +
  ylab(expression(paste(italic(rho[TPR])))) +
  theme(text = element_text(size = 20L), legend.position = "none")

ggsave("../figure/g_score_plot.pdf", p, height = 4L, width = 4L)


# DATA -------------------------------------------------------------------------

tpr <- ppv <- seq(0L, 1L, by = 0.2)


# F1 score  -------------------------------------------------------------------------

compute_f_1 <- function(ppv, tpr) {
  f_1 <- 2*(ppv * tpr)/(ppv+tpr)
  ifelse(is.na(f_1), 0, f_1)}

scores <- data.table::data.table(expand.grid(tpr, ppv))
data.table::setnames(scores, c("tpr", "ppv"))
scores[, f_1 := compute_f_1(ppv, tpr)]

# PLOT -------------------------------------------------------------------------

p <- ggplot2::ggplot(scores, aes(x = ppv, y = tpr, fill = f_1)) +
  geom_tile() +
  geom_text(aes(label = round(f_1, 2L)), color = "white") +
  scale_fill_gradient(
    low = "darkseagreen4",
    high = "black") +
  scale_x_continuous(breaks = ppv) +
  scale_y_continuous(breaks = tpr) +
  xlab(expression(paste(italic(rho[PPV])))) +
  ylab(expression(paste(italic(rho[TPR])))) +
  theme(text = element_text(size = 20L), legend.position = "none")

ggsave("../figure/f1_score_plot.pdf", p, height = 4L, width = 4L)



# DATA -------------------------------------------------------------------------

tpr <- ppv <- seq(0L, 1L, by = 0.2)


# Balanced accuracy  -------------------------------------------------------------------------


tpr <- tnr <- seq(0L, 1L, by = 0.2)

compute_gscore <- function(tnr, tpr) {
  f_1 <- (tnr + tpr)/2
  ifelse(is.na(f_1), 0, f_1)}

scores <- data.table::data.table(expand.grid(tpr, tnr))
data.table::setnames(scores, c("tpr", "tnr"))
scores[, f_1 := compute_gscore(tnr, tpr)]

# PLOT -------------------------------------------------------------------------

p <- ggplot2::ggplot(scores, aes(x = tnr, y = tpr, fill = f_1)) +
  geom_tile() +
  geom_text(aes(label = round(f_1, 2L)), color = "white") +
  scale_fill_gradient(
    low = "darkseagreen4",
    high = "black") +
  scale_x_continuous(breaks = tnr) +
  scale_y_continuous(breaks = tpr) +
  xlab(expression(paste(italic(rho[TNR])))) +
  ylab(expression(paste(italic(rho[TPR])))) +
  theme(text = element_text(size = 20L), legend.position = "none")

ggsave("../figure/bac_plot.pdf", p, height = 4L, width = 4L)


