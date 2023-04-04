source("scripts/tree-viz.R")
# creates plots for splitcriteria and splitcriteria for classifiaction and regression

split_point <- p$plot_area(2) + theme(legend.position = "top") + xlim(c(4.2, 5.4)) + 
  ylim(c(2.7,2.9)) + 
  annotate("rect", ymin = -Inf, ymax = 2.8, xmin = -Inf, xmax = Inf, fill = "#00A9FF", alpha = 0.25) +
  annotate("rect", ymin = 2.8, ymax = Inf, xmin = -Inf, xmax = Inf, fill = "#FF68A1", alpha = 0.25)
ggsave("slides/trees/figure/split_point.pdf", split_point, units = "cm",
       width = 9.8, height = 9.8)

mean_plot <- ggplot(df, aes(x, y)) + geom_point() + theme_bw() + 
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = mean(y), ymax = mean(y), col = "red") +
  xlab("expression(x_{j})", parse = TRUE)

ggsave("slides/trees/figure/splitcrit_optimal-constant.pdf", mean_plot, units = "cm",
       width = 9.8, height = 9.8)

mean_subplot1 <- ggplot(df, aes(x, y)) + geom_point() + theme_bw() + 
  annotate("rect", xmin = -Inf, xmax = 2.5, ymin = mean(y[x <= 2.5]), 
           ymax = mean(y[x <= 2.5]), col = "red") +
  annotate("rect", xmin = 2.5, xmax = Inf, ymin = mean(y[x > 2.5]), 
           ymax = mean(y[x > 2.5]), col = "red") +
  annotate("rect", xmin = 2.5, xmax = 2.5, ymin = -Inf, ymax = Inf, col = "black")
mean_subplot2 <- ggplot(df, aes(x, y)) + geom_point() + theme_bw() + 
  annotate("rect", xmin = -Inf, xmax = 5.25, ymin = mean(y[x <= 5.25]), 
           ymax = mean(y[x <= 5.25]), col = "red") +
  annotate("rect", xmin = 5.25, xmax = Inf, ymin = mean(y[x > 5.25]), 
           ymax = mean(y[x > 5.25]), col = "red") +
  annotate("rect", xmin = 5.25, xmax = 5.25, ymin = -Inf, ymax = Inf, col = "black")

ggsave("slides/trees/figure/splitcrit_optimal-constant-sub1.pdf", mean_subplot1, 
       units = "cm",
       width = 6.8, height = 6.8)
ggsave("slides/trees/figure/splitcrit_optimal-constant-sub2.pdf", mean_subplot2, 
       units = "cm",
       width = 6.8, height = 6.8)

round(var(y[x <= 2.5]), 3)
round(var(y[x > 2.5]), 3)
round(var(y[x <= 5.25]), 3) 
round(var(y[x > 5.25]), 3)

length(y[x <= 2.5])
length(y[x > 2.5])
length(y[x <= 5.25])
length(y[x > 5.25])

round(var(y[x <= 2.5]) * (length(y[x <= 2.5]) / 100), 3) +
  round(var(y[x > 2.5]) * (length(y[x > 2.5]) / 100), 3) 
round(var(y[x <= 5.25]) * (length(y[x <= 5.25]) / 100), 3) +
  round(var(y[x > 5.25]) * (length(y[x > 5.25]) / 100), 3) 

get_var <- function(y, x, split) {
  y1 <- y[x <= split]
  y2 <- y[x > split]
  n1 <- length(y1)
  n2 <- length(y2)
  var(y1) * (n1/ (n1 + n2)) + var(y2) * (n2 / (n1 + n2))
}

get_risk <- function(y, x, split) {
  y1 <- y[x <= split]
  y2 <- y[x > split]
  p1 <- mean(y1)
  p2 <- mean(y2)
  sum((y1 - p1)^2) + sum((y2 - p2)^2)
}

search_plot <- ggplot(df, aes(x, y)) + geom_point() + theme_bw() 
possible_splits <- seq(0.5, 9.5, length.out = 40)
variance <- rep(0, length(possible_splits))
risk <- variance
for (i in 1:length(possible_splits)) {
  search_plot <- search_plot +
    annotate("rect", xmin = possible_splits[i], xmax = possible_splits[i], 
             ymin = -Inf, ymax = Inf, col = "black", linetype = "dashed")
  variance[i] <- get_var(y, x, possible_splits[i])
  risk[i] <- get_risk(y, x, possible_splits[i])
}

upper <- search_plot + 
  annotate("rect", ymin = -Inf, ymax = Inf, xmin = possible_splits[4],
           xmax = possible_splits[4], col = "darkgreen") +
  ylab(expression(italic(y))) + xlab(expression(italic(x[j])))
variance
split_variance <- data.frame(x = possible_splits, variance)
split_risk <- data.frame(x = possible_splits, risk)
lower <- ggplot(split_variance, aes(x, variance)) + geom_path() + geom_point() +
  theme_bw() + ylab("Variance") + xlim(c(0, 10)) +
  xlab(expression(italic(x[j]))) + ylim(c(0.6, 2)) + 
  geom_point(aes(x = possible_splits[4], y = variance[4]), 
             col = "darkgreen")

ggsave("slides/trees/figure/splitcrit_optimal-constant-grid.pdf", upper / lower, 
       units = "cm",
       width = 13.2, height = 11.8)


upper1 <- ggplot(df, aes(x, y)) + geom_point() + theme_bw() +
  xlim(c(0, 10)) + xlab("") +
  annotate("rect", ymin = -Inf, ymax = Inf, xmin = possible_splits[4],
           xmax = possible_splits[4], col = "black", linetype = "dashed") +
  ylab(expression(italic(y)))+ 
  annotate("rect", xmin = -Inf, xmax = possible_splits[4],
           ymin = mean(y[x < possible_splits[4]]), ymax = mean(y[x < possible_splits[4]]),
           col = "red") +
  annotate("rect", xmin = possible_splits[4], xmax = Inf,
           ymin = mean(y[x >= possible_splits[4]]), ymax = mean(y[x >= possible_splits[4]]),
           col = "red") 

upper2 <- ggplot(df, aes(x, y)) + geom_point() + theme_bw() +
  xlim(c(0, 10)) + xlab("") + ylab("") +
  annotate("rect", ymin = -Inf, ymax = Inf, xmin = possible_splits[8],
           xmax = possible_splits[8], col = "black", linetype = "dashed") +
  annotate("rect", xmin = -Inf, xmax = possible_splits[8],
           ymin = mean(y[x < possible_splits[8]]), ymax = mean(y[x < possible_splits[8]]),
           col = "red") +
  annotate("rect", xmin = possible_splits[8], xmax = Inf,
           ymin = mean(y[x >= possible_splits[8]]), ymax = mean(y[x >= possible_splits[8]]),
           col = "red") 

lower1 <- ggplot(split_risk %>% filter(x == possible_splits[4]), aes(x, risk)) + geom_point() +
  theme_bw() + ylab("Risk") + xlim(c(0, 10)) + ylim(c(80, 175)) +
  xlab(expression(italic(x[j]))) +
  annotate("rect", ymin = -Inf, ymax = Inf, xmin = possible_splits[4],
           xmax = possible_splits[4], col = "black", linetype = "dashed") 

lower2 <- ggplot(split_risk %>% filter(x == possible_splits[8]), aes(x, risk)) + geom_point() +
  theme_bw() + ylab("") + xlim(c(0, 10)) + ylim(c(80, 175)) +
  xlab(expression(italic(x[j]))) +
  annotate("rect", ymin = -Inf, ymax = Inf, xmin = possible_splits[8],
           xmax = possible_splits[8], col = "black", linetype = "dashed") 

library(patchwork)
ggsave("slides/trees/figure/splitcrit_optimal-constant-grid.pdf", 
       (upper1 + upper2) / (lower1 + lower2), 
       units = "cm",
       width = 18.2, height = 11.8)


upper_final <- ggplot(df, aes(x, y)) + geom_point() + theme_bw() +
  xlim(c(0, 10)) + xlab("") +
  annotate("rect", ymin = -Inf, ymax = Inf, xmin = possible_splits[which.min(risk)],
           xmax = possible_splits[which.min(risk)], col = "black", linetype = "dashed") +
  ylab(expression(italic(y)))+ 
  annotate("rect", xmin = -Inf, xmax = possible_splits[which.min(risk)],
           ymin = mean(y[x < possible_splits[which.min(risk)]]), 
           ymax = mean(y[x < possible_splits[which.min(risk)]]),
           col = "red") +
  annotate("rect", xmin = possible_splits[which.min(risk)], xmax = Inf,
           ymin = mean(y[x >= possible_splits[which.min(risk)]]), 
           ymax = mean(y[x >= possible_splits[which.min(risk)]]),
           col = "red") 
lower_final <- ggplot(split_risk, aes(x, risk)) + geom_point() +
  geom_path() +
  theme_bw() + ylab("Risk") + xlim(c(0, 10)) + ylim(c(80, 175)) +
  xlab(expression(italic(x[j]))) +
  annotate("rect", ymin = -Inf, ymax = Inf, xmin = possible_splits[which.min(risk)],
           xmax = possible_splits[which.min(risk)], col = "green", linetype = "dashed") 

ggsave("slides/trees/figure/splitcrit_optimal-constant-grid2.pdf", 
       upper_final / lower_final, 
       units = "cm",
       width = 15.2, height = 11.8)


constant_classif <- ggplot(iris %>% filter(Sepal.Length < 6.5), aes(Sepal.Length, Sepal.Width)) + 
  geom_point(aes(shape = Species, col = Species)) +
  scale_color_manual(values = c(virginica = "#0CB702", versicolor = "#00A9FF", setosa = "#FF68A1")) +
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf,
           alpha = 0.25, fill = "#FF68A1") + theme(legend.position="top")

ggsave("slides/trees/figure/splitcrit_optimal-constant-classif.pdf", constant_classif, 
       units = "cm",
       width = 9.8, height = 9.8)