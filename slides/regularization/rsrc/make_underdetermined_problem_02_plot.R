# ------------------------------------------------------------------------------
# FIG: UNDER-DETERMINED PROBLEM 02
# ------------------------------------------------------------------------------

library(mlr)
library(mlbench)
library(ggplot2)
library(BBmisc)
library(reshape)
library(viridis)

mat_X <- as.matrix(X[,c(1,2)])
cor_X <- as.matrix(X[1:6,c(1,2)])
incor_X <-  as.matrix(X[7:8,c(1,2)])

theta_dir <- c(1/sqrt(2), -1/sqrt(2))

emp_risk_cor <- function(theta_len){
  sum(log(1 + exp(- abs(theta_len * cor_X %*% theta_dir))))
}

emp_risk_incor <- function(theta_len){
  sum(log(1 + exp(abs(theta_len * incor_X %*% theta_dir))))
}

theta_lens <- seq(1,10,length.out = 100)
emp_data <- data.frame(t_len = theta_lens,
                       cor = sapply(theta_lens, emp_risk_cor),
                       incor = sapply(theta_lens, emp_risk_incor))

emp_data$emp <- emp_data$cor + emp_data$incor
min_t_len <- emp_data$t_len[which.min(emp_data$emp)]

plot_df <- melt(emp_data, id.vars="t_len")
theta_pl <- ggplot(plot_df, aes(t_len, value)) +
  geom_line(aes(colour=variable)) +
  geom_vline(xintercept = min_t_len, linetype="dashed") +
  xlab(expression('Length of '~theta)) +
  ylab("") +
  labs(colour="") +
  annotate("label", x=min_t_len, y=6, label="bar(theta)", parse=TRUE) +
  scale_color_viridis(end = 0.9, discrete = TRUE, labels = expression(f[cor], f[incor], R[emp]))

loss_score <- function(score){
  log(1 + exp(-score))
}

scores <- seq(-5.5, 5.5, length.out = 100)

loss_1 <- loss_score(scores)
loss_m1 <- loss_score(-scores)

plot_df_1 <- data.frame(loss = loss_1, scores = scores)
plot_df_m1 <- data.frame(loss = loss_m1, scores = scores)

X_m1 <- X[X$type == "-1", c(1,2)]
X_1 <- X[X$type == "1", c(1,2)]

theta_scale <- 8

X_m1$class <- "cor"
X_m1$class[4] <- "incor"
X_m1 <- rbind(X_m1, X_m1)
X_m1$score <- as.matrix(X_m1[,c(1,2)]) %*% theta_dir
X_m1$score[5:8] <- X_m1$score[5:8] * theta_scale
X_m1$theta <- "1"
X_m1$theta[5:8] <- as.character(theta_scale)

X_1$class <- "cor"
X_1$class[4] <- "incor"
X_1 <- rbind(X_1, X_1)
X_1$score <- as.matrix(X_1[,c(1,2)]) %*% theta_dir
X_1$score[5:8] <- X_1$score[5:8] * theta_scale
X_1$theta <- "1"
X_1$theta[5:8] <- as.character(theta_scale)

loss_pl <- ggplot() +
  geom_line(data=plot_df_1, aes(x=scores, y=loss)) +
  geom_line(data=plot_df_m1, aes(x=scores, y=loss)) +
  geom_point(data = X_1, aes(score, loss_score(score), colour=class,
                             shape=theta), size=2.1,
             alpha=0.7) +
  geom_point(data = X_m1, aes(score, loss_score(-score), colour=class,
                              shape=theta), size=2.1,
             alpha=0.7) +
  labs(colour="classified", shape=expression(bar(theta))) +
  theme(legend.spacing.y = unit(0, 'cm')) +
  ylab("log loss") +
  guides(colour = guide_legend(order = 1),
         shape = guide_legend(order = 2)) +
  annotate("label", x=-3.5, y=4, label="1") +
  annotate("label", x=3.5, y=4, label="-1") +
  scale_color_viridis(end = 0.9, discrete = TRUE, labels = c("correctly", "incorrectly"))

p <- grid.arrange(theta_pl, loss_pl, ncol=2)

ggsave("../figure/underdetermined_problem_02.png", plot = p, width = 6, height = 2)