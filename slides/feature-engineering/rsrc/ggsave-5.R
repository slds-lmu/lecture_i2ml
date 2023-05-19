

library(mlr)
library(mlrMBO)
library(ggplot2)
library(gridExtra)
library(reshape2)
library(kernlab)
library(mvtnorm)
library(gptk)
library(smoof)

set.seed(31415)
x = runif(n = 100, min = 0, max = 10)
y = 2 * 0.2 * x + rnorm(100, 0, 1)

df_outlier_feat = df_outlier_target = df_outlier = data.frame(x = x, y = y)

df_outlier$outlier = "Wthout outliers"
gg1 = ggplot(df_outlier_feat, aes(x = x , y = y)) +
  geom_point() +
  xlab("Feature") +
  ylab("Target")

df_outlier_target$y[2] = 500

gg2 = ggplot(df_outlier_target, aes(x = x, y = y)) +
  geom_point() +
  xlab("Feature") +
  ylab("Target")

gridExtra::grid.arrange(gg1, ncol = 2)

########################################################

gridExtra::grid.arrange(gg1, gg2, ncol = 2)

########################################################

df_outlier_target$y[2] = 500

df_outlier_target$outlier = "With outliers"
gg1 = ggplot(rbind(df_outlier, df_outlier_target), aes(x = x , y = y, color = outlier)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  xlab("Feature") +
  ylab("Target") +
  ggtitle("Outlier in the Target") +
  labs(color = "")

gg2 = ggplot() +
  geom_point(data = df_outlier, aes(x = x, y = y)) +
  geom_smooth(data = rbind(df_outlier, df_outlier_target), aes(x = x , y = y, color = outlier), method = "lm", se = FALSE) +
  xlab("Feature") +
  ylab("Target") +
  ggtitle("") +
  labs(color = "") +
  coord_cartesian(ylim = c(-2, 8))

#########################################################
gridExtra::grid.arrange(gg1, gg2, ncol = 2)

########################################################

df_outlier_feat$x[2] = -999

df_outlier_feat$outlier = "With outliers"
gg1 = ggplot(rbind(df_outlier, df_outlier_feat), aes(x = x , y = y, color = outlier)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  xlab("Feature") +
  ylab("Target") +
  ggtitle("Outlier in the Feature") +
  labs(color = "")

gg2 = ggplot() +
  geom_point(data = df_outlier, aes(x = x, y = y)) +
  geom_smooth(data = rbind(df_outlier, df_outlier_feat), aes(x = x , y = y, color = outlier), method = "lm", se = FALSE) +
  xlab("Feature") +
  ylab("Target") +
  ggtitle("") +
  labs(color = "") +
  coord_cartesian(xlim=c(0, 10))

gridExtra::grid.arrange(gg1, gg2, ncol = 2)

#######################################################

source("figure_code/plot_loss.R")

set.seed(31415)

x = 1:5
y = 2 + 0.5 * x + rnorm(length(x), 0, 1.5)
data = data.frame(x = x, y = y)
model = lm(y ~ x)

plotModQuadraticLoss(data = data, model = model, pt_idx = c(1,4))

##########################################################

plotModAbsoluteLoss(data, model = model, pt_idx = c(1,4))
##########################################################

df_outlier_target$y[2] = 500

df_outlier_target$method = c("rlm", "lm")
gg1 = ggplot(data = df_outlier_target, aes(x = x, y = y)) +
  geom_point() +
  geom_smooth(aes(color = "Quadratic"), method = "lm", se = FALSE) +
  geom_smooth(aes(color = "Absolute"), method = "rlm", se = FALSE) +
  xlab("Feature") +
  ylab("Target") +
  ggtitle("Outlier in the Target") +
  labs(color = "Used Loss") +
  theme(legend.position = "none")

gg2 = ggplot(data = df_outlier_target, aes(x = x, y = y)) +
  geom_point() +
  geom_smooth(aes(color = "Quadratic"), method = "lm", se = FALSE) +
  geom_smooth(aes(color = "Absolute"), method = "rlm", se = FALSE) +
  xlab("Feature") +
  ylab("Target") +
  ggtitle("") +
  labs(color = "Used Loss") +
  coord_cartesian(ylim = c(-2, 8))

gridExtra::grid.arrange(gg1, gg2, ncol = 2)
#######################################################

df_outlier_feat$x[2] = -999

df_outlier_feat$method = c("rlm", "lm")
gg1 = ggplot(data = df_outlier_feat, aes(x = x, y = y)) +
  geom_point() +
  geom_smooth(aes(color = "Quadratic"), method = "lm", se = FALSE) +
  geom_smooth(aes(color = "Absolute"), method = "rlm", se = FALSE) +
  xlab("Feature") +
  ylab("Target") +
  ggtitle("Outlier in the Feature") +
  labs(color = "Used Loss") +
  theme(legend.position = "none")

gg2 = ggplot(data = df_outlier_feat, aes(x = x, y = y)) +
  geom_point() +
  geom_smooth(aes(color = "Quadratic"), method = "lm", se = FALSE) +
  geom_smooth(aes(color = "Absolute"), method = "rlm", se = FALSE) +
  xlab("Feature") +
  ylab("Target") +
  ggtitle("") +
  labs(color = "Used Loss") +
  coord_cartesian(xlim = c(0, 10))

gridExtra::grid.arrange(gg1, gg2, ncol = 2)

##################################################

set.seed(31415)
x = runif(n = 100, min = 0, max = 10)
y = ifelse(x < 6, rnorm(n = sum(x < 6), mean = 3, sd = 0.5), rnorm(n = sum(x >= 6), mean = 6, sd = 0.5))

x[1] = -0.5

df_outlier_target = data.frame(x = x, y = y)
df_outlier_target$y[which.min(x)] = 15

gg1 = ggplot(data = df_outlier_target, aes(x = x, y = y)) + geom_point()
mod = rpart::rpart(y ~ x, control = list(minsplit = 1, minbucket = 1))
gg2 = ggplot(data = df_outlier_target, aes(x = x, y = y)) + geom_point() + geom_vline(xintercept = mod$split[,"index"], col = "red", linetype = "dashed")

gridExtra::grid.arrange(gg1, ncol = 2)

####################################################

gridExtra::grid.arrange(gg1, ncol = 2)
rpart.plot::rpart.plot(mod)

gridExtra::grid.arrange(gg1, gg2, ncol = 2)
rpart.plot::rpart.plot(mod)
###################################################

data = readr::read_csv("data/ames_housing_extended.csv")
data = data[, ! grepl(pattern = "energy_t", x = names(data))]

impute_var = "Lot Frontage"
x = na.omit(data[[impute_var]])
z = (x - mean(x)) / sd(x)
x_removed = x[abs(z) < 3]

df_plot = data.frame(value = c(x, x_removed), technique = rep(c("None", "Z-Score"), times = c(length(x), length(x_removed))))

ggplot(data = df_plot, aes(x = value, fill = technique)) +
  geom_histogram(position = position_dodge(), bins = 40) +
  # geom_rug() +
  geom_vline(xintercept = c(- 3 * sd(x) + mean(x), 3 * sd(x) + mean(x)),
             color = "red", linetype = "dashed") +
  xlab(impute_var) +
  ylab("Density") +
  labs(fill = "Outlier removal technique")

###################################################

set.seed(31415)
x1 = c(rnorm(200, mean = c(2, 6), sd = 1), 0.5, 1.7, 2,   3,   2, 2.3, 5.5, 5.6, 5.5, 7.5, 8, 7.6, 9, 9.7, 9.6)
x2 = c(rnorm(200, mean = c(2, 6), sd = 1), 8.4,   8, 9, 7.6, 8.4, 7.2,   2, 3.1, 1.4,   3, 2, 0.2, 9,   8,   3)

cluster = c(rep(c("A", "B"), times = 100L), rep("Noise", times = 15L))

df_plot = data.frame(x1, x2, cluster)
ggplot(data = df_plot, aes(x = x1, y = x2, color = cluster)) + geom_point()







