n.trees = 20000
shrinks = c(0.1, 0.01, 0.001)
inters = seq(1, 16, 3)
pred.n.trees = seq(1, n.trees, length.out = 30)

getModel = function(train, n.trees, inter, shrinkage) {
  gbm(spam ~ ., data = train, distribution = "bernoulli",
    train.fraction = 1, verbose = FALSE, 
    n.trees = n.trees, interaction.depth = inter,
    shrinkage = shrinkage
  )
}

getPred = function(model, test, n.trees) {
  pred = predict(model, newdata = test, 
    n.trees = n.trees, type = "response")
  pred = as.numeric(pred > 0.5)
}

getErr = function(model, test, n.trees) {
  pred = getPred(model, test, n.trees)
  mean(pred != test$spam)
}
