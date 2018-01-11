# There still is a bug somewhere here, 
# if you find it write me and I'll buy you a beer or something

trainADA = function(formula, data, iters, ...) {
  
  require(rpart)
  
  n = nrow(data)
  #initialize weights
  w = rep(1/n, times = n)
  
  models = list()
  alpha = numeric(iters)
  
  #main loop
  for(i in seq_len(iters)) {
    
    #this is really stupid, but rpart will only look in the parent frame (which is the global.env) 
    #for w and will not find it otherwise...
    assign("w", get("w"), parent.frame())
    
    models[[i]] = rpart(formula = formula, data = data, weights = w, 
                        control = rpart.control(maxdepth = 1), ...)
    
    pred = predict(models[[i]], data, type = "vector")
    
    missc = pred != models[[i]]$y
    
    err = sum(w * missc)/sum(w)
    
    alpha[i] = 0.5 * log((1 - err) / err)
    
    w = w * exp(alpha[i] * missc)
    
    w = w / sum(w)
  }
  
  structure(list(alpha = alpha, models = models, iters = iters),
            class = "myADA")
}



predictADA = function(model, newdata) {
  
  pred = vapply(model$models, predict, newdata = newdata, type = "vector", 
                FUN.VALUE = numeric(nrow(newdata)))
  
  #recode classes to -1, 1
  pred = ifelse(pred == 1, -1, 1)
  
  pred = pred * model$alpha
  
  pred = sign(rowSums(pred))
  
  #recode classes to 1, 2
  ifelse(pred == -1, 1, 2)

}



data(Sonar, package = "mlbench")
 

x = trainADA(Class ~ ., data = Sonar, iters = 5L)

p = predictADA(x, Sonar)

mean(p == as.numeric(Sonar$Class))



