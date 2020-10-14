# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

set.seed(1234)

n = 20
x = runif(n, min = 0, max = 7)
y = x + rnorm(n) > 3.5
df = data.frame(x = x, y = y)

model = glm(y ~ x, family = binomial(link = "logit"), data = df)

df$score = predict(model)
df$prob = predict(model, type = "response")
x = seq(0, 7, by = 0.01)

dfn = data.frame(x = x)
dfn$prob = predict(model, newdata = dfn, type = "response")
dfn$score = predict(model, newdata = dfn)

# PLOT -------------------------------------------------------------------------

pdf("../figure/reg_class_log_5.pdf", width = 8, height = 5)

p = ggplot() + 
  geom_line(data = dfn, aes(x = x, y = prob))
p = p + geom_point(data = df, aes(x = x, y = prob, colour = y), size = 2)
p = p + xlab("x") + ylab(expression(pi(x)))
p = p + theme(legend.position = "none")
p = p + scale_color_viridis_d(end = .9)
p

ggsave("../figure/reg_class_log_5.pdf", width = 8, height = 5)
dev.off()