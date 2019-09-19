library(tidyverse)
library(mlr)
library(mlrCPO)
library(parallelMap)

parallelStartSocket(7)

data = read.csv("data/ames_housing_extended.csv")

task = data %>%
  select(SalePrice, MS.Zoning, Street, Lot.Shape, Land.Contour, Bldg.Type) %>%
  makeRegrTask(id = "None", target = "SalePrice") %>>% cpoFixFactors()
  
task1 = createDummyFeatures(task, method = "1-of-n")
task1$task.desc$id = "One-Hot"

task2 = createDummyFeatures(task, method = "reference")
task2$task.desc$id = "Dummy"

lrns =  list(
  makeLearner(id = "Linear Regression", "regr.lm"),
  makeLearner(id = "Random Forest", "regr.ranger"))
  
set.seed(1)
rin = makeResampleInstance(cv10, task1)

res = benchmark(lrns, list(task1, task2, task), rin, mae)

pl = as.data.frame(res) %>%
  filter(task.id != "None" | learner.id != "Linear Regression") %>%
  ggplot(aes(y = mae, x = task.id)) + 
  geom_boxplot() + 
  facet_wrap(~learner.id) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 20, hjust = 1)) +
  ylab("Mean Absolute Error") +
  xlab("") + ggtitle("Ames House Price Prediction")

ggsave("figure_man/ames-encoding.png", width = 6, height = 5)