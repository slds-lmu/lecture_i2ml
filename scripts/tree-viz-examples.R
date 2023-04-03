source("scripts/tree-viz.R")

####### Examples

p <- plot_boundaries(iris, Species ~ Sepal.Length + Sepal.Width, 
                     "Sepal.Length", "Sepal.Width", 
                     cols = c(virginica = "#0CB702", versicolor = "#00A9FF", setosa = "#FF68A1"), 
                     maxdepth = 4, alpha = 0.2)
p$plot_tree(1)
p$plot_area(1)
p$plot_tree(2)
p$plot_area(2)

png("slides/trees/figure_man/tree_depth3_structure.png", 
    width = 824, height = 824, pointsize = 20)
p$plot_tree(3)
dev.off()

png("slides/trees/figure_man/tree_depth3_structure_wide.png", 
    width = 1024, height = 724, pointsize = 22)
p$plot_tree(3)
dev.off()

ggsave("slides/trees/figure_man/tree_depth3_area.png",
       p$plot_area(3) + theme(legend.position="top"), units = "cm",
       width = 9.8, height = 9.8)

iris2 <- iris[1:100,] %>% mutate(Species = as.factor(as.character(Species)))
p2 <- plot_boundaries(iris2, Species ~ Sepal.Length + Sepal.Width, 
                      "Sepal.Length", "Sepal.Width", 
                      cols = c(setosa = "red", versicolor = "green"), 
                      maxdepth = 4, alpha = 0.2)

p2$plot_tree(1)
p2$plot_area(1)
p2$plot_tree(2)
p2$plot_area(2)
p2$plot_tree(3) #should obviously fail
p2$plot_area(3) #as well

######################## continuous ######
set.seed(19)
x <- runif(100, 0, 10)
y <- 2 * (0.5 * sin(x * 2 - 0.1) + 0.75 * cos(0.5 * x)) + rnorm(100, 0, 0.2)
df <- data.frame(x, y)

pp <- plot_contin(df, y ~x)
pp$plot_area(1) + theme_bw()
pp$plot_tree(1) 
pp$plot_tree(3) 
pp$plot_area(3) + theme_bw()

png("slides/trees/figure_man/tree_depth3_structure_regr.png", 
    width = 824, height = 824, pointsize = 20)
pp$plot_tree(3)
dev.off()
ggsave("slides/trees/figure_man/tree_depth3_area_regr.png",
       pp$plot_area(3) + theme_bw() , units = "cm",
       width = 9.8, height = 9.8)
  

png("slides/trees/figure_man/tree_depth1_structure.png", width = 1224, height = 754,
    pointsize = 25)
p$plot_tree(1)
dev.off()
ggsave("slides/trees/figure_man/tree_depth1_area.png",
       p$plot_area(1) + theme(legend.position="top") , units = "cm",
       width = 9.8, height = 9.8)

png("slides/trees/figure_man/tree_depth2_structure.png", 
    width = 824, height = 824, pointsize = 20)
p$plot_tree(2)
dev.off()
ggsave("slides/trees/figure_man/tree_depth2_area.png",
       p$plot_area(2) + theme(legend.position="top") , units = "cm",
       width = 9.8, height = 9.8)

pnp <- p$plot_area(2) + theme(legend.position="none")
pnp$layers[[1]] <- NULL
pnp <- pnp + xlim(c(4.3, 7.9)) + ylim(c(2, 4.4)) + geom_point(aes(x = 5, y = 3), col = "black", shape = 8)
pnp
ggsave("slides/trees/figure_man/tree_depth3_area_nopoints.png",
        pnp, units = "cm",
       width = 9.8, height = 9.8)

ggsave("slides/trees/figure/cart_intro_classification_tree_wide.pdf", 
       p$plot_area(3) + theme(legend.position="top"), units = "cm",
       width = 15.8, height = 8)

ggsave("slides/trees/figure/cart_intro_regression_tree_wide.pdf", 
       pp$plot_area(3) + theme_bw(), units = "cm",
       width = 15.8, height = 8)

py <- ggplot(data = iris,
       aes(.data[["Sepal.Length"]], .data[["Sepal.Width"]],
           color = .data[["Species"]], 
           shape = .data[["Species"]])) +
  geom_point() + theme_bw() +
  scale_color_manual(values = c(virginica = "#0CB702", versicolor = "#00A9FF", setosa = "#FF68A1")) 


py <- py + annotate("rect", xmin = -Inf, xmax = Inf, ymin = 2.1, ymax = 2.1, col = "darkblue") +   
    annotate("rect", xmin = -Inf, xmax = Inf, ymin = 2.675, ymax = 2.675, col = "darkblue") + 
    annotate("rect", xmin = -Inf, xmax = Inf, ymin = 3.25, ymax = 3.25, col = "black")   +
    annotate("rect", xmin = -Inf, xmax = Inf, ymin = 3.825, ymax = 3.825, col = "darkblue")   +
    annotate("rect", xmin = -Inf, xmax = Inf, ymin = 4.45, ymax = 4.45, col = "darkblue") +
  theme(legend.position="top")

ggsave("slides/trees/figure_man/tree-growing-y.png", py, units = "cm",
       width = 9.8, height = 9.8)

px <- ggplot(data = iris,
             aes(.data[["Sepal.Length"]], .data[["Sepal.Width"]],
                 color = .data[["Species"]], 
                 shape = .data[["Species"]])) +
  geom_point() + theme_bw() +
  scale_color_manual(values = c(virginica = "#0CB702", versicolor = "#00A9FF", setosa = "#FF68A1")) 


px <- px + annotate("rect", ymin = -Inf, ymax = Inf, xmin = 4.35, xmax = 4.35, col = "darkblue") +   
  annotate("rect", ymin = -Inf, ymax = Inf, xmin = 5.45, xmax = 5.45, col = "black") + 
  annotate("rect", ymin = -Inf, ymax = Inf, xmin = 6.15, xmax = 6.15, col = "darkblue")   +
  annotate("rect", ymin = -Inf, ymax = Inf, xmin = 6.95, xmax = 6.95, col = "darkblue")   +
  annotate("rect", ymin = -Inf, ymax = Inf, xmin = 7.95, xmax = 7.95, col = "darkblue") +
  theme(legend.position="top")

ggsave("slides/trees/figure_man/tree-growing-x.png", px, units = "cm",
       width = 9.8, height = 9.8)

p$plot_tree(1)

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

bs_data1 <- data.frame(Label = c(1, 2, 3), 
                       Probability = c(0.1, 0.6, 0.3), 
                       Truth = c(0, 0, 1))
bs_data1$`Brier Score` <- round((bs_data1$Probability - bs_data1$Truth)^2, 2)
bs_data2 <- data.frame(Label = c(1, 2, 3), 
                       Probability = c(0.8, 0.1, 0.1), 
                       Truth = c(1, 0, 0))
bs_data2$`Brier Score` <- round((bs_data2$Probability - bs_data2$Truth)^2, 2)
library(stargazer)
stargazer(t(bs_data1))
stargazer(t(bs_data2))

# categorical
catfeat <- data.frame(Cat = as.factor(c("A", "B", "C", "D")), freq = c(6, 8, 12, 4))
catfeat$freq  <- catfeat$freq / sum(catfeat$freq)
catplot1 <- ggplot(catfeat, aes(Cat, freq)) + 
  geom_bar(stat = "identity", fill = 2:5) +
  xlab("Category of Feature") + ylab("Rel. Frequency") + theme_bw()
catplot2 <- ggplot(catfeat, aes(reorder(Cat, freq), freq)) + 
  geom_bar(stat = "identity", fill = 2:5) +
  xlab("Category of Feature") + ylab("Rel. Frequency") + theme_bw()
catplot3 <- ggplot(catfeat, aes(reorder(Cat, freq), freq))  + 
  geom_bar(stat = "identity", fill = 2:5) +
  xlab("Category of Feature") + ylab("Rel. Frequency") +
  annotate("rect", xmin = 2.5, xmax = 2.5, ymin = -Inf, ymax = Inf, 
           linetype = "dashed", col = "black") + theme_bw()

ggsave("slides/trees/figure/categoryplot-binary1.pdf", catplot1, 
       units = "cm",
       width = 6, height = 8)
ggsave("slides/trees/figure/categoryplot-binary2.pdf", catplot2, 
       units = "cm",
       width = 6, height = 8)
ggsave("slides/trees/figure/categoryplot-binarysmall.pdf", catplot2, 
       units = "cm",
       width = 5, height = 4)
ggsave("slides/trees/figure/categoryplot-binary3.pdf", catplot3, 
       units = "cm",
       width = 6, height = 8)


# numeric
catfeat <- data.frame(Cat = as.factor(c("A", "B", "C", "D")), freq = c(6.0, 8.0, 12.0, 4.0))
catplot1 <- ggplot(catfeat, aes(Cat, freq)) + 
  geom_bar(stat = "identity", fill = 2:5) +
  xlab("Category of Feature") + ylab("Mean of outcome") + theme_bw()
catplot2 <- ggplot(catfeat, aes(reorder(Cat, freq), freq)) + 
  geom_bar(stat = "identity", fill = 2:5) +
  xlab("Category of Feature") + ylab("Mean of outcome") + theme_bw()
catplot3 <- ggplot(catfeat, aes(reorder(Cat, freq), freq)) + 
  geom_bar(stat = "identity", fill = 2:5) +
  xlab("Category of Feature") + ylab("Mean of outcome") +
  annotate("rect", xmin = 2.5, xmax = 2.5, ymin = -Inf, ymax = Inf, 
           linetype = "dashed", col = "black") + theme_bw()

ggsave("slides/trees/figure/categoryplot-cont1.pdf", catplot1, 
       units = "cm",
       width = 6, height = 8)
ggsave("slides/trees/figure/categoryplot-cont2.pdf", catplot2, 
       units = "cm",
       width = 6, height = 8)
ggsave("slides/trees/figure/categoryplot-cont3.pdf", catplot3, 
       units = "cm",
       width = 6, height = 8)

iris2 <- iris %>% filter(Species %in% c("setosa", "virginica")) %>%
  mutate(prediction = ifelse(Sepal.Length < 5.45, "setosa", "virginica"),
         Species = as.factor(as.character(Species)))

p <- plot_boundaries(iris2, Species ~ Sepal.Length + Sepal.Width, 
                     "Sepal.Length", "Sepal.Width", 
                     cols = c(virginica = "#0CB702", setosa = "#FF68A1"), 
                     maxdepth = 4, alpha = 0.2)

left_plot <- p$plot_area(1) +  theme_bw() +theme(legend.position="top") 


base <- ggplot(iris2, aes(Sepal.Length, Sepal.Width,
                 color = Species, 
                 shape = Species)) +
  geom_point() + scale_color_manual(values = c(virginica = "#0CB702", versicolor = "#00A9FF", setosa = "#FF68A1"))

possible_splits <- seq(2.3, 4.2, length.out = 8L)
flips <- rep(0, length(possible_splits))
right_plot <- base + theme_bw() + theme(legend.position="top")
for (s in 1:length(possible_splits)) {
 rgt <- names(which.max(table(iris2$Species[iris2$Sepal.Width >= possible_splits[s]])))
 lft <- names(which.max(table(iris2$Species[iris2$Sepal.Width < possible_splits[s]])))
 newprediction <- ifelse(iris2$Sepal.Width >= possible_splits[s], rgt, lft)
 flips[s] <- sum(newprediction != iris2$prediction)
 right_plot <- right_plot + annotate("rect", xmin = -Inf, xmax = Inf, col = "black",
                         ymin = possible_splits[s], ymax = possible_splits[s]) +
   annotate("text", x = 8.35, y = possible_splits[s] + 0.07, label = paste0(flips[s], " flips")) +
   xlim(c(4, 8.5)) 
}

png("slides/trees/figure/tree-binary.pdf", 
    width = 1024, height = 524, pointsize = 22)
p$plot_tree(1)
dev.off()

ggsave("slides/trees/figure/surrogate-splits.pdf", left_plot + right_plot, 
       units = "cm",
       width = 21, height = 9.5)

surrogate_tree <- rpart(prediction ~ Sepal.Width, data = iris2, maxdepth = 1L)
rpart.plot(surrogate_tree)
