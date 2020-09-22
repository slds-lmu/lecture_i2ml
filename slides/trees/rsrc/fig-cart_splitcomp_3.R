 
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
pdf("../figure/cart_splitcomp_3.pdf", width = 8, height = 3.4)
# generate data (one categorcal variable with 4 categories, 0-1 response)
data = data.frame(category = sample(c("A", "B", "C", "D"), size = 150,
                                    replace = TRUE, prob = c(0.2, 0.1, 0.4, 0.3)),
                  y = sample(c(0,1), size = 150, replace = TRUE, prob = c(0.3, 0.7)))

# calculates proportion of 1-outcomes and plot
subset.data = subset(data, y == 1)
plot.data = data.frame(prop.table(table(subset.data$category)))
colnames(plot.data) = c("Category", "Frequency")
p1 = ggplot(data = plot.data, aes(x = Category, y = Frequency, fill = Category)) +
  geom_bar(stat = "identity")  + theme(legend.position = "none") +
  ggtitle("1)") + ylab("Frequency of class 1") + xlab("Category of feature")

# sort by proportions
p2.pre = ggplot(data = plot.data, aes(x = reorder(Category, Frequency), y = Frequency, fill = Category)) +
  geom_bar(stat = "identity")  + theme(legend.position = "none") +
  ylab("Frequency of class 1") + xlab("Category of feature")
p2 = p2.pre + ggtitle("2)")


# decision tree to draw a vertical line where the spit is being made
mod = rpart::rpart(y ~., data = data)
lvls = levels(reorder(plot.data$Category, plot.data$Frequency))
vline.level = 'C'
p3 = p2.pre +  geom_vline(xintercept = which(lvls == vline.level) - 0.5, col = 'red', lwd = 1, linetype = "dashed") +
  ggtitle("3)")
grid.arrange(p1, p2, p3, ncol = 3)
ggsave("../figure/cart_splitcomp_3.pdf", width = 8, height = 3.4)
dev.off()

