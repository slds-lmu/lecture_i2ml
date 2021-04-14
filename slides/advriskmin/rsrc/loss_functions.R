# Visualization of all loss functions


library(qrmix)
library(qrmix)
library(quantreg)
library(quantreg)
library(hqreg)
library(bmrm)
library(MASS)


# --- Losses

quant = function(res, q = 0.25){ # res = y - f(x)
  if (res < 0) {
    (1 - q) * (- res)
  } else {
    q*res
  }
}
quant = Vectorize(quant)

L1 = function(res) {
	abs(res)
}

L2 = function(res) {
	(res)^2
}


epsinsensitive = function(res, eps) {
	ifelse(abs(res) > eps, abs(res) - 2, 0)
}


huber = function(res, delta = 0.5) {
  if (abs(res) <= delta) {
    0.5 * (res^2)
  } else {
    delta* abs(res) - 0.5 * (delta^2)
  }
}

log_barrier = function(res, a = 2) {

  res2 = abs(res) 
  res2[res2 > a] = Inf
  res2[res2 <= a] = - a^2 * log(1 - (abs(res2[res2 <= a]) / a)^2)

  return(res2)
}





plotLoss = function(df, losses) {

	dfp = do.call(cbind, lapply(losses, function(loss) loss(df$res)))
	colnames(dfp) = names(losses)

	dfp = cbind(dfp, df)

	dfm = melt(dfp, id.vars = c("res"))
	names(dfm) = c("res", "loss", "value")

	p = ggplot()
	p = p + geom_point(data = dfm, aes(x = res, y = value, color = loss), size = 0.1)
	p = p + scale_x_continuous(name = expression(y - f(x)))
	p = p + scale_y_continuous(name = expression(L(y - f(x))))
	p = p + guides(colour = guide_legend(override.aes = list(size=3)))
	p = p + theme(legend.title = element_blank(), plot.title = element_blank())

	return(p)
}


