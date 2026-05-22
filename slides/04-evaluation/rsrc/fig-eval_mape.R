library(quantreg)
library(ggplot2)
library(gridExtra)

set.seed(31415)

x = 1:5
y = 2.0 + 0.5 * x + rnorm(length(x), 0, 1.5)
data = data.frame(x = x, y = y)

sol = rq(y ~ x, weights = 1/y, tau=0.5)

plot1 = ggplot() + geom_point(data=data.frame(x=x, y=y), aes(x=x, y=y)) +
  geom_abline(intercept = sol$coefficients[1], slope = sol$coefficients[2])


sol_fun = function(x) x*sol$coefficients[2] + sol$coefficients[1]
inv_fun = function(x) 1/(x*sol$coefficients[2] + sol$coefficients[1])

lx = rep(x, each=3)
ly = rep(1/y, each=3) 
lx[1:length(lx) %% 3 == 0] = NA
ly[1:length(ly) %% 3 == 0] = NA
ly[(1:length(ly) +1) %% 3  == 0] = inv_fun(x)

res = seq(-5, 5, length.out = 101) 
mape_res = function(res, y) abs(res/y)
mape = function(y, yhat) mape_res(y - yhat, y)
loss = c(mape_res(res , y[1]), mape_res(res , y[3]))

df = data.frame(res = rep(res, 2), loss = loss, y = rep(c(
  as.character(round(y[1], 2)), as.character(round(y[3], 2))), each=length(res)))

y_hat = sol_fun(x[c(1,3)])
l_res = c(mape(y[c(1,3)], y_hat))

df_err = data.frame(x = rep(y[c(1, 3)] - y_hat, each=3))
df_err$y = rep(l_res, each=3)

df_err[(1:nrow(df_err) + 1) %% 3 == 0, "y"] = 0
df_err[(1:nrow(df_err) ) %% 3 == 0, ] = NA

plot2 = ggplot() + 
  geom_line(data=df, aes(x = res, y = loss, linetype = y)) +
  xlab(expression("Residuals"== y - hat(y))) +
  ylab(expression(L(y,  hat(y)))) +
  geom_point(data=data.frame(x = y[c(1, 3)] - y_hat, y = l_res),
             aes(x=x, y=y)) + 
  geom_path(data=df_err, aes(x = x, y=y), colour = "red")

ggsave(grid.arrange(plot1, plot2, ncol=2), 
       filename="../figure/eval_mape.pdf", width = 7, height = 2.5)
     
