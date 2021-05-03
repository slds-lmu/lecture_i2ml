

library(ggplot2)
library(randomForest)
library(colorspace)
library(mlr)
library(mboost)
library(mlbench)
source("rsrc/cim1_optim.R")
library(tidyr)


############################################ COMPONENTWISE GRADIENT BOOSTING
load("rsrc/spam.RData")
m = 20
model = glmboost(spam ~ ., data = spam, family = Binomial(),
                 control = boost_control(mstop = m))

data = do.call(cbind, lapply(model$coef(aggregate = "cumsum"), as.numeric))
data = gather(as.data.frame(data), "base_learner", "y")
data$m = rep(seq_len(m), times = nrow(data) / m)
data$base_learner = reorder(data$base_learner, data$y, function(x) -max(x), order = TRUE)

p = ggplot(data, aes(x = m, y = y, color = base_learner)) +
  geom_line(size = 1.5, alpha = .3) +
  ylab(expression(theta[j])) +
  labs(caption = "First 20 boosting iterations on Spam example") +
  scale_x_discrete(limits = c(as.character(1:m)))
p

#############################################################

p + geom_vline(xintercept = 5, linetype = 2, size = 1) +
  labs(caption = "mstop = 5:  Four selected base learners") + theme(legend.position = "none")
p + geom_vline(xintercept = 12, linetype = 2, size = 1) +
  labs(caption = "mstop = 12: Five selected base learners") + theme(legend.position = "none")

#################################################### NONLINEAR BASE LEARNERS

library(splines)
x <- seq(0, 1, by = 0.001)
spl <- bs(x, df = 6, intercept = TRUE)


layout(matrix(c(3, 2, 1, 1), 2, 2, byrow = TRUE))

w <- c(0.2, 1, 0.5, 1.5, 1.2, 0.8)


res <- w[1] * spl[,1]
for(i in 2:6)
  res <- res + w[i] * spl[,i]

plot(res~x, type = "l", lwd = 2, col = 1,
     xlab = "Sum of cubic B-splines weighted with coefficients")

plot(spl[,1] ~ x, ylim = c(0, max(spl)), type = 'l', lwd = 2, col = 1,
     xlab="Cubic B-spline basis weighted with coefficients", ylab = "")
for (j in 2:ncol(spl)) lines(w[j] * spl[,j] ~ x, lwd = 2)

plot(spl[,1] ~ x, ylim = c(0, max(spl)), type = 'l', lwd = 2, col = 1,
     xlab = "Cubic B-spline basis", ylab = "")

for (j in 2:ncol(spl)) lines(spl[,j] ~ x, lwd = 2)

layout(1)

################################################# SPAM EXAMPLE

load("rsrc/spam.RData")
cols = colnames(spam)[1:(ncol(spam) - 1)]


form = as.formula(paste("spam ~ ",
                        paste(sprintf("bols(%s) + bbs(%s, df = 2, center = TRUE)", cols, cols), collapse = " + ")
))

mod = mboost(form, data = spam, family = Binomial())

const = attr(coef(mod), "offset")
eff = data.frame(const = const, fitted(mod, which = "word_freq_remove", type = "link"))
colnames(eff)[2:3] = c("lin.", "nonlin.")

data = data.frame(gather(eff, "base_learner", "y"), x = rep(spam$word_freq_remove, times = 3))
ggplot(data) +
  geom_line(aes(x = x, y = y, color = base_learner), size = 1, alpha= .5) + geom_rug(aes(x=x), alpha= .5) +
  ylab("base learner") + xlab("word_freq_remove") + theme(legend.position="top") +
  labs(caption = "Separate constant, linear and nonlinear base learner for feature word_freq_remove") +
  theme(plot.caption = element_text(hjust = 0.5))

ggplot(data.frame(y = rowSums(eff), x = spam$word_freq_remove), aes(x = x, y = y)) +
  geom_point() + geom_line() +
  ylab("base learner") + xlab("word_freq_remove") +
  labs(caption = "Overall estimate for feature word_freq_remove") +
  theme(plot.caption = element_text(hjust = 0.5))

###################################################

load("rsrc/comparing_methods.RData")
ggplot(data = ggd2[ggd2$learner %in% c("rf", "ada", "gbm", "blackboost", "rf.fulltree"), ],
       aes(x = iters, y = mmce, col = learner)) + geom_line()
