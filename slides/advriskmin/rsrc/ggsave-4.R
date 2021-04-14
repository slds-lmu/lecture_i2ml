
library(qrmix)
library(mlr)
library(quantreg)
library(reshape2)



#0-1-loss
x = seq(-2, 2, by = 0.01); y = as.numeric(x < 0)
qplot(x, y, geom = "line", xlab = expression(r), ylab = expression(L(yf(x))))

########################################
#brier-score
x = seq(0, 1, by = 0.01)
df = data.frame(x = x, y = 1, pi = (1 - x)^2)
df = rbind(df, data.frame(x = x, y = 0, pi = x^2))
df$y = as.factor(df$y)

p = ggplot(data = df, aes(x = x, y = pi, color = y)) + geom_line() + xlab(expression(pi(x))) + ylab(expression(L(y, pi(x)))) + labs(title = "Brier Score")
p

########################################
#bernoulli
x = seq(-2, 2, by = 0.01); y = log(1 + exp(-x))
qplot(x, y, geom = "line", xlab = expression(yf(x)), ylab = expression(L(yf(x))))

########################################

bernoulli = function(y, pix) {
  -y * log(pix) - (1 - y) * log(1 - pix)
}

x = seq(0, 1, by = 0.001)
df = data.frame(x = x, y = 1, pi = bernoulli(1, x))
df = rbind(df, data.frame(x = x, y = 0, pi = bernoulli(0, x)))
df$y = as.factor(df$y)

p = ggplot(data = df, aes(x = x, y = pi, color = y)) + geom_line() + xlab(expression(pi(x))) + ylab(expression(L(y, pi(x))))
p