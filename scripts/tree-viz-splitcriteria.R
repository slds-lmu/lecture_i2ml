source("scripts/tree-viz.R")
# creates plots for splitcriteria and splitcriteria for classifiaction and regression

set.seed(19)
x <- runif(100, 0, 10)
y <- 2 * (0.5 * sin(x * 2 - 0.1) + 0.75 * cos(0.5 * x)) + rnorm(100, 0, 0.2)
df <- data.frame(x, y)

p <- plot_boundaries(iris, Species ~ Sepal.Length + Sepal.Width, 
                          "Sepal.Length", "Sepal.Width", 
                          cols = c(virginica = "#0CB702", versicolor = "#00A9FF", setosa = "#FF68A1"), 
                          maxdepth = 4, alpha = 0.2)

split_point <- p$plot_area(2) + theme(legend.position = "top") + xlim(c(4.2, 5.4)) + 
  ylim(c(2.6,2.95)) + theme(legend.position = "none") +
  annotate("rect", ymin = -Inf, ymax = 2.8, xmin = -Inf, xmax = Inf, fill = "#00A9FF", alpha = 0.25) +
  annotate("rect", ymin = 2.8, ymax = Inf, xmin = -Inf, xmax = Inf, fill = "#FF68A1", alpha = 0.25)
ggsave("slides/trees/figure/split_point.pdf", split_point, units = "cm",
       width = 9.8, height = 9.8)

mean_plot <- ggplot(df, aes(x, y)) + geom_point() + theme_bw() + 
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = mean(y), ymax = mean(y), col = "red") +
  ylab(expression(italic(y))) + xlab(expression(italic(x[j])))

ggsave("slides/trees/figure/splitcrit_optimal-constant.pdf", mean_plot, units = "cm",
       width = 9.8, height = 9.8)

mean_subplot1 <- ggplot(df, aes(x, y)) + geom_point() + theme_bw() + 
  annotate("rect", xmin = -Inf, xmax = 2.5, ymin = mean(y[x <= 2.5]), 
           ymax = mean(y[x <= 2.5]), col = "red") +
  annotate("rect", xmin = 2.5, xmax = Inf, ymin = mean(y[x > 2.5]), 
           ymax = mean(y[x > 2.5]), col = "red") +
  annotate("rect", xmin = 2.5, xmax = 2.5, ymin = -Inf, ymax = Inf, col = "black") +
  ylab(expression(italic(y))) + xlab(expression(italic(x[j])))
mean_subplot2 <- ggplot(df, aes(x, y)) + geom_point() + theme_bw() + 
  annotate("rect", xmin = -Inf, xmax = 5.25, ymin = mean(y[x <= 5.25]), 
           ymax = mean(y[x <= 5.25]), col = "red") +
  annotate("rect", xmin = 5.25, xmax = Inf, ymin = mean(y[x > 5.25]), 
           ymax = mean(y[x > 5.25]), col = "red") +
  annotate("rect", xmin = 5.25, xmax = 5.25, ymin = -Inf, ymax = Inf, col = "black") +
  ylab(expression(italic(y))) + xlab(expression(italic(x[j])))

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
split_risk$id <- 1:40
split_risk$mark <- as.factor(as.integer(1:40 %in% c(4, 8)))
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

lower1 <- ggplot(split_risk %>% filter(x == possible_splits[4]), aes(x, risk)) +
  geom_point(col = "orange") +
  theme_bw() + ylab("Risk") + xlim(c(0, 10)) + ylim(c(80, 175)) +
  xlab(expression(italic(x[j]))) +
  annotate("rect", ymin = -Inf, ymax = Inf, xmin = possible_splits[4],
           xmax = possible_splits[4], col = "black", linetype = "dashed") 

lower2 <- ggplot(split_risk %>% filter(x == possible_splits[8]), aes(x, risk)) + 
  geom_point(col = "orange") +
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
lower_final <- ggplot(split_risk, aes(x, risk)) + 
  geom_point(aes(col = mark)) +
  geom_path() +
  theme_bw() + 
  theme(legend.position = "none") +
  scale_color_manual(values = c("black", "orange")) +
  ylab("Risk") + xlim(c(0, 10)) + ylim(c(80, 175)) +
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

base <- ggplot(data = iris, aes(Sepal.Length, Sepal.Width)) + 
  geom_point(aes(shape = Species, col = Species)) +
  scale_color_manual(values = c(virginica = "#0CB702", versicolor = "#00A9FF", setosa = "#FF68A1")) +
  theme_bw() + theme(legend.position = "none") +
  xlim(4.05, 8.05)
 
get_risk_brier <- function(y, x, split) {
  y1 <- y[x <= split]
  y2 <- y[x > split]
  y1_expanded <- as.integer(y1)
  y2_expanded <- as.integer(y2)
  p1 <- table(y1) / length(y1)
  p2 <- table(y2) / length(y2)
  loss <- 0
  for (i in 1:length(unique(y))) {
    loss <- loss + sum(((y1_expanded == i) - p1[i]) ^ 2) + 
      sum(((y2_expanded == i) - p2[i]) ^ 2) 
  }
  p1 <- t(t(p1))
  p1 <- data.frame(Label = rownames(p1), proportion = p1[, 1])
  p2 <- t(t(p2))
  p2 <- data.frame(Label = rownames(p2), proportion = p2[, 1])
  list(loss = round(loss, 1), predictions = list(left = p1, right = p2))
}

possible_splits <- seq(4.5, 7.5, 0.25)
bs <- lapply(possible_splits, get_risk_brier, y = iris$Species, x = iris$Sepal.Length)

riskds <- data.frame(loss = unlist(lapply(bs, "[[", "loss")),
                     split = possible_splits)

upper_mid <- base + annotate("rect", ymin = -Inf, ymax = Inf, 
                             xmin = possible_splits[3], xmax = possible_splits[3], 
                             col = "black") + xlab("")
upper_left <- ggplot(data = bs[[3]]$predictions$left, 
                     aes(x = Label, y = proportion, fill = Label)) + 
  geom_bar(stat = "identity") + ylab("Proportion") +
  ylim(c(0, 1)) +
  scale_fill_manual(values = c(virginica = "#0CB702", versicolor = "#00A9FF", setosa = "#FF68A1")) +
  theme_bw() + theme(axis.text.x = element_text(angle = 15)) +
  xlab("") +
  theme(legend.position = "none")

upper_right <- ggplot(data = bs[[3]]$predictions$right, 
                     aes(x = Label, y = proportion, fill = Label)) + 
  geom_bar(stat = "identity") + ylab("Proportion") +
  ylim(c(0, 1)) +
  scale_fill_manual(values = c(virginica = "#0CB702", versicolor = "#00A9FF", setosa = "#FF68A1")) +
  theme_bw() + theme(axis.text.x = element_text(angle = 15)) + xlab("") +
  theme(legend.position = "none")

lower <- ggplot(data = riskds[3, ], aes(split, loss)) + 
  geom_point() + annotate("rect", col = "black", ymin = -Inf, ymax = Inf, 
                          linetype = "dashed",
                          xmin = possible_splits[3], xmax = possible_splits[3]) +
  xlim(4.05, 8.05) + ylim(65, 100) + theme_bw() + xlab("Sepal.Length") +
  ylab("Risk")

plot1 <- (upper_left + upper_mid + upper_right +
            plot_spacer() + lower + plot_spacer()) +
  plot_layout(ncol = 3, nrow = 2)
plot1

upper_mid <- base + annotate("rect", ymin = -Inf, ymax = Inf, 
                             xmin = possible_splits[9], xmax = possible_splits[9], 
                             col = "black") + xlab("") 
upper_left <- ggplot(data = bs[[9]]$predictions$left, 
                     aes(x = Label, y = proportion, fill = Label)) + 
  geom_bar(stat = "identity") + ylab("Proportion") +
  ylim(c(0, 1)) +
  scale_fill_manual(values = c(virginica = "#0CB702", versicolor = "#00A9FF", setosa = "#FF68A1")) +
  theme_bw() + theme(axis.text.x = element_text(angle = 15)) +
  theme(legend.position = "none") + xlab("")

upper_right <- ggplot(data = bs[[9]]$predictions$right, 
                      aes(x = Label, y = proportion, fill = Label)) + 
  geom_bar(stat = "identity") + ylab("Proportion") +
  ylim(c(0, 1)) +
  scale_fill_manual(values = c(virginica = "#0CB702", versicolor = "#00A9FF", setosa = "#FF68A1")) +
  theme_bw() + theme(axis.text.x = element_text(angle = 15)) +
  theme(legend.position = "none") + xlab("")

lower <- ggplot(data = riskds[9, ], aes(split, loss)) + 
  geom_point() + annotate("rect", col = "black", ymin = -Inf, ymax = Inf, 
                          linetype = "dashed",
                          xmin = possible_splits[9], xmax = possible_splits[9]) +
  xlim(4.05, 8.05) + ylim(65, 100) + theme_bw() + xlab("Sepal.Length") +
  ylab("Risk")

plot2 <- (upper_left + upper_mid + upper_right +
            plot_spacer() + lower + plot_spacer()) +
  plot_layout(ncol = 3, nrow = 2)
plot2

upper_mid  <- base + annotate("rect", ymin = -Inf, ymax = Inf, 
                          xmin = possible_splits[5], xmax = possible_splits[5], 
                          col = "black") + xlab("")
lower <- ggplot(data = riskds, aes(split, loss)) + 
  geom_point() + annotate("rect", col = "black", ymin = -Inf, ymax = Inf, 
                          linetype = "dashed",
                          xmin = possible_splits[5], xmax = possible_splits[5]) +
  xlim(4.05, 8.05) + ylim(65, 100) + theme_bw() + xlab("Sepal.Length") +
  ylab("Risk")
upper_left <- ggplot(data = bs[[5]]$predictions$left, 
                     aes(x = Label, y = proportion, fill = Label)) + 
  geom_bar(stat = "identity") + ylab("Proportion") +
  scale_fill_manual(values = c(virginica = "#0CB702", versicolor = "#00A9FF", setosa = "#FF68A1")) +
  theme_bw() + theme(axis.text.x = element_text(angle = 15)) +
  ylim(c(0, 1)) +
  theme(legend.position = "none") + xlab("")

upper_right <- ggplot(data = bs[[5]]$predictions$right, 
                      aes(x = Label, y = proportion, fill = Label)) + 
  geom_bar(stat = "identity") + ylab("Proportion") +
  scale_fill_manual(values = c(virginica = "#0CB702", versicolor = "#00A9FF", setosa = "#FF68A1")) +
  theme_bw() + theme(axis.text.x = element_text(angle = 15)) +
  ylim(c(0, 1)) +
  theme(legend.position = "none") + xlab("")

plot3 <- (upper_left + upper_mid + upper_right +
            plot_spacer() + lower + plot_spacer()) +
  plot_layout(ncol = 3, nrow = 2)
plot3

ggsave("slides/trees/figure/splitcrit-classif_optimal-constant-sub1.pdf", plot1, 
       units = "cm",
       width = 26, height = 16)

ggsave("slides/trees/figure/splitcrit-classif_optimal-constant-sub2.pdf", plot2, 
       units = "cm",
       width = 26, height = 16)

ggsave("slides/trees/figure/splitcrit-classif_optimal-constant-grid.pdf", plot3, 
       units = "cm",
       width = 26, height = 16)

