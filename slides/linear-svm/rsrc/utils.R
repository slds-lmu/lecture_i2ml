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
  pl + viridis::scale_color_viridis(end=0.9, discrete = TRUE)
}

#################################################################################

################################################################################
# FIGURE: 0-1 LOSS & HINGE LOSS
################################################################################

# Lisa Wimmer

# PREREQ -----------------------------------------------------------------------

library(ggplot2)

# LOSS FUNCTIONS ---------------------------------------------------------------

zero_one_loss <- function(f) {ifelse(f < 0, 1, 0)}

hinge_loss <- function(f) {sapply(f, FUN = function(x) max(0, 1 - x))}

squared_hinge_loss <- function(f) {
  sapply(f, FUN = function(x) (max(0, 1 - x))^2)}

huber_loss <- function(f) {
  ifelse(f <= 1, ifelse(f <= 0, 1 - 2*f, (1 - f)^2), 0)}

log_loss <- function(f) log(1 + exp(-f)) / log(2)

# PLOTS ------------------------------------------------------------------------

#' @param x Vector of values to calculate losses for
#' @param include Which losses to show

plot_losses <- function(include = c("01", "hinge", "sqhinge", "huber", "log")) {
  x <- seq(-2, 1.5, length.out = 10000)
  cols <- c("01" = "#067B7F", hinge="#66CC00", sqhinge="#000099", huber="#6B007B", log = "220000")

  p <- ggplot(data.frame(x), aes(x = x))
  p <- p + labs(x = expression(paste(italic(y), italic(f))),
                y = expression(paste(italic(L), "(", italic(y), ",", italic(f),")")))

  if ("01" %in% include) {
    # Split 0-1 loss to avoid lopsided line at x = 0
    p <- p + stat_function(fun = "zero_one_loss", aes(col = "0-1"),
                           xlim = c(-2, -0.001), size = 1.5)
    p <- p + stat_function(fun = "zero_one_loss", aes(col = "0-1"),
                           xlim = c(0.001, 1.5), size = 1.5)
    p <- p + geom_segment(aes(x = 0, xend = 0, y = 0, yend = 1),
                          size = 1.5, col = cols["01"])
  }
  if ("hinge" %in% include)
    p <- p + stat_function(fun = "hinge_loss", aes(col = "hinge"), size = 1)
  if ("sqhinge" %in% include)
      p <- p + stat_function(fun = "squared_hinge_loss", aes(col = "sq. hinge"), size = 1)
  if ("huber" %in% include)
      p <- p + stat_function(fun = "huber_loss", aes(col = "huber"), size = 1)
  if ("log" %in% include)
      p <- p + stat_function(fun = "log_loss", aes(col = "log"), size = 1)

  # Axes
  p <- p + geom_hline(yintercept = 0)
  p <- p + geom_vline(xintercept = 0)
  p <- p + scale_y_continuous(limits = c(0, 3))

  # Legend
  p <- p + scale_color_manual("Losses", values = unname(cols[include]))
  p <- p + theme(legend.position = "right")
  p <- p + guides(col = guide_legend(nrow = 5, byrow = TRUE))
  return(p)
}

# p = plot_losses(c("01", "hinge", "sqhinge", "huber", "log"))
# print(p)
