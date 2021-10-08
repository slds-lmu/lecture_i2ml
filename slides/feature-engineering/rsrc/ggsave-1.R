

library(mlr)
library(mlrMBO)
library(ggplot2)
library(gridExtra)
library(reshape2)
library(kernlab)
library(mvtnorm)
library(gptk)
library(smoof)


library(ggplot2)
d = data.frame(
  Method = factor(1:4, labels = c("Linear Regression", "Gradient Boosting", "Linear Regression w. Feat. Eng.", "Gradient Boosting w. Feat. Eng.")),
  Error = c(25.5, 10, 11, 9.8)
)
ggplot(data = d) + geom_bar(aes(x = Method, y = Error), stat = "identity") + theme_minimal() + theme(axis.text.x = element_text(angle = 15, hjust = 1))

############################################################################