library(bmrm)
library(quantreg)
library(gridExtra)
library(MASS)
library(ggplot2)
library(rmutil)
set.seed(1234)

fun1 = function(x) return(.2*x) 


losses = list(
  L1 = list(fun = function(r) abs(r), distribution = qlaplace),  
  L2 = list(fun = function(r) r^2, distribution = qnorm), 
  Huber = list(fun = function(r) ifelse(r > 1 | r < -1, abs(r)-.5, .5 * r^2), distribution = qnorm),
  Eps_Insensitive_1 = list(fun = function(r) ifelse(r > 1 | r < -1, abs(r) - 1, 0)),
  Quantile_75 = list(fun = function(r) ifelse(r > 0, abs(r) * 3 / 4, abs(r) * 1 / 4)))
  

plotResiduals = function(loss) {

  design = matrix(rnorm(40000), ncol = 100, nrow = 400)
  dimnames(design) = list(rownames(design, do.NULL = FALSE, prefix = ""), colnames(design, do.NULL = FALSE, prefix = "x"))
  df = data.frame(y = fun1(seq(-2, 2, length.out = 400)) + rnorm(400), as.data.frame(design))

  lf = losses[[loss]][["fun"]]
  dist = losses[[loss]][["distribution"]]

  residuals = switch(loss, 
    "L1" = rq(y~., data = df, .5)$residuals,
    "L2" = lm(y~., data = df)$residuals,
    "Huber" = rlm(y~., data = df, scale.est = "Huber", k2 = 1, maxit = 100)$residuals,
    "epsilon" = {
      lmRes5 = nrbm(epsilonInsensitiveRegressionLoss(x = design, y = df$y, epsilon = 1))
      lmRes5 = data.frame(target = df$y, prediction = predict(lmRes5, design))
      lmRes5$target - lmRes5$w   
      }
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
ggsave("figure_man/residuals_plot_L1.pdf", p, width = 9, height = 5)

p = plotResiduals("L2")
ggsave("figure_man/residuals_plot_L2.pdf", p, width = 9, height = 5)

p = plotResiduals("Huber")
ggsave("figure_man/residuals_plot_Huber.pdf", p, width = 9, height = 5)


