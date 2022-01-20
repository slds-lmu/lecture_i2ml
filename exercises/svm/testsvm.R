library(e1071) 

X <- matrix(c(0,0,0.5,0.5,0,1,3,0,0,3,3,3), byrow=TRUE, ncol=2) 
y = c(-1,1,1,-1,-1,-1)*(-1) 

plot(x = dat$X1, y = dat$X2, pch = ifelse(dat$y == 1, "-", "+"), col = "black", 
     xlab = "x1", ylab = "x2") 

for(cost in c(0.1,10,1000)){ 
  
  dat = data.frame(X, y = as.factor(y)) 
  #dat = dat[2:6,] 
  
  svmfit = svm(y ~ ., data = dat, kernel = "linear", cost = cost, scale = FALSE) 
  #  print(svmfit) 
  plot(svmfit, dat)  
  
  beta = drop(t(svmfit$coefs)%*%X[svmfit$index,]) 
  beta0 = -svmfit$rho   
  cat("C = ", cost, "\n")
  cat("theta = ", round(beta,3), "\n")
  cat("theta0 = ", round(beta0,3), "\n")
} 
