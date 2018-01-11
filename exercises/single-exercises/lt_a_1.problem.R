gen3class = function() {
  library(MASS)
  set.seed(1L)
  Sigma =  matrix(c(1,0,0,1), nrow = 2, ncol = 2)
  d1 = mvrnorm(n = 50, c(3,3), Sigma, tol = 1e-6, empirical = FALSE, EISPACK = FALSE)
  d1 = data.frame(d1)
  d2 = mvrnorm(n = 50, c(3,0), Sigma, tol = 1e-6, empirical = FALSE, EISPACK = FALSE)
  d2 = data.frame(d2)
  d3 = mvrnorm(n = 50, c(0,0), Sigma, tol = 1e-6, empirical = FALSE, EISPACK = FALSE)
  d3 = data.frame(d3)
  
  library(ggplot2)
  plot2 <- ggplot(NULL, aes(X1, X2)) + 
    geom_point(data = d1, color = "red") +
    geom_point(data = d2) +
    geom_point(data = d3, color = "blue")  
  plot2
  
  d1$Species = 1
  d2$Species = 2
  d3$Species = 3
  df = rbind(d1,d2,d3)
  return(df)
}