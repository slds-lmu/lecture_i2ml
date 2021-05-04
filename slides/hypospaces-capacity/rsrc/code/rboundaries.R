library(caret)
library("rpart")

data(iris)

# Two class case
#x <- iris[1:100, c("Sepal.Length", "Sepal.Width", "Species")]
#x$Species <- factor(x$Species)

#seed of 100 and frac of 0.3 is good for KNN
# 1,11,12,60 are good with seed 10 and frac 0.6

set.seed(10)
size <- floor(0.25 * nrow(iris))
indices <- sample(seq_len(nrow(iris)), size = size)

# Three classes
x <- iris[1:150, c("Sepal.Length", "Sepal.Width", "Species")]

train <- x[indices, ]
test <- x[-indices, ]

# Easier to separate
#x <- iris[1:150, c("Petal.Length", "Petal.Width", "Species")]

head(x)

# Code adapted from https://github.com/mhahsler/Introduction_to_Data_Mining_R_Examples/blob/master/chap5_decisionboundary.R
# Available under Creative Commons Attribution 4.0 International License. Credit : Michael Hahsler.

# k = 1, 7 and 20
model <- knn3(Species ~ ., data=train, k = 1)
decisionplot(model, train, class = "Species", main = "kNN (k = 7)")

preds.train = predict(model, train, type = "class")
preds.test = predict(model, test, type = "class")

calc_class_err = function(actual, predicted) {
  mean(actual != predicted)
}

err.train <- calc_class_err(train$Species, preds.train)
err.test <- calc_class_err(test$Species, preds.test)

# params = c(1,3,6,9,12,15,18,22,25)
# trn.err = 1:9
# tst.err = 1:9
# 
# iter = 1
# for(i in params) {
#   
#   model <- knn3(Species ~ ., data=train, k = i)
#   
#   preds.train = predict(model, train, type = "class")
#   preds.test = predict(model, test, type = "class")
#   
#   trn.err[iter] <- calc_class_err(train$Species, preds.train)
#   tst.err[iter] <- calc_class_err(test$Species, preds.test)
#   
#   iter = iter + 1
#   cat(iter)
# }
# 
# plot(tst.err)
# plot(trn.err)
# 
# length(preds.train)


#

######################################################################################################
####################################### Decision Trees ###############################################

# 1,11,12,60 is good with seed 10
model <- rpart(Species ~ ., data=train,
                control = rpart.control(cp = 0.001, minsplit = 2))
decisionplot(model, train, class = "Species", main = "Decision Tree (minsplit = 2) ")


# Compute training error
preds.train <- predict(model, type = "class")
cmat.train <- table(train$Species, preds.train )
err.train <- 1 - sum(diag(cmat.train))/sum(cmat.train)


# Compute test error
preds.test = predict(model,test,type="class")
cmat.test <- table(test$Species,preds.test)
err.test <- 1 - sum(diag(cmat.test))/sum(cmat.test)





# trn.err = 1:30
# tst.err = 1:30
# 
# for (i in params){
#   model <- rpart(Species ~ ., data=train,
#                  control = rpart.control(cp = 0, minsplit = i))
#   
#   # Compute training error
#   preds.train <- predict(model, type = "class")
#   cmat.train <- table(train$Species, preds.train )
#   err.train <- 1 - sum(diag(cmat.train))/sum(cmat.train)
#   
#   
#   # Compute test error
#   preds.test = predict(model,test,type="class")
#   cmat.test <- table(test$Species,preds.test)
#   err.test <- 1 - sum(diag(cmat.test))/sum(cmat.test)
#   
#   
#   
#   trn.err[i] = err.train
#   tst.err[i] = err.test
#   
# }

params = rev(1:30)

# plot(params, rev(trn.err), type="o", col="blue", pch="o", lty=1, ylim=c(0.6,1) )
# points(params, rev(tst.err), col="red", pch="*")
# lines(params, rev(tst.err), col="red",lty=2)

plot(params, trn.err, type="o", col="blue", pch="o", lty=1, ylim=c(0.6,1) )

points(params, tst.err, col="red", pch="*")
lines(params, tst.err, col="red",lty=2)

plot(tst.err)

decisionplot <- function(model, data, class = NULL, predict_type = "class",
                         resolution = 100, showgrid = TRUE, ...) {
  
  if(!is.null(class)) cl <- data[,class] else cl <- 1
  data <- data[,1:2]
  k <- length(unique(cl))
  
  plot(data, col = as.integer(cl)+1L, cex.lab = 1.5, cex.main = 1.5, xlab = "Sepal Length", ylab = "Sepal Width",lwd = 3, pch = as.integer(cl)+1L, ...)
  
  # make grid
  r <- sapply(data, range, na.rm = TRUE)
  xs <- seq(r[1,1], r[2,1], length.out = resolution)
  ys <- seq(r[1,2], r[2,2], length.out = resolution)
  g <- cbind(rep(xs, each=resolution), rep(ys, time = resolution))
  colnames(g) <- colnames(r)
  g <- as.data.frame(g)
  
  ### guess how to get class labels from predict
  ### (unfortunately not very consistent between models)
  p <- predict(model, g, type = predict_type)
  if(is.list(p)) p <- p$class
  p <- as.factor(p)
  
  if(showgrid) points(g, col = as.integer(p)+1L, pch = ".")
  
  z <- matrix(as.integer(p), nrow = resolution, byrow = TRUE)
  contour(xs, ys, z, add = TRUE, drawlabels = FALSE,
          lwd = 2, cex=2, levels = (1:(k-1))+.5)
  
  invisible(z)
}
