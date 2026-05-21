library(rpart)
library(tidyverse)
library(patchwork)
library(rattle)
library(xtable)
set.seed(12)
df <- data.frame(x = runif(100, 0, 12))
df$Truth <- sin(0.5 * (df$x + sqrt(df$x))) + 0.01 * df$x^2
df$y <- df$Truth + rnorm(100, 0, 0.15)
plot(df$x, df$y, xlim = c(0, 10))

tree <- rpart(y ~ x, df[df$x <= 10, ])
Tree <- predict(tree, df)
plot_frame <- cbind(df, Tree)
plot_frame <- plot_frame %>% pivot_longer(cols = c(Truth, Tree))

a <- ggplot(plot_frame, aes(x, y)) + geom_point() + 
  geom_line(aes(x, value, col = name)) + theme_bw() +
  xlim(0, 10) + 
  scale_x_continuous(limits = c(0, 10), breaks = seq(0, 10, by = 5)) +
  theme(legend.title = element_blank(), legend.position = c(0.2, 0.85))
b <- ggplot(plot_frame, aes(x, y)) + geom_point() + 
  geom_line(aes(x, value, col = name)) + theme_bw() +
  scale_x_continuous(limits = c(0, 12), breaks = seq(0, 12, by = 6)) +
  theme(legend.position = "none")
ggsave("slides/trees/figure/not-smooth-extrapolation.pdf",
       a + b, 
       units = "cm",
       width = 16, height = 8.1)


library(mlbench)
library(mlr)
data(BreastCancer)
d = BreastCancer
d$Id = NULL
for (i in 1:9)
  d[,i] = as.integer(d[,i])
print(str(d))
lrn = makeLearner("classif.rpart")
task1 = makeClassifTask(data = d, target = "Class")
mod1 = train(lrn, task1)
d2 = d[-13, ]
task2 = makeClassifTask(data = d2, target = "Class")
mod2 = train(lrn, task2)
png("slides/trees/figure/instability_full.pdf", 
    width = 824, height = 644, pointsize = 22)
fancyRpartPlot(mod1$learner.model, sub = "")
dev.off()

png("slides/trees/figure/instability_reduced.pdf", 
    width = 824, height = 644, pointsize = 22)
fancyRpartPlot(mod2$learner.model, sub = "")
dev.off()

full <- predict(mod1, task2)
reduced <- predict(mod2, task2)
data <- data.frame(full = full$data$response, reduced = reduced$data$response)
xtable(table(data))

