


source("rsrc/ridge_polynomial_reg.R")

set.seed(314259)
f = function (x) {
  return (5 + 2 * x + 10 * x^2 - 2 * x^3)
}

x = runif(40, -2, 5)
y = f(x) + rnorm(length(x), 0, 10)

x.true = seq(-2, 5, length.out = 400)
y.true = f(x.true)
df = data.frame(x = x.true, y = y.true)

lambda.vec = 0

plotRidge(x, y, lambda.vec, baseTrafo, degree = 10) +
  geom_line(data = df, aes(x = x, y = y), color = "red", size = 1) +
  xlab("x") + ylab("f(x)") + 
  #ggtitle("Predicting Using Linear Regression") +
  theme(plot.title = element_text(size = 15)) #smaller title size

#################################################################

source("rsrc/ridge_polynomial_reg.R")

f = function (x) {
  return (5 + 2 * x + 10 * x^2 - 2 * x^3)
}

set.seed(314259)
x = runif(40, -2, 5)
y = f(x) + rnorm(length(x), 0, 10)

x.true = seq(-2, 5, length.out = 400)
y.true = f(x.true)
df = data.frame(x = x.true, y = y.true)

lambda.vec = c(0, 10, 100)


plotRidge(x, y, lambda.vec, baseTrafo, degree = 10) +
  geom_line(data = df, aes(x = x, y = y), color = "red", size = 1) +
  xlab("x") + ylab("f(x)") + 
  #  ggtitle("Predicting Using Ridge Regression") +
  labs(color=expression(lambda)) +
  theme(plot.title = element_text(size = 15)) #smaller title size

#################################################################

library(xtable)
betas = getPolyData(x, y, lambda.vec, baseTrafo, degree = 10)$betas

betas = cbind(as.numeric(rownames(betas)), betas)

colnames(betas) <- c("$\\lambda$" , sapply(1:(ncol(betas)-1), 
                                           function(i) return (paste0("$\\beta_{",
                                                                      as.character(i-1),
                                                                      "}$"))))

print(xtable(signif(betas, 2), digits = 2, align = "rr|lllllllllll"),
      row.names = FALSE, sanitize.colnames.function = function(x) x, include.rownames = FALSE,
      hline.after = 0, latex.environments = "tiny")
