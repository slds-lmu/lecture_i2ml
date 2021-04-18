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

# cauchy = function(res, c = 2) {
# 
#   res2 = (res / c)^2 
# 
#   return(2 * res2 / (res2 + 4))
# }

# Confirmed with Bernd: use def from https://www.user.tu-berlin.de/mtoussai/teaching/15-MachineLearning/15-MachineLearning-script.pdf, p. 24

cauchy = function(res, c = 2) {
  
  0.5 * c^2 * log((res / c)^2 + 1L)
  
}

# Confirmed with Bernd: use def from https://heartbeat.fritz.ai/5-regression-loss-functions-all-machine-learners-should-know-4fb140e9d4b0

logcosh <- function(res) log(cosh(res))


plotLoss = function(df, losses) {

	dfp = do.call(cbind, lapply(losses, function(loss) loss(df$res)))
	colnames(dfp) = names(losses)

	dfp = cbind(dfp, df)

	dfm = melt(dfp, id.vars = c("res"))
	names(dfm) = c("res", "loss", "value")

	p = ggplot()
	p = p + geom_point(data = dfm, aes(x = res, y = value, color = loss), size = 0.1)
	p = p + scale_x_continuous(name = expression(y - f(x)))
	p = p + scale_y_continuous(name = expression(L(y,f(x))))
	p = p + guides(colour = guide_legend(override.aes = list(size=3)))
	p = p + theme(plot.title = element_blank())

	return(p)
}


