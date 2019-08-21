plotModQuadraticLoss = function (data, model, loss, pt_idx)
{

  df_plot = data.frame(x = x[pt_idx], y = y[pt_idx], y_hat = predict(model)[pt_idx])
  df_plot$resid = df_plot$y_hat - df_plot$y
  df_plot$loss  = (df_plot$y_hat - df_plot$y)^2
  df_plot$loss_label = as.character(round(df_plot$loss, 2))

  gg1 = ggplot() +
    geom_point(data = data, aes(x = x, y = y)) +
    geom_abline(intercept = coef(model)[1], slope = coef(model)[2]) +
    geom_rect(data = df_plot, aes(ymin = y_hat, ymax = y, xmin = x, xmax = x + resid), color = "black", linetype = "dotted", fill = "red", alpha = 0.2) +
    geom_segment(data = df_plot, aes(x = x, y = y, xend = x, yend = y_hat), color = "red") +
    geom_point(data = df_plot, aes(x = x, y = y), color = "red", size = 2) +
    geom_text(data = df_plot, aes(x = x + resid/2, y = y + resid/2, label = loss_label), color = "red") +
    coord_fixed() + ggtitle("Data & Model")

  gg2 = ggplot() +
    stat_function(data = data.frame(x = c(-4, 4)), mapping = aes(x), fun = function (x) {x^2}) +
    geom_point(data = df_plot, aes(x = resid, y = loss), color = "red", size = 2) +
    geom_segment(data = df_plot, mapping = aes(x = resid, y = 0, xend = resid, yend = loss), color = "red") +
    xlab(expression(Residuals == y - f(x))) + ylab(expression(L(f(x), y))) +
    geom_text(data = df_plot, mapping = aes(x = resid, y = loss, label = loss_label), color = "red", hjust = -0.5) +
    ggtitle("Loss") 

  return (gridExtra::grid.arrange(gg1, gg2, ncol = 2))
}

plotModAbsoluteLoss = function (data, model, pt_idx, add_quadratic = TRUE)
{

  df_plot = data.frame(x = x[pt_idx], y = y[pt_idx], y_hat = predict(model)[pt_idx])
  df_plot$resid = df_plot$y_hat - df_plot$y
  df_plot$loss  = abs(df_plot$y_hat - df_plot$y)
  df_plot$loss_label = as.character(round(df_plot$loss, 2))
  df_plot$loss_qu = (df_plot$y_hat - df_plot$y)^2
  df_plot$loss_label_qu = as.character(round(df_plot$loss_qu, 2))

  gg1 = ggplot() +
    geom_point(data = data, aes(x = x, y = y)) +
    geom_abline(intercept = coef(model)[1], slope = coef(model)[2]) +
    geom_segment(data = df_plot, aes(x = x, y = y, xend = x, yend = y_hat), color = "red") +
    geom_point(data = df_plot, aes(x = x, y = y), color = "red", size = 2) +
    geom_text(data = df_plot, aes(x = x, y = y + resid/2, label = loss_label), color = "red", hjust = -0.5) +
    coord_fixed() + ggtitle("Data & Model") + xlim(-1.8, 5)

  gg2 = ggplot() +
    stat_function(data = data.frame(x = c(-4, 4)), mapping = aes(x), fun = function (x) {abs(x)}) +
    geom_point(data = df_plot, aes(x = resid, y = loss), color = "red", size = 2) +
    geom_segment(data = df_plot, mapping = aes(x = resid, y = 0, xend = resid, yend = loss), color = "red") +
    xlab(expression(Residuals == y - f(x))) + ylab(expression(L(f(x), y))) +
    geom_text(data = df_plot, mapping = aes(x = resid, y = loss, label = loss_label), color = "red", hjust = -0.5) +
    ggtitle("Loss") + ylim(c(0, 16))
  
  if (add_quadratic) {
    gg2 = gg2 +
      stat_function(data = data.frame(x = c(-4, 4)), mapping = aes(x), fun = function (x) {x^2}, alpha = 0.4) +
      geom_point(data = df_plot, aes(x = resid + 0.1, y = loss_qu), color = "red", size = 2, alpha = 0.4) +
      geom_segment(data = df_plot, mapping = aes(x = resid + 0.1, y = 0, xend = resid + 0.1, yend = loss_qu), color = "red", alpha = 0.4) +
      geom_text(data = df_plot, mapping = aes(x = resid + 0.1, y = loss_qu, label = loss_label_qu), color = "red", hjust = -0.5, alpha = 0.4)
  }
  return (gridExtra::grid.arrange(gg1, gg2, ncol = 2))
}

plotModAbsLogQuadLoss = function (data, model, pt_idx, add_quadratic_abs = TRUE)
{

  df_plot = data.frame(x = x[pt_idx], y = y[pt_idx], y_hat = predict(model)[pt_idx])
  df_plot$resid = df_plot$y_hat - df_plot$y
  df_plot$loss  = log(abs(df_plot$y_hat - df_plot$y) + 1)^2
  df_plot$loss_label = as.character(round(df_plot$loss, 2))
  df_plot$loss_abs  = abs(df_plot$y_hat - df_plot$y)
  df_plot$loss_label_abs = as.character(round(df_plot$loss_abs, 2))  
  df_plot$loss_qu = (df_plot$y_hat - df_plot$y)^2
  df_plot$loss_label_qu = as.character(round(df_plot$loss_qu, 2))

  gg1 = ggplot() +
    geom_point(data = data, aes(x = x, y = y)) +
    geom_abline(intercept = coef(model)[1], slope = coef(model)[2]) +
    geom_segment(data = df_plot, aes(x = x, y = y_hat, xend = x, yend = y_hat + sign(y - y_hat) * loss), color = "red") +
    geom_point(data = df_plot, aes(x = x, y = y), color = "red", size = 2) +
    geom_text(data = df_plot, aes(x = x, y = y_hat + sign(y - y_hat) * loss / 2, label = loss_label), color = "red", hjust = -0.5)
    coord_fixed()

  gg2 = ggplot() +
    stat_function(data = data.frame(x = c(-4, 4)), mapping = aes(x), fun = function (x) {log(abs(x) + 1)^2}) +
    geom_point(data = df_plot, aes(x = resid, y = loss), color = "red", size = 2) +
    geom_segment(data = df_plot, mapping = aes(x = resid, y = 0, xend = resid, yend = loss), color = "red") +
    xlab(expression(Residuals == y - f(x))) + ylab(expression(L(f(x), y))) +
    geom_text(data = df_plot, mapping = aes(x = resid, y = loss, label = loss_label), color = "red", hjust = -0.5)

  if (add_quadratic_abs) {
    gg2 = gg2 +
      stat_function(data = data.frame(x = c(-4, 4)), mapping = aes(x), fun = function (x) {abs(x)}, alpha = 0.4) +
      geom_point(data = df_plot, aes(x = resid - 0.1, y = loss_abs), color = "red", size = 2, alpha = 0.4) +
      geom_segment(data = df_plot, mapping = aes(x = resid - 0.1, y = 0, xend = resid - 0.1, yend = loss_abs), color = "red", alpha = 0.4) +
      geom_text(data = df_plot, mapping = aes(x = resid - 0.1, y = loss_abs, label = loss_label_abs), color = "red", hjust = -0.5, alpha = 0.4) +
      stat_function(data = data.frame(x = c(-4, 4)), mapping = aes(x), fun = function (x) {x^2}, alpha = 0.4) +
      geom_point(data = df_plot, aes(x = resid + 0.1, y = loss_qu), color = "red", size = 2, alpha = 0.4) +
      geom_segment(data = df_plot, mapping = aes(x = resid + 0.1, y = 0, xend = resid + 0.1, yend = loss_qu), color = "red", alpha = 0.4) +
      geom_text(data = df_plot, mapping = aes(x = resid + 0.1, y = loss_qu, label = loss_label_qu), color = "red", hjust = -0.5, alpha = 0.4)
  }
  return (gridExtra::grid.arrange(gg1, gg2, ncol = 2))
}
