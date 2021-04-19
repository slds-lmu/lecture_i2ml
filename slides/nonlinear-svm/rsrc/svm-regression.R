# plot for epsilon-insensitive regression
# scatterplot of linear data with epsilon-cube around it

library(ggplot2)

set.seed(1234)
x = seq(0, 1, length.out = 100)
y = x + rnorm(100, 0, 0.05)
df = data.frame(x = x, y = y)

p = ggplot(df, aes(x, y)) + geom_point(size = 3, color = "grey")
p = p + geom_abline(intercept = 0, slope = 1)
p = p + geom_abline(intercept = 0.12, slope = 1, linetype = 2)
p = p + geom_abline(intercept = -0.12, slope = 1, linetype = 2)
p = p + geom_segment(aes(x = .5, y = .5, xend = .5, yend = .38), color = "red")
p = p + geom_text(aes(x = 0.52, y = 0.46, label = "epsilon"), parse = TRUE, color = "red", size = 8)
p
ggsave("figure_man/regression/svm_regression.pdf")
