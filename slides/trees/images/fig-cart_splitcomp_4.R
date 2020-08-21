setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(knitr)
library(mlbench)
library(mlr)
library(OpenML)

library(ggplot2)
library(viridis)
library(gridExtra)
library(ggrepel)
library(repr)

library(data.table)
library(BBmisc)

library(party)
library(rpart)
library(rpart.plot)
library(randomForest)
library(rattle)
library(smoof)
library(kableExtra)
library(kknn)
library(e1071)
library(rattle)

library(plyr)
library(kernlab)

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))



scale_c_d <- scale_colour_discrete <- scale_color_discrete <-
  function(...) {
    viridis::scale_color_viridis(..., end = .9, discrete = TRUE, drop = TRUE)
  }


set.seed(600000)
pdf("cart_splitcomp_4.pdf", width = 8, height = 3.5)
data = rbind(data.frame(category = "A", y = runif(30, 5, 7.5)),
             data.frame(category = "B", y = runif(15, 6, 12)),
             data.frame(category = "C", y = runif(60, 5, 20)),
             data.frame(category = "D", y = runif(45, 1, 6)))

# calculate the mean of the outcome in each category
plot.data = aggregate(y ~ category, data = data, FUN = mean)
colnames(plot.data) = c("Category", "Mean")

# plot the categories wrt the mean of the outcome in each category
p1 = ggplot(data = plot.data, aes(x = Category, y = Mean, fill = Category)) +
  geom_bar(stat = "identity")  + theme(legend.position = "none") +
  ggtitle("1)") + ylab("Mean of outcome") + xlab("Category of feature")

# sort by increasing mean of the outcome
p2.pre = ggplot(data = plot.data, aes(x = reorder(Category, Mean), y = Mean, fill = Category)) +
  geom_bar(stat = "identity")  + theme(legend.position = "none") +
  ylab("Mean of outcome") + xlab("Category of feature")
p2 = p2.pre + ggtitle("2)")

# decision tree to draw a vertical line where the spit is being made
mod = rpart::rpart(y ~., data = data)
lvls = levels(reorder(plot.data$Category, plot.data$Mean))
vline.level = 'B'
p3 = p2.pre +  geom_vline(xintercept = which(lvls == vline.level) - 0.5, col = 'red', lwd = 1, linetype = "dashed") +
  ggtitle("3)")
grid.arrange(p1, p2, p3, ncol = 3)
ggsave("cart_splitcomp_4.pdf", width = 8, height = 3.5)
dev.off()

