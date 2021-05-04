library(e1071)

plot_lin_svm <- function(data,
                         C = 1,
                         eps = 0.01,
                         a = NULL,
                         features_names = c("x.1", "x.2"),
                         target_name = "y",
                         highlight_sv = FALSE,
                         highlight_mc = TRUE,
                         show_slack = FALSE,
                         show_distances = FALSE,
                         show_margin = TRUE,
                         show_gamma = TRUE,
                         show_points = TRUE,
                         gamma_offset = c(0, 0),
                         sw_labels = 1) {
  
  x <- as.matrix(data[, features_names])
  y <- as.numeric(as.character(data[, target_name]))
  
  if(is.null(a)){
  model <- svm(
    x = x, y = data[, target_name], kernel = "linear", scale = FALSE,
    cost = C, type = "C-classification"
  )
  a <- rep(0, length(y))
  a[model$index] <- model$coefs[,1] / y[model$index] * sw_labels
  }

  sv <-  which(a > eps)
  sv_no_slack <- which(a > eps & a < C)
  
  theta_hat <- (y[sv] * a[sv]) %*% x[sv,]
  theta_0 <- mean(1/y[sv_no_slack] - (x[sv_no_slack, ] %*% t(theta_hat)))
  
  slacks <- 1 - y[sv] * (x[sv,] %*% t(theta_hat) + theta_0)
  gamma <- 1 / sqrt(sum(theta_hat^2))

  slope <- -theta_hat[1] / theta_hat[2]
  intercept <- -theta_0 / theta_hat[2]
  intercept_diff <- gamma / cos(abs(atan(slope)))
  
  fitted <- rep(1, length(y))
  fitted[x %*% t(theta_hat) + theta_0 < 0] <- -1
  miss_cl <- which(fitted != y)

  origin <- rep(intercept / (1 - slope), 2)
  gamma_vec <- origin + theta_hat * gamma^2

  gamma_df <- as.data.frame(rbind(origin, gamma_vec))
  gamma_ann <- (origin + gamma_vec) / 2

  data$sv <- FALSE
  data$sv[sv] <- TRUE

  pl <- ggplot(data, aes_string(x = features_names[1], 
                                y = features_names[2]))
  
  if (show_margin) {
    pl <- pl + geom_abline(
      slope = slope, intercept = intercept + intercept_diff,
      linetype = "dashed"
    ) +
      geom_abline(
        slope = slope, intercept = intercept - intercept_diff,
        linetype = "dashed"
      )
  }
  
  if (show_points) {
    if (highlight_sv) {
      pl <- pl +
        geom_point(aes_string(colour = target_name,
                              alpha = "sv"), size = 3) +
        scale_alpha_manual(values = c(0.3, 1))
    } else {
      pl <- pl +
        geom_point(aes_string(colour = target_name), size = 3)
    }
  } else {
    pl <- pl +
      geom_point(aes_string(colour = target_name), size = 3, alpha = 0)
  }

  pl <- pl + coord_fixed()

  if (show_distances) {
    data$dist <- -(x %*% t(theta_hat) + theta_0)

    if (highlight_sv) {
      d_data <- data[sv, ]
    } else {
      d_data <- data
    }

    for (i in 1:nrow(d_data)) {
      tmp <- rbind(
        d_data[i, features_names],
        d_data[i, features_names] +
          theta_hat * gamma^2 * d_data$dist[i]
      )
      pl <- pl + geom_line(data = tmp, aes_string(x = features_names[1],
                                                  y = features_names[2]),
                           linetype = "dotted")
    }
  }

  if (highlight_mc) {
    pl <- pl +
      geom_point(
        data = data[miss_cl, ], aes_string(x = features_names[1],
                                           y = features_names[2]),
        shape = "cross", colour="red"
      )
  }

  pl <- pl + xlab("") + ylab("") + theme(legend.position = "none") +
    geom_abline(slope = slope, intercept = intercept)

  if (show_gamma) {
    pl <- pl + 
      geom_line(data = gamma_df, aes_string(x = features_names[1],
                                            y = features_names[2])) +
      annotate("label",
        x = gamma_ann[1] + gamma_offset[1], 
        y = gamma_ann[2] + gamma_offset[2], label = "gamma",
        parse = TRUE
      )
  }

  if (show_slack) {
    for (i in 1:length(slacks)) {
      tmp <- as.data.frame(rbind(x[sv[i], ], 
                                 x[sv[i], ] + 
                                   y[sv[i]] * theta_hat * gamma^2 * slacks[i]))
      pl <- pl + geom_line(data = tmp, aes_string(x = features_names[1],
                                                  y = features_names[2]),
                           linetype = "dotted")
    }
  }
  pl
}
