source("scripts/tree-viz.R")

png("slides/trees/figure/tree-binary.pdf", 
    width = 1024, height = 524, pointsize = 22)
p$plot_tree(1)
dev.off()


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
df <- data.frame(x, y, y_true = 2 * (0.5 * sin(x * 2 - 0.1) + 0.75 * cos(0.5 * x)))

p <- plot_contin(y ~ x, data = df, minsplit = 1, minbucket = 1, cp = -1, maxdepth = 14, vertical = FALSE)
p$plot_area(7)

ggsave("slides/trees/figure/tree-overfitting-prediction.pdf",
       p$plot_area(7) + geom_line(aes(x, y_true)) +
         theme_bw() + ylab(expression(italic(y)))+
         xlab(expression(italic(x))), units = "cm",
       width = 12, height = 8)

p <- plot_contin(y ~ x, data = df, minsplit = 1, minbucket = 5, cp = 0.001, maxdepth = 14, vertical = FALSE)
p$plot_area(6)

ggsave("slides/trees/figure/tree-less-overfitting-prediction.pdf",
       p$plot_area(6) + geom_line(aes(x, y_true)) +
         theme_bw() + ylab(expression(italic(y)))+
         xlab(expression(italic(x))), units = "cm",
       width = 12, height = 8)

pdf("slides/trees/figure/tree-overfitting.pdf", 
    width = 2024, height = 1024, pointsize = 22)
p$plot_tree(7)
dev.off()


df <- data.frame(
  depth = 1:12,
  loss = c(112.32, 100.01, 98.54, 95.95, 95.02, 94.87, 93.12, 92.31, 55.71, 
           17.03, 17.01, 15.97))

ggsave("slides/trees/figure/horizon.pdf",
       ggplot(df, aes(depth, loss)) + geom_path() + theme_bw() +
         xlab("Depth") + ylab("Training loss") + 
         annotate("rect", col = "darkgreen", xmin = 8, xmax = 8, ymin = -Inf, ymax = Inf) +
         annotate("text", col = "darkgreen", label = "Horizon", x = 7, y = 30) +
         scale_x_continuous(limits = c(1, 12), breaks = seq(0, 12, by = 2)), 
       units = "cm",
       width = 12, height = 8)
  

