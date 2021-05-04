betaRidge = function (X, y, lambda) 
{
  return (solve(t(X) %*% X + lambda * diag(ncol(X))) %*% (t(X) %*% y))
}

baseTrafo = function (x, degree)
{
  out = cbind(1, x)
  for (i in seq_len(degree)[-1]) {
    out = cbind(out, x^i)
  }
  # poly ist scheiﬂe
  return (out)
}

plotRidge = function (x, y, lambda.vec, base.trafo, ...)
{
  requireNamespace("ggplot2")
  
  # browser()
  
  X = base.trafo(x, ...)
  
  x.pred = seq(min(x), max(x), length.out = 500)
  X.pred = base.trafo(x.pred, ...)
  
  df.truth = data.frame(feature = x, truth = y)
  
  # browser()
  
  df.polys = lapply(lambda.vec, function (lambda) {
    beta = betaRidge(X, y, lambda)
    
    return (data.frame(
      feature = x.pred,
      pred = X.pred %*% beta,
      lambda = lambda
    ))
  })
  
  plot.df = df.polys[[1]]
  for (i in seq_along(df.polys)[-1]) {
    plot.df = rbind(plot.df, df.polys[[i]])
  }
  plot.df$lambda = as.factor(plot.df$lambda)
  
  gg = ggplot2::ggplot()
  if (length(lambda.vec) == 1) {
    gg = gg + ggplot2::geom_line(data = plot.df, aes(x = feature, y = pred, color = lambda), show.legend = FALSE)
  } else {
    gg = gg + ggplot2::geom_line(data = plot.df, aes(x = feature, y = pred, color = lambda))
  }
  
  return (
    gg +
      ggplot2::geom_point(data = df.truth, mapping = aes(x = feature, y = truth))
  )
}