# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(randomForest)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

set.seed(600000)
model = randomForest(Species ~ ., data = iris, importance = TRUE)

# PLOT -------------------------------------------------------------------------

pdf("../figure/cart_forest_fimp_1.pdf", width = 8, height = 2.8)

randomForest::varImpPlot(model, main = "")

ggsave("../figure/cart_forest_fimp_1.pdf", width = 8, height = 2.8)
dev.off()
