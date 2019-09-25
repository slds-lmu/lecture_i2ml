library(ggplot2)
library(glmnet)
library(mlbench)
library(dplyr)


# Boston Housing Data
data(BostonHousing)

data <- BostonHousing

data <- data%>%mutate_if(is.numeric,scale)
train_data <- data[sample(1:nrow(data), 50,
                          replace=FALSE),]
  
fit = glmnet(x = as.matrix(train_data[,1:13]), y = as.matrix(train_data[,14]), alpha = 1)
plot(fit, xvar = "lambda")


cv.fit = cv.glmnet(x = data.matrix(train_data[,1:13]), y = data.matrix(train_data[,14]), alpha = 1)
plot(cv.fit)
