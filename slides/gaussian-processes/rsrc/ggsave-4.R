
library(knitr)
library(mlr)
library(mlrMBO)
library(ggplot2)
library(gridExtra)
library(reshape2)
library(kernlab)
library(mvtnorm)
library(gptk)
library(smoof)


x1 = - 0.5
x2 = 0.5
f.x1 = 1

k = exp(-0.5 * (x2 - x1)^2)

K = matrix(c(1, k, k, 1), nrow = 2)

data.grid = expand.grid(X1 = seq(-4, 4, length.out = 200), X2 = seq(-4, 4, length.out = 200))
data.grid = cbind(data.grid, prob = mvtnorm::dmvnorm(data.grid, mean = c(0, 0), sigma = K))

x = seq(-4, 4, by = 0.01)
y = dnorm(x = x, mean = 0, sd = 1)
p1 = ggplot(data = data.frame(x = x, y = y)) + geom_line(aes(x = x, y = y), lty = 2) + theme_bw()
p1 = p1 + coord_fixed(xlim = c(-4, 4), ylim = c(0, 1), ratio = 8)
p1 = p1 + ggtitle("Marginal distribution of f(x*)") + xlab("f(x*)") + ylab("density")
p4 = p1 + ggtitle("Marginal distribution of f(x)") + xlab("f(x)")

p2 = ggplot(data.grid, aes(x = X1, y = X2, z = prob, fill = prob)) 
p2 = p2 + geom_raster(aes(fill = prob))
p2 = p2 + geom_contour(colour = "white") 
p2 = p2 + coord_fixed(xlim = c(-4, 4), ylim = c(-4, 4), ratio = 1) + theme_bw() + theme(legend.position = "none")
p2 = p2 + ggtitle("Bivariate Normal Density") + xlab("f(x)") + ylab("f(x*)")

p3 = ggplot() + geom_line(data = data.frame(x = x, y = rep(0, length(x))), aes(x = x, y = y), lty = 2) 
p3 = p3 + coord_fixed(xlim = c(-2, 2), ylim = c(-4, 4), ratio = 1 / 2) + 
  ggtitle("Posterior process") + theme_bw() + ylab("f(x)")
grid.arrange(p1, p2, p3, p4, ncol = 2)

###########################################################

p3 = p3 + annotate(x = x1, y = f.x1, colour = "red", size = 2, geom = "point") +
  annotate(x = - 0.5, y = 1.6, label = "training point", colour = "red", geom = "text")
grid.arrange(p1, p2, p3, p4, ncol = 2)

############################################################

p4 = p4 + geom_vline(xintercept = f.x1, colour = "red") 
p4 = p4 + 
  annotate(x = f.x1 - 1, y = 0.5, label = "observed \n value", colour = "red", geom = "text")
p2 = p2 + geom_vline(xintercept = f.x1, colour = "red")

grid.arrange(p1, p2, p3, p4, ncol = 2)

###########################################################

m.cond = K[1, 2] / K[1, 1] * 1
s.cond = K[2, 2] - K[1, 2]^2 / K[1, 1]

y.post = dnorm(x = x, mean = m.cond, sd = s.cond)
p1 = p1 + geom_line(data = data.frame(x = x, y = y.post), aes(x = x, y = y, colour = y)) +
  theme(legend.position = "none")
grid.arrange(p1, p2, p3, p4, ncol = 2)

#########################################################

p1 = p1 + geom_vline(xintercept = m.cond, colour = "orange")
p3 = p3 + annotate(x = 0.5, y = m.cond, colour = "orange", size = 2, geom  ="point") +
  annotate(x = 0.5, y = m.cond + 0.6, label = "prediction", colour = "orange", geom = "text")
grid.arrange(p1, p2, p3, p4, ncol = 2) 

#########################################################

d.process = data.frame(x = seq(-2, 2, by = 0.01)) 
d.process$k = sapply(d.process, function(x) exp(-0.5 * (x - x1)^2))
d.process$m.post = d.process$k * 1 
d.process$k.post = 1 - d.process$k^2

p3 = p3 + geom_line(data = d.process, aes(x = x, y = m.post))
p3 = p3 + geom_line(data = d.process, aes(x = x, y = m.post + 2 * k.post), color = "grey")
p3 = p3 + geom_line(data = d.process, aes(x = x, y = m.post - 2 * k.post), color = "grey")
p3 = p3 + geom_ribbon(data = d.process, 
                      aes(x = x, ymax = m.post + 2 * k.post, ymin = m.post - 2 * k.post), fill = "grey", alpha = .5)
grid.arrange(p1, p2, p3, p4, ncol = 2)
##########################################################

set.seed(124415)
x = seq(-5, 5, by = 0.01)
y = cos(x) 
df = data.frame(x = x, y = y)
train = sample(1:length(x), 5)
istrain = 1:length(x) %in% train

configureMlr(show.info = FALSE, show.learner.output = FALSE)
tsk = makeRegrTask(id = "GP as interpolator", data = df, target = "y")
lrn = makeLearner("regr.km", predict.type = "se", par.vals = list(nugget.estim = FALSE))
mod = train(lrn, tsk, subset = train)
pred = predict(mod, tsk)
pred = cbind(pred$data, x = df$x, type = istrain)

p = ggplot() + geom_point(data = pred[train, ], aes(x = x, y = truth), size = 1, colour = "red")
p = p + geom_line(data = pred, aes(x = x, y = response))
p = p + geom_ribbon(data = pred, aes(x = x, ymin = response - 2 * se, ymax = response + 2 * se), fill = "grey70", alpha = 0.3)
p = p + theme_bw() + ylab(expression(hat(f)(x))) + 
  labs(caption = "After observing the training points (red), the posterior process (black) interpolates the training points.\n (k(x,x') is Matèrn with nu = 2.5, the default for DiceKriging::km)")
ggsave(filename = "figure_man/gp-interpolator.png", plot = p, width = 6, height = 3)

#########################################################

configureMlr(show.info = FALSE, show.learner.output = FALSE)

set.seed(1234)
obj.fun =  makeHimmelblauFunction()
des = generateDesign(n = 10, par.set = getParamSet(obj.fun), )
des$y = apply(des, 1, obj.fun)
surr.km = makeLearner("regr.km", predict.type = "se", covtype = "gauss")

control = makeMBOControl()
control = setMBOControlTermination(control, iters = 5)
control = setMBOControlInfill(control, crit = makeMBOInfillCritEI())

run = mbo(obj.fun, design = des, learner = surr.km, control = control, show.info = TRUE)

points = data.frame(run$opt.path)

x = seq(-4.5, 4.5, length.out = 200)
z = expand.grid(x1 = x, x2 = x)
pred = predict(run$models[[1]], newdata = z)
z$se = pred$data$se
z$pred = pred$data$response


p1 = ggplot() + ylim(c(-4.5, 4.5)) + xlim(c(-4.5, 4.5))
p1 = p1 + geom_raster(data = z, aes(x = x1, y = x2, fill = pred), alpha = 0.8) 
p1 = p1 + geom_point(data = points, aes(x = x1, y = x2), size = 3, color = "orange")
p1 = p1 + scale_fill_gradient(low = "black", high = "white", name = "post. mean") 
p1 = p1 + xlab(expression(x[1])) + ylab(expression(x[2]))
p1 = p1 + theme(legend.text = element_text(size = 12))

p2 = ggplot() + ylim(c(-4.5, 4.5)) + xlim(c(-4.5, 4.5))
p2 = p2 + geom_raster(data = z, aes(x = x1, y = x2, fill = se), alpha = 0.8) 
p2 = p2 + geom_point(data = points, aes(x = x1, y = x2), size = 3, color = "orange")
p2 = p2 + labs(fill = "post. variance") 
p2 = p2 + xlab(expression(x[1])) + ylab(expression(x[2]))
p2 = p2 + theme(legend.text = element_text(size = 12))

p1
p2
########################################################

set.seed(124415)
n = 6
x.obs = runif(n, -2, 2)
y.obs = x.obs^2 + rnorm(n)
df = data.frame(x = x.obs, y = y.obs)

preddf = data.frame(x = seq(-2, 2, by = 0.01))

configureMlr(show.info = FALSE, show.learner.output = FALSE)
tsk = makeRegrTask(id = "GP as interpolator", data = df, target = "y")
lrn = makeLearner("regr.km", predict.type = "se", par.vals = list(nugget.estim = TRUE, covtype = "gauss"))
mod = train(lrn, tsk)
pred = cbind(preddf, predict(mod, newdata = preddf)$data)

p = ggplot() + geom_point(data = df, aes(x = x, y = y), size = 1, colour = "red")
p = p + geom_line(data = pred, aes(x = x, y = response))
p = p + geom_ribbon(data = pred, aes(x = x, ymin = response - 2 * se, ymax = response + 2 * se), fill = "grey70", alpha = 0.3)
p = p + theme_bw() + ylab(expression(hat(f)(x))) + 
  labs(caption = "After observing the training points (red), we have a nugget-band around the oberved points. \n (k(x,x') is the squared exponential)")
ggsave(filename = "figure_man/gp-regression.png", plot = p, width = 6, height = 3)








