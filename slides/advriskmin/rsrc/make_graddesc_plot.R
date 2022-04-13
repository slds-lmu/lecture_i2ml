
#1 Define gradient for huber loss
gradHuberConstant = function(theta, y, delta = 0.5) {
  if (abs(y - theta) < delta) 
    - (y - theta)
  else
    - delta * sign(y - theta)
} 

#2 Define huber loss function
HuberLossConstant = function(theta, y, delta) {
  comp = sapply(y, function(y) {
    if (abs(y - theta) > delta)
      1 / 2 * (y - theta)^2
    else 
      delta * abs(y - theta) - 1 / 2 * delta^2
  })
  mean(comp)
}

#3 Define gradient descent with huber loss
gradient.descent = function(df, n.iter = 3, theta.start = - 1, lambda = 2, theta.opt = 4) {
  
  plist = list()
  theta = theta.start
  counter = 1
  
  p = ggplot(data = df, aes(x = x, y = y)) + geom_point()
  p = p + geom_abline(intercept = theta.opt, slope = 0, colour = "green")
  
  while (counter < n.iter) {
    theta = theta - lambda * mean(sapply(df$y, function(y) gradHuberConstant(theta, y)))
    theta
    
    pout = p + geom_abline(intercept = theta, slope = 0)
    pout = pout + ggtitle(paste("Iteration", counter))
    plist[[counter]] = pout 
    counter = counter + 1
  }
  return(plist)
}


n = 50

x = runif(n, -2, 2)
df = data.frame(x = x, y = rnorm(n, mean = 0, sd = 0.5))

# manually add an outlier
df = rbind(df, data.frame(x = -1.8, y = 2))


delta = 0.5
y = df$y

theta.true = optimize(function(theta) HuberLossConstant(theta, y = y, delta = delta), interval = c(-2, 2))$minimum

plist = gradient.descent(df, n.iter = 4, theta.start = 2, theta.opt = theta.true)

ggsave(plist[[1]], filename = "graddesc_iter1.png", path = "../figure")
ggsave(plist[[2]], filename = "graddesc_iter2.png", path = "../figure")
ggsave(plist[[3]], filename = "graddesc_iter3.png", path = "../figure")
