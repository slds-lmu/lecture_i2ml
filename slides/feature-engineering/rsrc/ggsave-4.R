
library(knitr)
library(mlr)
library(mlrMBO)
library(ggplot2)
library(gridExtra)
library(reshape2)
library(kernlab)
library(mvtnorm)
library(gptk)
library(smoof)

n_cols = 200L
# p = 0.02
# simDF = function (n_feats, n_cols, p) {
#   cols = list()
#   for (i in seq_len(n_cols)) {
#     cols[[i]] = rnorm(n_feats)
#     cols[[i]][sample(n_feats, size = n_feats * p, replace = FALSE)] = NA
#   }
#   df = do.call(cbind, cols)
#   return (df)
# }
# sim = 50L
# ratios = numeric(sim)
# for (i in seq_len(sim)) {
#   ratios[i] = sum(! complete.cases(simDF(n_feats, n_cols, p))) / n_feats
# }
# boxplot(ratios)
# mean(ratios)
# 1 - pbinom(q = 0, size = n_cols, p = p)
df_probs = lapply(c(0.01, 0.02, 0.05, 0.1), FUN = function (p) {
  n_feats = seq_len(n_cols)
  na_prob = 1 - pbinom(q = 0, size = n_feats, p = p)
  return (data.frame(n_feats = n_feats, na_prob = na_prob, prob = p))
})

df_plots = do.call(rbind, df_probs)
df_plots$prob = paste0(df_plots$prob * 100, " %")

ggplot(data = df_plots, aes(x = n_feats, y = na_prob, color = prob)) +
  geom_line() +
  xlab("Number of Features") +
  ylab("Percentage of\nNon-Usable Observations") +
  labs(color = "Percentage of missing\nobservations per\nfeature")


################################################################

library(naniar)
data = read_csv("data/ames_housing_extended.csv") %>% dplyr::select(-X1, -matches("energy"))
vis_miss(data) + theme(axis.text.x = element_text(angle = 90, size = 10))

###############################################################

impute_var = "Lot Frontage"
x = data[[impute_var]]
y_mean = y_med = x
y_mean[is.na(y_mean)] = mean(x, na.rm = TRUE)
y_med[is.na(y_med)] = quantile(x, 0.5, na.rm = TRUE)

df_plot = data.frame(value = c(x, y_mean, y_med), technique = rep(c("No imputation", "Imputing with mean", "Imputing with median"), each = length(x)))

ggplot(data = df_plot, aes(x = value, fill = technique)) +
  geom_histogram(position = position_dodge(), bins = 40) +
  # geom_rug(aes(color = technique), alpha = 0.1) +
  xlab(impute_var) +
  ylab("Density") +
  labs(fill = "")

#############################################################

# ap = adjust_path(getwd())
data = readr::read_csv("data/ames_housing_extended.csv")
data = data[, ! grepl(pattern = "energy_t", x = names(data))]

load("figure_data/plot_impute.rds")
df_plot = df_plot[! df_plot$technique %in% c("CART", "Random Forest"),]

ggplot(data = df_plot, aes(technique, perf)) +
  geom_boxplot() +
  xlab("Imputation Technique") +
  ylab("MAE")

##########################################################

set.seed(618)
x = runif(n = 100, min = 0, max = 10)
y = 2 + 2 * x * sin(x) + 2 * x + rnorm(100, mean = 0, sd = 2)

mod = lm(y ~ x)
x_new = c(2, 5, 8, 8.5, 9)
pred_new = predict(mod, newdata = data.frame(x = x_new))

df_plot = data.frame(x = x, y = y)
df_new_points = data.frame(x = x_new, y = pred_new)

ggplot() +
  geom_point(data = df_plot, aes(x = x, y  = y)) +
  geom_smooth(data = df_plot, aes(x = x, y = y), method = "lm", se = FALSE,
              color = "red") +
  geom_point(data = df_new_points, aes(x = x, y = y), color = "red", size = 3) +
  xlab("Feature used for imputation") +
  ylab("Feature to impute")

