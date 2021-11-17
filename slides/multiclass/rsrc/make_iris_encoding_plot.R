
library(kableExtra)
library(magick)
library(dplyr)
library(knitr)

data(iris)
set.seed(123)
species <- iris$Species
species <- data.frame(Species = sample(species)[10:15])

c <- cbind(original = species, mlr::createDummyFeatures(species))
c %>%
  knitr::kable(format = 'latex') %>%
  kableExtra::kable_styling(latex_options = "HOLD_position") %>%
  save_kable(file = "../figure/iris_encoding.png", latex_header_includes = c("\\\\usepackage{fontspec}"))
