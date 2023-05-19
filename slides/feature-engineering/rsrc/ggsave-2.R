
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


library(mlr)
library(mlrCPO)
library(ggplot2)
library(dplyr)
theme_set(theme_minimal())
#ap = adjust_path(getwd())
data = readr::read_csv("data/ames_housing_extended.csv")
data = data[, ! grepl(pattern = "energy_t", x = names(data))]

data_new = data
names(data_new) = make.names(names(data_new))
data_new = data_new %>%
  dplyr::select(-X1, -Fence, -Pool.QC, -Misc.Feature, -Alley) %>%
  select_if(is.numeric) %>%
  na.omit()

df_plot = data.frame(x = data_new$SalePrice)

gg1_dist = ggplot(df_plot, aes(x)) +
  geom_histogram(aes(y = stat(density)), color = "white", bins = 40L) +
  stat_function(fun = dnorm, col = "red",
                args = list(mean = mean(df_plot$x), sd = sd(df_plot$x))) +
  xlab("Sale Price") +
  ylab("Density")

df_plot = data.frame(x = log(data_new$SalePrice))

gg2_dist = ggplot(df_plot, aes(x)) +
  geom_histogram(aes(y = stat(density)), color = "white", bins = 40L) +
  stat_function(fun = dnorm, col = "red", args = list(mean = mean(df_plot$x), sd = sd(df_plot$x))) +
  xlab("Log Sale Price") +
  ylab("Density")

task = removeConstantFeatures(makeRegrTask(id = "Ames Housing", data = data_new, target = "SalePrice"))
lrn = makeLearner("regr.lm")
lrn$id = "No Trafo"
lrn_loglm = cpoLogTrafoRegr() %>>% makeLearner("regr.lm")
lrn_loglm$id = "Log Trafo"
mod = train(learner = "regr.lm", task = task)
mod_log = train(learner = lrn_loglm, task = task)
target = data_new$SalePrice

pred_mod = predict(mod, task)$data$response
pred_mod_log = predict(mod_log, task)$data$response
df_plot = data.frame(target, pred_mod, pred_mod_log)

gg1_pred = ggplot(data = df_plot, aes(x = target, y = pred_mod)) +
  geom_point(alpha = 0.2) +
  geom_abline(intercept = 0, slope = 1, color = "red") +
  xlab("Sale Price") +
  ylab("Predicted Sale Price")

gg2_pred = ggplot(data = df_plot, aes(x = target, y = pred_mod_log)) +
  geom_point(alpha = 0.2) +
  geom_abline(intercept = 0, slope = 1, color = "red") +
  xlab("Sale Price") +
  ylab("exp(Predicted Log Sale Price)")

gridExtra::grid.arrange(gg1_dist, gg1_pred, ncol = 2)

##########################################################

gridExtra::grid.arrange(gg2_dist, gg2_pred, ncol = 2)
#########################################################

set.seed(31415)
rdesc = makeResampleInstance(desc = cv10, task = task)
bmr = benchmark(learners = list(lrn, lrn_loglm), tasks = task, resamplings = rdesc, measures = mae)
plotBMRBoxplots(bmr, pretty.names = FALSE)

###################################################

lrn_ranger = makeLearner("regr.ranger", num.trees = 200L, mtry = 3L)
lrn_ranger$id = "RF No Trafo"
lrn_logranger = cpoLogTrafoRegr() %>>% lrn_ranger
lrn_logranger$id = "RF Log Trafo"
bmr = benchmark(learners = list(lrn, lrn_loglm, lrn_ranger, lrn_logranger), tasks = task, resamplings = rdesc, measures = mae)
plotBMRBoxplots(bmr, pretty.names = FALSE)

#######################################################

data = readr::read_csv("data/ames_housing_extended.csv")
data = data[, ! grepl(pattern = "energy_t", x = names(data))]

data_new = data
names(data_new) = make.names(names(data_new))
task = data_new %>%
  dplyr::select(-X1, -Fence, -Pool.QC, -Misc.Feature, -Alley) %>%
  select_if(is.numeric) %>%
  na.omit() %>%
  makeRegrTask(id = "Ames Housing", data = ., target = "SalePrice") %>%
  removeConstantFeatures()

lrn_kknn_no_scale = makeLearner("regr.kknn", scale = FALSE)
lrn_kknn_no_scale$id = "No Scaling"
lrn_kknn_scale = mlrCPO::cpoScale() %>>% makeLearner("regr.kknn", scale = FALSE)
lrn_kknn_scale$id = "Normalize Features"
lrn_kknn_boxcox = makePreprocWrapperCaret(lrn_kknn_no_scale, ppc.BoxCox = TRUE)
lrn_kknn_boxcox$id = "Box-Cox Trafo"

set.seed(31415)
bmr = benchmark(learners = list(lrn_kknn_no_scale, lrn_kknn_scale, lrn_kknn_boxcox),
                tasks = task, resamplings = cv10, measures = mae)

plotBMRBoxplots(bmr, pretty.names = FALSE)

###################################################

library(mlr)

data = read.csv("data/ames_housing_extended.csv")

data %>%
  dplyr::select(SalePrice, Central.Air, Bldg.Type) %>%
  slice(5:9) %>%
  knitr::kable(format = 'latex') %>%
  kableExtra::kable_styling(latex_options = 'HOLD_position', font_size = 7)

##################################################

data = read.csv("data/ames_housing_extended.csv")
data %>%
  dplyr::select(SalePrice, Central.Air, Bldg.Type) %>%
  slice(5:9) %>%
  createDummyFeatures(target = "SalePrice") %>%
  knitr::kable(format = 'latex') %>%
  kableExtra::kable_styling(latex_options = 'HOLD_position', font_size = 4)

###############################################

library(dplyr)
data = read.csv("data/ames_housing_extended.csv")

data %>%
  filter(!is.na(Foundation)) %>%
  dplyr::select(Foundation) %>%
  group_by(Foundation) %>%
  tally(name = "nk") %>%
  t() %>%
  knitr::kable(format = 'latex') %>%
  kableExtra::kable_styling(latex_options = 'HOLD_position', font_size = 7)
####################################################

data %>%
  mutate(house.id  = row_number()) %>%
  dplyr::select(house.id, SalePrice, Foundation) %>%
  filter(Foundation == "Wood") %>%
  t() %>%
  knitr::kable(format = 'latex') %>%
  kableExtra::kable_styling(latex_options = 'HOLD_position', font_size = 7)
###################################################

data %>%
  dplyr::select(SalePrice, Foundation) %>%
  group_by(Foundation) %>%
  dplyr::summarize(`Foundation(enc)` = mean(SalePrice, na.rm = TRUE)) %>%
  t() %>%
  knitr::kable(format = 'latex') %>%
  kableExtra::kable_styling(latex_options = 'HOLD_position', font_size = 7)

#################################################
















