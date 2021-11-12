library(bmrm)
library(quantreg)
library(gridExtra)
library(MASS)
library(ggplot2)
library(rmutil)
library(jmuOutlier)
set.seed(1111)
fun1 = function(x) return(.2*x) 


losses = list(
  L1 = list(fun = function(r) abs(r), distribution = qlaplace, sample = rlaplace),  
  L2 = list(fun = function(r) r^2, distribution = qnorm, sample = rnorm), 
  Huber_Gaussian = list(fun = function(r) ifelse(r > 1 | r < -1, abs(r)-.5, .5 * r^2), distribution = qnorm, sample = rnorm),
  Huber_L1 = list(fun = function(r) ifelse(r > 1 | r < -1, abs(r)-.5, .5 * r^2), distribution = qlaplace, sample = rlaplace)
)
  

plotResiduals = function(loss) {

  design = matrix(rnorm(40000), ncol = 100, nrow = 400)
  dimnames(design) = list(rownames(design, do.NULL = FALSE, prefix = ""), colnames(design, do.NULL = FALSE, prefix = "x"))

  lf = losses[[loss]][["fun"]]
  dist = losses[[loss]][["distribution"]]
  sample = losses[[loss]][["sample"]]

  df = data.frame(y = fun1(seq(-2, 2, length.out = 400)) + sample(400), as.data.frame(design))


  residuals = switch(loss, 
    "L1" = rq(y~., data = df, .5)$residuals,
    "L2" = lm(y~., data = df)$residuals,
    "Huber_Gaussian" = rlm(y~., data = df, scale.est = "Huber", k2 = 1, maxit = 100)$residuals,
    "Huber_L1" = rlm(y~., data = df, scale.est = "Huber", k2 = 1, maxit = 100)$residuals
    )

  df = cbind(df, residuals)

  p1 = ggplot(data = df, aes(x = residuals)) + geom_histogram() + theme_bw()
  p1 = p1 + stat_function(fun = lf, colour = "blue") + xlim(c(-5, 5)) + ggtitle("Distribution of Residuals")

  if (!is.null(dist)) {
    p2 =  ggplot(df, aes(sample = residuals)) + theme_bw()
    p2 = p2 + stat_qq(distribution = dist) + stat_qq_line(distribution = dist) + ggtitle("Residuals vs. Quantiles of Error Distribution")
    return(grid.arrange(p1, p2, nrow = 1))
  } else {
    return(p1)
  }
}

p = plotResiduals("L1")
ggsave("../figure/residuals_plot_L1.pdf", p, width = 8, height = 4)
# Title figures 
ggsave("../figure/residuals_plot_L1_title.png", grid::grid.draw(p$grobs[[1]]) , width = 4, height = 3)

p = plotResiduals("L2")
ggsave("../figure/residuals_plot_L2.pdf", p, width = 8, height = 4)
# Title figures 
ggsave("../figure/residuals_plot_L2_title.png", grid::grid.draw(p$grobs[[1]]) , width = 4, height = 3)

p = plotResiduals("Huber_Gaussian")
ggsave("../figure/residuals_plot_Huber_Gaussian.pdf", p, width = 8, height = 4)

p = plotResiduals("Huber_L1")
ggsave("../figure/residuals_plot_Huber_L1.pdf", p, width = 8, height = 4)

ggsave("../figure/residuals_plot_L2_title.png", grid::grid.draw(p$grobs[[1]]) , width = 4, height = 3)

