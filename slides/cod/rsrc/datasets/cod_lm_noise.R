library(reshape)
library(mlr)

d <- getTaskData(bh.task)                                                                                                   
n <- nrow(d)

# creating 500 noise variables
p <- 500
x <- data.frame(replicate(p, rnorm(n)))                                                                                   
d <- cbind(d, x)                         

d_true <- d
d_true[,15:ncol(d_true)] = 0
d_noise <- d
d_noise[,1:13] = 0
d_noise$chas = as.factor(d_noise$chas)

set.seed(1234)
ks <- 4
res <- matrix(nrow=100, ncol = ks)
for(k in 1:ks){
  for(i in 1:10){
    idx <- sample(1:10, n, replace = TRUE)
    for(j in 1:10){
      res_lm <- lm(medv ~ ., d[idx != j,1:(14 + k*100)])
      intercept <- res_lm$coefficients[1]
      p_true  <- abs(predict(res_lm, d_true[idx == j,1:(14 + k*100)]) - intercept)
      p_noise <- abs(predict(res_lm, d_noise[idx == j,1:(14 + k*100)]) - intercept)
      res[(i-1)*10 + j, k] <- mean(p_noise / (p_true + p_noise))
    }
  }
}

colnames(res) <- as.character(1:ks*100)
noise_prop <- melt(res)
noise_prop$X2 <- as.factor(noise_prop$X2)

saveRDS(object = noise_prop, "datasets/cod_lm_noise.rds")
