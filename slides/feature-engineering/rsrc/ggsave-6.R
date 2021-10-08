

library(mlr)
library(mlrMBO)
library(ggplot2)
library(gridExtra)
library(reshape2)
library(kernlab)
library(mvtnorm)
library(gptk)
library(smoof)

library(dplyr)
data = read.csv("data/ames_housing_extended.csv")
data %>%
  filter(!is.na(Neighborhood)) %>%
  group_by(Neighborhood) %>%
  tally() %>%
  sample_n(6) %>%
  t() %>%
  knitr::kable(format = 'latex') %>%
  kableExtra::kable_styling(latex_options = 'HOLD_position', font_size = 7)

############################################################################