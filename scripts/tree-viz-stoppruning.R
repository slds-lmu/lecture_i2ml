source("scripts/tree-viz.R")

png("slides/trees/figure/tree-binary.pdf", 
    width = 1024, height = 524, pointsize = 22)
p$plot_tree(1)
dev.off()

ggsave("slides/trees/figure/surrogate-splits.pdf", left_plot + right_plot, 
       units = "cm",
       width = 21, height = 9.5)

surrogate_tree <- rpart(prediction ~ Sepal.Width, data = iris2, maxdepth = 1L) 
splits <- parttree(surrogate_tree)
splits


p_surro$plot_area(1)

set.seed(8)
df_cat <- data.frame(x = as.factor(sample(c("a", "b", "c", "d", "e"), 100, replace = TRUE)))
df_cat$y <- log((as.integer(df_cat$x)^2 - 3)^2) + rnorm(100, 0, 1)
df_cat$y <- df_cat$y - min(df_cat$y)
df_cat$y <- df_cat$y / max(df_cat$y)
df_cat$y <- ifelse(df_cat$y > 0.5, "Sunny", "Overcast")
df_cat$y[c(4, 7, 19:33, 41, 55:71)] <- c("Rainy")
df_cat$x[c(19:33, 55:71)] <- "d"

tree_cat <- rpart(y ~ x, data = df_cat, cp = -1L)
png("slides/trees/figure/tree-categorical.pdf", 
    width = 1024, height = 624, pointsize = 22)
rpart.plot(tree_cat, type = 4)
dev.off()

set.seed(19)
x <- runif(100, 0, 10)
y <- 2 * (0.5 * sin(x * 2 - 0.1) + 0.75 * cos(0.5 * x)) + rnorm(100, 0, 0.2)
y[c(1, 11, 25, 44, 100)] <- - 2 * y[c(1, 11, 25, 44, 100)] +rnorm(5, 0, 1)
df <- data.frame(x, y)

p <- plot_contin(y ~ x, data = df, minsplit = 1, minbucket = 1, cp = -1, maxdepth = 22, vertical = FALSE)
p$plot_area(7)

ggsave("slides/trees/figure/tree-overfitting-prediction.pdf",
       p$plot_area(7) + theme_bw() + ylab(expression(italic(y)))+
         xlab(expression(italic(x))), units = "cm",
       width = 12, height = 8)

pdf("slides/trees/figure/tree-overfitting.pdf", 
    width = 2024, height = 1024, pointsize = 22)
p$plot_tree(7)
dev.off()

exponential_growth <- data.frame(depth = 1:50, n_leaves = 2^(1:50))
xtable(exponential_growth[c(1, 6, 9, 15, 22, 30, 40),], )
