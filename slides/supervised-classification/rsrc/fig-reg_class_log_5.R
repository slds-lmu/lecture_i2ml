 
library(knitr)
library(mlbench)
library(mlr)
library(OpenML)

library(ggplot2)
library(viridis)
library(gridExtra)
library(ggrepel)
library(repr)

library(data.table)
library(BBmisc)


library(party)
library(kableExtra)
library(kknn)
library(e1071)

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))




pdf("../figure/reg_class_log_5.pdf", width = 8, height = 3)
set.seed(1234)
n = 20
x = runif(n, min = 0, max = 7)
y = x + rnorm(n) > 3.5
df = data.frame(x = x, y = y)

model = glm(y ~ x,family = binomial(link = 'logit'), data = df)
df$score = predict(model)
df$prob = predict(model, type = "response")
x = seq(0, 7, by = 0.01)
dfn = data.frame(x = x)
dfn$prob = predict(model, newdata = dfn, type = "response")
dfn$score = predict(model, newdata = dfn)

p2 = ggplot() + geom_line(data = dfn, aes(x = x, y = prob))
p2 = p2 + geom_point(data = df, aes(x = x, y = prob, colour = y), size = 2)
p2 = p2 + xlab("x") + ylab(expression(pi(x)))
p2 = p2 + theme(legend.position = "none")
p2
ggsave("../figure/reg_class_log_5.pdf", width = 8, height = 3)
dev.off()

