# ------------------------------------------------------------------------------
# FIG: ERROR DISTRIBUTION OVER CV FOLDS ----------------------------------------
# ------------------------------------------------------------------------------

library(ggplot2)
library(gridExtra)
library(mlr3)
library(mlr3learners)

# DATA -------------------------------------------------------------------------

task <- tsk("spam")
learners <- list(
  nb = lrn("classif.svm"), 
  lda = lrn("classif.lda"))
resampling <- rsmp("cv", folds = 20L)

set.seed(123L)
results <- lapply(learners, function(i) resample(task, i, resampling))

errors <- lapply(results, function(i) i$score()[, .(learner_id, classif.ce)])
errors <- do.call(rbind, errors)

dens_lda <- density(errors[learner_id == "classif.lda"]$classif.ce)
dens_svm <- density(errors[learner_id == "classif.svm"]$classif.ce)
sd_lda <- sd(errors[learner_id == "classif.lda"]$classif.ce)
sd_svm <- sd(errors[learner_id == "classif.svm"]$classif.ce)

# PLOT -------------------------------------------------------------------------

# plot error densities

p <- ggplot(errors, aes(x = classif.ce, fill = learner_id)) +
  geom_density(col = NA, alpha = 0.6) +
  xlim(0L, 0.2) +
  scale_fill_manual(
    "learner", labels = c("LDA", "SVM"), values = c("gray60", "gray20")) +
  # theme_classic() +
  labs(x = "MCE", y = "density over 20-CV")

# annotate lines for mean and sd 

p <- p +
  geom_segment(
    x = dens_lda$x[which.max(dens_lda$y)],
    xend = dens_lda$x[which.max(dens_lda$y)],
    y = 0L,
    yend = max(density(errors[learner_id == "classif.lda"]$classif.ce)$y)) +
  geom_segment(
    x = dens_svm$x[which.max(dens_svm$y)],
    xend = dens_svm$x[which.max(dens_svm$y)],
    y = 0L,
    yend = max(density(errors[learner_id == "classif.svm"]$classif.ce)$y)) +
  geom_segment(
    x = dens_lda$x[which.max(dens_lda$y)] - sd_lda,
    xend = dens_lda$x[which.max(dens_lda$y)] + sd_lda,
    y = 1,
    yend = 1) +
  geom_segment(
    x = dens_svm$x[which.max(dens_svm$y)] - sd_svm,
    xend = dens_svm$x[which.max(dens_svm$y)] + sd_svm,
    y = 3,
    yend = 3) +
  annotate(
    "text", 
    x = 0.03, 
    y = 5, 
    label = list(bquote(sigma[SVM] ~ "=" ~ .(round(sd_svm, 3)))),
    parse = TRUE) +
  annotate(
    "text", 
    x = 0.14, 
    y = 3, 
    label = list(bquote(sigma[LDA] ~ "=" ~ .(round(sd_lda, 3)))),
    parse = TRUE)

# make bg transparent

p <- p +
  theme(
    panel.background = element_rect(fill = "transparent"),
    plot.background = element_rect(fill = "transparent"), 
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(), 
    legend.background = element_rect(fill = "transparent"))

ggsave(
  "../figure/plot_ttest_error_dens.png",
  p,
  height = 2.5,
  width = 5L)

# TEST -------------------------------------------------------------------------

p_val <- t.test(
  errors[learner_id == "classif.lda"]$classif.ce, 
  errors[learner_id == "classif.svm"]$classif.ce)$p.value
