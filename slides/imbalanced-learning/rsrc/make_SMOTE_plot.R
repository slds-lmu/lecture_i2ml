library(UBL)

## data
data(iris)
dat <- iris[, c(1, 2, 5)]
dat$Species <- factor(ifelse(dat$Species == "setosa", "rare", "common"))
## checking the class distribution of this artificial data set
table(dat$Species)


## now using SMOTE with k=5 to create a more "balanced problem"
newData <- SmoteClassif(Species ~ ., dat, C.perc = list(common = 1,rare = 6),k=5)
table(newData$Species)

## now using SMOTE with k=3to create a more "balanced problem"
newData_2 <- SmoteClassif(Species ~ ., dat, C.perc = list(common = 1,rare = 6),k=1)
table(newData_2$Species)



par(mfrow = c(1, 3))
plot(dat[, 1], dat[, 2], pch = 19 + as.integer(dat[, 3]),
     main = "Original iris Data", xlab=colnames(dat)[1],ylab=colnames(dat)[2])
plot(newData[, 1], newData[, 2], pch = 19 + as.integer(newData[, 3]),
     main = "SMOTE'd iris Data (k=5)", xlab=colnames(dat)[1],ylab=colnames(dat)[2])
plot(newData_2[, 1], newData_2[, 2], pch = 19 + as.integer(newData_2[, 3]),
     main = "SMOTE'd iris Data (k=1)", xlab=colnames(dat)[1],ylab=colnames(dat)[2])


#install.packages("DMwR2")
library(DMwR2)

#if (requireNamespace("DMwR2", quietly = TRUE)) {
  
data(algae, package ="DMwR2")
clean.algae <- data.frame(algae[complete.cases(algae), ])
alg.HVDM1 <- TomekClassif(season~., clean.algae, dist = "HVDM",
                          Cl = c("winter", "spring"), rem = "both")
alg.HVDM2 <- TomekClassif(season~., clean.algae, dist = "HVDM", rem = "maj")
#}


iris_tomek <- TomekClassif(Species~., dat, dist = "Euclidean",
                          Cl = c("winter", "spring"), rem = "both")


data(ImbC)
plot(ImbC$X1, ImbC$X2, col = ImbC$Class, xlab = "X1", ylab = "X2")


i.train <- sample(1:nrow(ImbC), as.integer(0.7*nrow(ImbC)))
trainD <- ImbC[i.train,]
testD <- ImbC[-i.train,]
model <- rpart(Class~., trainD)
preds <- predict(model, testD, type = "class")
table(preds, testD$Class)
