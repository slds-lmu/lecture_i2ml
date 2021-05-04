################################################################################
# EXAMPLE: POSTERIOR PROBABILITIES FOR SVM VS TRUE LOG-ODDS
################################################################################

# Lisa Wimmer

# IDEA -------------------------------------------------------------------------

# Demonstrate how fitting posterior probabilities for SVM via Platt scaling
# may fail to give a good approximation of the true probabilities, by 
# contrasting the results to the true log-odds and posterior log-odds of 
# approaches that directly output posterior probabilities.

# PREREQ -----------------------------------------------------------------------

library(dplyr)
library(ggplot2)
library(mlr3)
library(mlr3learners)
library(ranger)
library(DiceKriging)
library(calibrateBinary)
library(kernlab)

# CREATE TASK ------------------------------------------------------------------

# Draw 1000 data points from 2 overlapping conditional distributions:
# p(x | y = 0) ~ Unif(0, 1), p(x | y = 1) ~ Unif(1.5, 1.5), 
# where p(y = 1) = pi.
# Two sets (train, test) are created since Platt scaling requires the estimation
# of coefficients a, b on a separate dataset to avoid overfitting.

set.seed(20200705)

n = 1000L
y = rep(0, n)
pi = 0.5
y[1:(pi * length(y))] = 1

df_c = data.frame(y = as.factor(y)) %>% 
  arrange(y) %>% 
  mutate(x = ifelse(y == 0,
                    runif(0.5 * n, 0, 1), 
                    runif(0.5 * n, 0.5, 1.5)))

df_r = data.frame(y) %>% 
  arrange(y) %>% 
  mutate(x = ifelse(y == 0,
                    runif(0.5 * n, 0, 1), 
                    runif(0.5 * n, 0.5, 1.5)))

task_c = TaskClassif$new(id = "sim_c", backend = df_c, target = "y")
task_r = TaskRegr$new(id = "sim_r", backend = df_r, target = "y")

train_set = sample(task_c$nrow, 0.6 * task_c$nrow)
test_set = setdiff(seq_len(task_c$nrow), train_set)

# FIT SVM ----------------------------------------------------------------------

# Fit SVM with Gaussian kernel of bandwidth 0.1. All methods are used with
# that same bandwidth to ensure comparability.
# Option "prob" performs internal Platt scaling to obtain posterior probs.

gamma = 0.1

learner_svm = lrn("classif.svm", id = "svm", kernel = "radial", gamma = gamma)
learner_svm$predict_type = "prob"
learner_svm$train(task_c, row_ids = train_set)
pred_svm = learner_svm$predict(task_c, row_ids = test_set)

# Get log-odds.

svm_logodds = log(pred_svm$prob[,"1"] / pred_svm$prob[,"0"])
plot(df_c$x[test_set], svm_logodds)

# FIT RF -----------------------------------------------------------------------

# Fit random forest.

learner_rf = lrn("classif.ranger", id = "rf", mtry = 1, min.node.size = 0.3 * n)
learner_rf$predict_type = "prob"
learner_rf$train(task_c, row_ids = train_set)
pred_rf = learner_rf$predict(task_c, row_ids = test_set)

# Get log-odds.

rf_logodds = log(pred_rf$prob[,"1"] / pred_rf$prob[,"0"])
plot(df_c$x[test_set], rf_logodds)

# FIT GP -----------------------------------------------------------------------

# Fit Gaussian process with Gaussian kernel of bandwidth 0.1.
# Kernel implementation in DiceKriging: k(x,y) = exp(-1/2 * (h / theta)^2)
# --> Align w/ gamma from svm: theta = sqrt(1 / (2 * gamma))

theta = sqrt(1 / (2 * gamma))

learner_gp = lrn("regr.km", id = "gp", covtype = "gauss", coef.cov = theta,
                 nugget.stability = 1e-8)
learner_gp$train(task_r, row_ids = train_set)
pred_gp = learner_gp$predict(task_r, row_ids = test_set)

# Get log-odds.

gp_logodds = log(pred_gp$response / (1 - pred_gp$response))
plot(df_c$x[test_set], gp_logodds)

# FIT KLR ----------------------------------------------------------------------

# Fit kernelized logistic regression with Gaussian kernel of bandwidth 0.1.

klr_model = KLR(X = df_r$x[train_set], y = df_r$y[train_set], 
                xnew = df_r$x[test_set], kernel = "exponential", 
                power = 1.8, rho = 1 / 0.1)

klr_logodds = log(klr_model / (1 - klr_model))
plot(df_c$x[test_set], klr_logodds)

# FIT RVM ----------------------------------------------------------------------

# Fit relevance vector machine with Gaussian kernel of bandwidth 0.1.

rvm_model = rvm(y ~ x, data = df_r[train_set,], kernel = "rbfdot",
                kpar = list(sigma = 0.1), fit = TRUE)
rvm_pred = predict(rvm_model, df_c$x[test_set], type = "probabilities")

# Get log-odds

rvm_logodds = log(rvm_pred / (1 - rvm_pred))

# PLOT RESULTS -----------------------------------------------------------------

res_df = data.frame(cbind(df_c[test_set,], svm_logodds, 
                          rf_logodds,
                          gp_logodds,
                          # rvm_logodds, 
                          klr_logodds
                          ))

p = ggplot(res_df)
p = p + labs(y = "Log-odds")
p = p + geom_line(aes(x = x, y = svm_logodds, col = "SVM"), size = 1.2)
p = p + geom_line(aes(x = x, y = klr_logodds, col = "KLR"), size = 1.2)
# p = p + geom_line(aes(x = x, y = rvm_logodds, col = "RVM"), size = 1.2)
p = p + geom_line(aes(x = x, y = rf_logodds, col = "RF"), size = 1.2)
p = p + geom_line(aes(x = x, y = gp_logodds, col = "GP"), size = 1.2)
p = p + geom_segment(aes(x = 0.5, xend = 0.5, y = -10, yend = 0,
                         col = "Optimal log-odds"),
                     linetype = "longdash", size = 1.2)
p = p + geom_segment(aes(x = 1, xend = 1, y = 0, yend = 10,
                         col = "Optimal log-odds"),
                     linetype = "longdash", size = 1.2)
p = p + geom_segment(aes(x = 0.5, xend = 1, y = 0, yend = 0,
                         col = "Optimal log-odds"),
                     linetype = "longdash", size = 1.2)
p = p + geom_hline(yintercept = 0, linetype = "dotted")
p = p + scale_y_continuous(limits = c(-10, 10))
p = p + scale_color_manual("Model", values = c("#067B7F", "#66CC00", "#000099",
                                               "red", "orange", "grey"))
p
