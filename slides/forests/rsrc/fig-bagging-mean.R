library(ggplot2)
library(rpart)

set.seed(6)
n <- 70
x <- runif(n, 0, 10)
y <- sin(x) + rnorm(n, sd=0.5)

data <- data.frame(x=x, y=y)

trees <- lapply(1:100, function(i) {
  samp <- sample(n, replace=TRUE)
  rpart(y ~ x, data=data[samp,], method="anova")
})

x_seq <- seq(0, 10, length.out=250)
preds <- sapply(trees, function(tree) predict(tree, newdata=data.frame(x=x_seq)))

mean_preds <- rowMeans(preds)

plot_df <- data.frame(x = rep(x_seq, each = 101), 
                      y = c(t(preds), mean_preds),
                      Model = factor(c(rep("Individual Trees", 100), "Bagged Mean")))

p1 <- ggplot(data, aes(x=x, y=y)) +
  geom_point(alpha=0.5) +
  stat_function(fun = sin, color = "red")

p2 <- ggplot(plot_df, aes(x=x, y=y, color=Model)) +
  geom_line(alpha=0.3) +
  geom_line(data = subset(plot_df, Model == "Bagged Mean"), size=1.2) +
  theme_minimal()

combined_plot <- grid.arrange(p1, p2, ncol=2)

ggsave("bagging-mean.png", plot = combined_plot, width = 16, height = 8, dpi = 300)
