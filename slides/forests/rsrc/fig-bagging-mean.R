# we want to visualize how bagging works, e.g.
# that the predicitions of the base learners are averaged
# -> creates 100 trees on bootstrapped toy data; visualizes them with their respective average

library(ggplot2)
library(rpart)
library(gridExtra)

set.seed(700)

# we model the sinus function as toy data
n <- 700
x <- runif(n, 0, 10)
y <- sin(x) + rnorm(n, sd=0.6)

data <- data.frame(x=x, y=y)

# fit data on bootstrapped toy data
trees <- lapply(1:200, function(i) {
  samp <- sample(n, replace=TRUE)
  rpart(y ~ x, data=data[samp,], method="anova")
})
x_seq <- seq(0, 10, length.out=250)
preds <- sapply(trees, function(tree) predict(tree, newdata=data.frame(x=x_seq)))

# mean acquired via bagging
mean_preds <- rowMeans(preds)

# combined into a dataframe for plotting
plot_df <- data.frame(x = rep(x_seq, each = 101), 
                      y = c(t(preds), mean_preds),
                      Model = factor(c(rep("Individual Trees", 100), "Bagged Mean")))

# visualization of toy data
p1 <- ggplot(data, aes(x=x, y=y)) +
  geom_point(alpha=0.5) +
  stat_function(fun = sin, color = "red")

# visualization of tree's predictions and mean (bagged)
p2 <- ggplot(plot_df, aes(x=x, y=y, color=Model)) +
  geom_line(alpha=0.3) +
  geom_line(data = subset(plot_df, Model == "Bagged Mean"), size=1.0) +
  theme_minimal()

# combined plots with equal width for slide
combined_plot <- grid.arrange(p1, p2, ncol=2, widths=c(1, 1))

ggsave("../figure/bagging-mean.png", plot = combined_plot, width = 16, height = 8, dpi = 300)
