 
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
library(kableExtra)
library(kknn)
library(e1071)

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))
set.seed(123)

plot_lp = function(...){
  plotLearnerPrediction(...) + scale_fill_viridis_d()
}

#logreg

pdf("../figure/reg_class_task_1.pdf", width = 6, height = 6)
plot_lp(makeLearner("classif.logreg"), sonar.task) + xlim(0,0.05) + ggtitle("Sonar")
ggsave("../figure/reg_class_task_1.pdf", width = 6, height = 6)
dev.off()

#svm

pdf("../figure/reg_class_task_2.pdf", width = 6, height = 6)
plot_lp(makeLearner("classif.svm"), iris.task, c("Petal.Length", "Petal.Width")) + ggtitle("Iris") 
ggsave("../figure/reg_class_task_2.pdf", width = 6, height = 6)
dev.off()

#
library(GGally)
pdf("../figure/reg_class_task_3.pdf", width = 8, height = 5)
ggpairs(iris, mapping = aes(col = Species))
ggsave("../figure/reg_class_task_3.pdf", width = 8, height = 5)
dev.off()
