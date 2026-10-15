library(mlbench)
library(kernlab)
library(ggplot2)

set.seed(9)

data = mlbench.twonorm(n = 50, d = 2)
data = as.data.frame(data)
X = as.matrix(data[, 1:2])
y = data$classes

colnames(data) <- c("x.1", "x.2", "Y")

mod_logreg = glm(Y ~ ., data = data, family = binomial())

classif_plot <- ggplot(aes(x = x.1, y = x.2, group = Y), data = data) + 
  geom_point(size = 6, aes(shape = Y, color = Y)) +
  geom_abline(intercept = - coef(mod_logreg)[1] / coef(mod_logreg)[2],
              slope = - coef(mod_logreg)[2] / coef(mod_logreg)[3],
              color = "black", lwd = 1) +
  xlab("x1") + ylab("x2") +
  scale_color_discrete(labels = c("0", "1")) +
  scale_shape_discrete(labels = c("0", "1")) +
  theme(axis.text = element_text(size = 18),
        axis.title = element_text(size = 30, face = "bold"), 
        legend.key.size = unit(2, 'cm'),
        legend.title = element_text(size = 25, face = "bold"),
        legend.text = element_text(size = 18),
        legend.title.align = 0.3)

hyp_classif <- classif_plot +
  geom_abline(intercept = 0,
              slope = -2, color = "darkgrey",
              lwd = 0.5, alpha = 0.8) +
  geom_abline(intercept = -0.2,
              slope = -1, color = "darkgrey",
              lwd = 0.5, alpha = 0.8) +
  geom_abline(intercept = -0.1,
              slope = -0.6, color = "darkgrey",
              lwd = 0.5, alpha = 0.8) +
  geom_abline(intercept = -0.3,
              slope = -0.5, color = "darkgrey",
              lwd = 0.5, alpha = 0.8)
hyp_classif
ggsave(filename = "../figure/nutshell-ml-basics-hypothesisspace-classif.png", 
       plot = hyp_classif, width = 16, height = 11, units = "in")
