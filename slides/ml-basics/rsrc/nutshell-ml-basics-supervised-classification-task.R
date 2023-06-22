library(mlbench)
library(kernlab)
#
data = mlbench.twonorm(n = 50, d = 2)
data = as.data.frame(data)
X = as.matrix(data[, 1:2])
y = data$classes

colnames(data) <- c("x.1", "x.2", "Y")

mod_logreg = glm(Y ~ ., data = data, family = binomial())

classif_plot <- ggplot(aes(x = x.1, y = x.2, group = Y), data = data) + 
  geom_point(size = 6, aes(shape=Y, color = Y)) +
  geom_abline(intercept = - coef(mod_logreg)[1] / coef(mod_logreg)[2],
              slope = - coef(mod_logreg)[2] / coef(mod_logreg)[3], color = "black",
              lwd = 1) + labs() +   xlab("x1") + ylab("x2") +
  theme(axis.text=element_text(size=18),axis.title=element_text(size=30,face="bold"), 
        legend.key.size = unit(2, 'cm'), legend.title = element_text(size=25, face = "bold"),
        legend.text = element_text(size=18), legend.title.align=0.3)

ggsave(filename = "figure/nutshell-ml-basics-supervised-classification-task.png", 
       plot = classif_plot , width = 16, height = 11, units = "in")