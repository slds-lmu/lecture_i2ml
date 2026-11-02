library(quantreg)
library(ggplot2)
library(gridExtra)

set.seed(31415)

x = 1:5
y = 2.0 + 0.5 * x + rnorm(length(x), 0, 1.5)
data = data.frame(x = x, y = y)

sol = rq(y ~ x, weights = 1/y, tau=0.5)

fun1 = function(x) 2*(x-3)^2 + x - 2
fun2 = function(x) log(fun1(x))
fun3 = function(x) 3.5*abs(x-3) + x

plot1 = ggplot() + geom_point(data=data.frame(x=x, y=y), aes(x=x, y=y)) +
  geom_function(fun = fun1) +
  geom_function(fun = fun2) +
  geom_function(fun = fun3) +
  labs(title= expression(hat(f)~" with "~rho["Spearman"]==1))
plot1

sapply(c(fun1, fun2, fun3), function(f) cor(y, f(x), method="spearman"))

fun4 = function(x) sin(4*x) + 3
fun5 = function(x) exp(sin(4*x)) + 3
  
plot2 = ggplot() + geom_point(data=data.frame(x=x, y=y), aes(x=x, y=y)) +
  geom_function(fun = fun4) +
  geom_function(fun = fun5) +
  labs(title= expression(hat(f)~" with "~rho["Spearman"]==0))  
plot2

sapply(c(fun4, fun5), function(f) cor(y, f(x), method="spearman"))

grid.arrange(plot1, plot2, ncol=2)

ggsave(grid.arrange(plot1, plot2, ncol=2), 
       filename="../figure/eval_spearman.pdf", width = 7, height = 2.5)
     
