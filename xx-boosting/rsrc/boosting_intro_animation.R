plotLineaBoosting = function (x, y, nboost, learning_rate, basis_fun = function (x) cbind(1, x))
{
  X = basis_fun(x)

  overall_pred = rep(mean(y), length(y))
  pseudo_resids = y
  coefs = matrix(0, nrow = nboost, ncol = ncol(X))
  ylim = c(min(y) - mean(y), max(y))

  for (i in seq_len(nboost)) {

    if (i == nboost) {
      layout_matrix = matrix(c(1, 1, 2, 3, 4, 4), byrow = TRUE, nrow = 3)
      layout(layout_matrix)

      par(mar = c(0, 0, 0, 0))
      plot(x = NA, y = NA, xlim = c(0, 1), ylim = c(0, 1), xlab = "", ylab = "", axes = FALSE)
      igraph:::igraph.Arrows(0.9, 0.1, 0.1, 0.1, h.lwd=2, sh.lwd=4, sh.col="dark red",
        curve=-2, width=1, size=0.7)
      text(x = 0.5, y = 0.8, labels = paste0("Add ", learning_rate, " x model"), col = "dark red", cex = 1.8)

      par(mar = c(5, 5, 0, 2))
      plot(x = x, y = y, ylim = ylim, xlab = "Feature x", ylab = "Target y")
      grid()
      segments(x0 = x, y0 = y, x1 = x, y1 = overall_pred, lty = 2, col = "dark red")

      # Add earlier models:
      if (i > 1) {
        lines(x = x, y = rep(mean(y), length(y)), col = rgb(0.5, 0, 0, 0.4))
        ccoefs = apply(coefs[seq_len(i), ], 2, cumsum)
        alphas = seq(0.4, 0.8, length.out = nrow(ccoefs))
        for (j in seq_along(alphas)) {
          lines(x = x, y = mean(y) + X %*% ccoefs[j,], col = rgb(0.7, 0, 0, alphas[j]))
        }
      }
      lines(x = x, y = overall_pred, col = "red", lwd = 2)
    }
    # Update step:
    pseudo_resids = y - overall_pred
    coefs[i,] = learning_rate * solve(t(X) %*% X) %*% t(X) %*% pseudo_resids

    # browser()

    blearner_pred = X %*% coefs[i,]
    overall_pred = overall_pred + blearner_pred

    if (i == nboost) {
      par(mar = c(5, 5, 0, 2))
      plot(x = x, y = pseudo_resids, ylim = ylim, col = "dark red", pch = 3, xlab = "Feature x",
        ylab = "Residuals of current model")
      grid()
      lines(x = x, y = blearner_pred / learning_rate, col = "dark blue", lwd = 2)

      par(mar = c(0, 0, 0, 0))
      plot(x = NA, y = NA, xlim = c(0, 1), ylim = c(0, 1), xlab = "", ylab = "", axes = FALSE)
      igraph:::igraph.Arrows(0.1, 0.9, 0.9, 0.9, h.lwd=2, sh.lwd=4, sh.col="dark red",
        curve=-2, width=1, size=0.7)
      text(x = 0.5, y = 0.2, labels = "Calculate the residuals of the current model", col = "dark red", cex = 1.8)

      par(mfrow = c(1,1))
    }
  }
}
