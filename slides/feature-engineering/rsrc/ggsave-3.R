
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
library(tidyverse)
library(stringi)

data = read_csv("data/ames_housing_extended.csv")
set.seed(2)

data %>%
  dplyr::select(matches("energy"), X1) %>%
  sample_n(8) %>%
  gather("Minute", "Energy_Consumption", -X1) %>%
  mutate(Minute = as.numeric(stri_replace(Minute, "", fixed = "energy_t"))) %>%
  ggplot(aes(x = Minute, y = Energy_Consumption, group = X1)) +
  geom_line() +
  facet_grid(X1~.) +
  theme_minimal() +
  ylab("Energy Consumption") +
  xlab("Minute of Day")

########################################################

library(tidyverse)

data = read_csv("data/ames_housing_extended.csv")

data %>%
  mutate(house.id = X1) %>%
  dplyr::select(house.id, matches("energy")) %>%
  gather(name, value, -house.id) %>%
  group_by(house.id) %>%
  dplyr::summarize(mean.energy = mean(value, na.rm = TRUE),
                   var.energy = var(value, na.rm = TRUE),
                   max.energy = max(value, na.rm = TRUE)) %>%
  sample_n(5) %>%
  mutate("..." = rep("...", times = 5)) %>%
  knitr::kable(format = 'latex') %>%
  kableExtra::kable_styling(latex_options = 'HOLD_position', font_size = 7)

##############################################

library(tidyverse)
library(stringi)
library(mlr)

data = read_csv("data/ames_housing_extended.csv")

task = data %>%
  mutate(lot_area = `Lot Area`) %>%
  dplyr::select(SalePrice, lot_area , matches("energy")) %>%
  na.omit %>%
  makeFunctionalData(fd.features = list("Energy" = 3:ncol(.))) %>%
  makeRegrTask(" ", data = ., target = "SalePrice")
feat.methods = list("Energy" = extractFDAWavelets(filter = "haar"))
lrns = list(
  makeLearner(id = "Boosted Linear Model", "regr.glmboost"),
  makeExtractFDAFeatsWrapper(makeLearner("regr.glmboost"), feat.methods = feat.methods),
  makeLearner(id = "Boosted Functional Linear Model", "regr.FDboost")
)

lrns[[2]]$id = "Boosted Linear Model with Wavelets"
if (FALSE) {
  set.seed(12)
  b1 = benchmark(lrns, task, cv10, measure = mae, keep.pred = FALSE, models = FALSE)
  saveRDS(b1, file = "benchmark_cache/ames.rds")
} else {
  b1 = readRDS("benchmark_cache/ames.rds")
}

plotBMRBoxplots(b1, pretty.names = FALSE) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 20, hjust = 1)) +
  ylab("Mean Absolute Error") +
  xlab("") + ggtitle("House Price Prediction")

############################################

