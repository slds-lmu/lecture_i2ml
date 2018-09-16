set.seed(123)

# prediction with f, based on vec x and param vec beta
f = function(x, beta) {
  crossprod(x, beta)
}

# L1 and L2 loss, based on design mat X, vec, param vec beta, computed with f
loss1 = function(X, y, beta) {
  yhat = apply(X, 1, f, beta = beta)
  sum((y - yhat)^2)
}
loss2 = function(X, y, beta) {
  yhat = apply(X, 1, f, beta = beta)
  sum(abs(y - yhat))
}

# optimize loss (1 or 2) with optim
# yes, neldermead not really the best, who cares it is 1d
optLoss = function(X, y, loss) {
  start = rep(0, ncol(X))
  res = optim(start, loss, method = "Nelder-Mead", X = X, y = y)
  res$par
}

# plot data and a couple of linear models
plotIt = function(X, y, models, remove_outlier = NA, highlight_outlier = NA) {
  if (is.na(remove_outlier[1])) {
    gd = as.data.frame(cbind(X[, 2, drop = FALSE],  y = y))
  } else {
    gd = as.data.frame(cbind(X[-remove_outlier, 2, drop = FALSE],  y = y[-remove_outlier])) 
  }
  pl = ggplot() + 
    geom_point(data = gd, aes(x = x1, y = y)) + 
    geom_abline(data = models, aes(intercept = intercept, slope = slope, color = Loss))

  if (! is.na(highlight_outlier[1])) { 
    pl = pl + geom_point(data = gd[highlight_outlier, ], aes(x = x1, y = y), col = "red", size = 2) +
      geom_point(data = gd[highlight_outlier, ], aes(x = x1, y = y), col = "red", shape = 1, size = 4)
  }
  # for (i in seq_along(models)) {
  #   m = models[[i]]
  #   pl = pl + geom_abline(intercept = m$beta[1], slope = m$beta[2], col = m$col, lty = m$lty)
  # }
  return(pl)
}
