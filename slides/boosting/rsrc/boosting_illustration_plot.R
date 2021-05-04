plotBoostingIllustration = function (x, y, nboost, learning_rate, basis_fun = function (x) cbind(1, x), plot_frames = NULL) {
  X = basis_fun(x)

  overall_pred = rep(mean(y), length(y))
  pseudo_resids = y
  coefs = matrix(0, nrow = nboost, ncol = ncol(X))
  ylim = c(min(y) - mean(y), max(y))

  for (i in seq_len(nboost)) {

    if (i == nboost) {
      par(mar = c(5, 5, 0, 2))
      plot(x = x, y = y, ylim = ylim, xlab = "Feature x", ylab = "Target y")
      grid()

      # Add earlier models:
      segments(x0 = x, y0 = y, x1 = x, y1 = overall_pred, lty = 2, col = "#143938")
      ccoefs = apply(coefs[seq_len(i), ], 2, cumsum)
      alphas = seq(0.4, 0.8, length.out = nrow(ccoefs))

      if (is.null(plot_frames[1]))
        plot_frames = 1:nboost

      for (j in plot_frames) {
        x_arrows = seq(min(x), max(x), length.out = 25)
        y_arrows_start = mean(y) + basis_fun(x_arrows) %*% ccoefs[j,]
        y_arrows_end = mean(y) + basis_fun(x_arrows) %*% as.numeric(tail(ccoefs, 1))
        arrow_range = y_arrows_end - y_arrows_start
        arrows(x0 = x_arrows[-c(1, length(x_arrows))],
          y0 = y_arrows_start[-c(1, length(x_arrows))] + 0.2 * arrow_range,
          x1 = x_arrows[-c(1, length(x_arrows))],
          y1 = y_arrows_end[-c(1, length(x_arrows))] - 0.2 * arrow_range,
          length = 0.1,
          col = "#e3753a",
          lwd = 2
        )

        lines(x = x, y = mean(y) + X %*% ccoefs[j,], col = "#b3cdce", lwd = 2)
        lines(x = x, y = overall_pred, col = "#418063", lwd = 2)

        legend(0, -0.5,
          c(
            expression(paste(
              "f", phantom()^{
                paste(" ", bgroup("[", paste("m-1"), "]"))
              })
            ),
            expression(paste(frac(paste(partialdiff, "L"), paste("", partialdiff, "f", "(", "x",
              phantom()^{paste("i")}, ")")))),
            expression(paste(
              "", "f", phantom()^{
                paste(" ", bgroup("[", paste("m"), "]"))
              })
            )
          ),
          lty = c(1, NA, 1),
          lwd = c(2, 2, 2),
          col = c("#b3cdce", "#e3753a", "#418063")
        )

        arrows(x0 = 0.5, y0 = -1.06 , x1 = 1.4, y1 = -1.06, length = 0.1, col = "#e3753a", lwd = 2)
      }
    }

    # Update step:
    pseudo_resids = y - overall_pred
    coefs[i,] = learning_rate * solve(t(X) %*% X) %*% t(X) %*% pseudo_resids

    blearner_pred = X %*% coefs[i,]
    overall_pred = overall_pred + blearner_pred
  }
}

bTrafo = function (x) {
  margin = 0.1 * (max(x) - min(x))
  splines::splineDesign(knots = seq(min(x) - margin, max(x) + margin,
    length.out = 10), x = x, outer.ok = TRUE)
}


plotBoostingIllustrationClassif = function(n = 10, mstop = 1L, seed = 121) {
  set.seed(seed)

  x1 = c(rnorm(n / 2, 3, 0.4), rnorm(n, 3.5, 0.4), rnorm(n / 2, 3, 0.4))
  x2 = c(rnorm(n / 2, 1, 0.6), rnorm(n, 2, 1), rnorm(n / 2, 3, 0.6))
  y = as.factor(rep(c(1,0, 1), times = c(n/2, n, n/2)))

  data = data.frame(x1 = x1, x2 = x2, y = y)
  plot(x1, x2, pch = as.numeric(y), col = y)

  require(mlr)
  lrn = makeLearner("classif.gamboost", mstop = mstop)
  task = makeClassifTask("classif.task", data, target = "y")
  plotLearnerPrediction(lrn, task)

}

# plotBoostingIllustrationClassif(10, 10, seed = 121)
