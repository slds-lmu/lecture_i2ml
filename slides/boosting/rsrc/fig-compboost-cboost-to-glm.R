# ------------------------------------------------------------------------------
# FIG: COMPBOOST BASELEARNER
# ------------------------------------------------------------------------------

# Purpose: visualize base learners

if (FALSE) {
  devtools::install_github("schalkdaniel/compboost", ref = "dev")
  install.packages("AmesHousing")
}

# DATA -------------------------------------------------------------------------

# Get data

dat = AmesHousing::make_ames()

cols_keep = c("Sale_Price", "Longitude", "Latitude", "Overall_Qual", "Year_Built", "Fireplaces",
  "Year_Sold", "Garage_Area", "Kitchen_Qual", "Pool_Area")

dat = dat[, cols_keep]

# TRAINING ---------------------------------------------------------------------

library(compboost)

# Train for a very long time to show convergence against GLM:
n_iters = 10000L

# Only linear base learners

set.seed(1L)
cwb_linear_bl = compboost::boostLinear(
  data = dat,
  learning_rate = 0.01,
  target = "Sale_Price",
  loss = compboost::LossQuadratic$new(),
  intercept = TRUE,
  iterations = n_iters,
  optimizer = OptimizerCoordinateDescent$new(parallel::detectCores() - 1L))

mod_lm = lm(Sale_Price ~ ., data = dat)

# PLOTS ------------------------------------------------------------------------

# Get traces of parameter values for linear base learners (slope only) and
# aggregate all intercepts.

iters = as.integer(seq(from = 1, to = n_iters, len = 200L))

extractPars = function(cboost, cwb_pars) {

  cpnames = names(cwb_pars)
  cppars  = numeric()
  int     = 0

  for (i in seq_along(cpnames)) {
    if (grepl("linear", cpnames[i])) {
      int = int + cwb_pars[[i]][1]
      cpnew = cwb_pars[[i]][2]
      names(cpnew) = gsub("_linear", "", cpnames[i], perl = TRUE)
      cppars = c(cppars, cpnew)
    }
    if (grepl("ridge", cpnames[i])) {
      fname = cboost$baselearner_list[[cpnames[i]]]$feature
      dict  = sort(cboost$baselearner_list[[cpnames[i]]]$factory$getDictionary())

      ref_cat = levels(dat[[fname]])[1]
      idx_ref_cat = dict[ref_cat] + 1

      int = int + cwb_pars[[i]][idx_ref_cat]
      cpnew = cwb_pars[[i]][-idx_ref_cat] - cwb_pars[[i]][idx_ref_cat]

      names(cpnew) = paste0(gsub("_ridge", "", cpnames[i], perl = TRUE), names(dict)[-idx_ref_cat])
      cppars = c(cppars, cpnew)
    }
  }
  return(c(Intercept = int, cppars))
}

params = lapply(iters, function(i) {
  out = extractPars(cwb_linear_bl, cwb_linear_bl$model$getParameterAtIteration(i))
  return(c(iteration = i, out))
})

params_all  = data.table::as.data.table(do.call(dplyr::bind_rows, params))
params_long = data.table::melt(params_all, id = "iteration")
params_long[, value := ifelse(is.na(value), 0L, value)]

# Plot development of slopes over time

cf_lm = coef(mod_lm)
names(cf_lm)[names(cf_lm) == "(Intercept)"] = "Intercept"
pars_lm = data.frame(variable = names(cf_lm), value = unname(cf_lm), iter = n_iters)

#df_tmp = params[[length(params)]][-1]
#df_tmp = data.frame(variable = names(df_tmp), value = df_tmp)
#merge(x = pars_lm[,-3], y = df_tmp, by = "variable")

iter_snapshots = c(250, 500, 1000, 5000, 10000)

lapply(iter_snapshots, function(i) {
  i0 = max(params_long$iteration[params_long$iteration <= i])
  gg = ggplot2::ggplot() +
    ggplot2::geom_point(data = dplyr::filter(pars_lm, variable != "Intercept"),
      ggplot2::aes(x = i0, y = value, col = variable), shape = 4) +
    ggplot2::geom_line(data = dplyr::filter(dplyr::filter(params_long, variable != "Intercept"), iteration <= i),
      ggplot2::aes(x = iteration, y = value, col = variable)) +
    ggplot2::theme_minimal() +
    ggplot2::xlab("m") +
    ggplot2::ylab("Parameter Value") +
    ggplot2::xlim(1, max(iter_snapshots)) +
    ggplot2::theme(legend.key.size = ggplot2::unit(0, "lines")) +
    ggplot2::ggtitle(paste0("Parameter after ", i, " Iterations"))

  ggplot2::ggsave(here::here(paste0("slides/boosting/figure/compboost-to-glm-iter", i , ".png")), gg, height = 3, width = 7L)
  invisible(NULL)
})




if (FALSE) {

# Mark number of selected base learners for 2 different iterations

markers <- c(30L, 90L)

p_2 <- p_1 +
  ggplot2::geom_vline(xintercept = markers[1L], linetype = "dashed") +
  ggplot2::ggtitle(sprintf(
    "mstop = %i: %i base learners selected",
    markers[1L],
    sum(slopes_long[iteration == markers[1L]]$value != 0)))

p_3 <- p_1 +
  ggplot2::geom_vline(xintercept = markers[2L], linetype = "dashed") +
  ggplot2::ggtitle(sprintf(
    "mstop = %i: %i base learners selected",
    markers[2L],
    sum(slopes_long[iteration == markers[2L]]$value != 0)))

p_4 <- ggpubr::ggarrange(
  p_2, p_3, ncol = 1L, common.legend = TRUE, legend = "right")

# ------------------------------------------------------------------------------

cwb_flexible_selected <-
  names(cwb_flexible_bl$model$getParameterAtIteration(n_iters))

pdp <- lapply(
  cwb_flexible_selected,
  function(i) {
    steps <- seq(0L, n_iters, by = 10L)
    cwb_flexible_bl$plot(i, iters = steps) +
      ggplot2::theme_minimal() +
      ggplot2::scale_color_viridis_d(
        end = 0.9, direction = -1L, labels = steps) +
      ggplot2::labs(
        subtitle = "",
        title = i,
        y = "")})

p_5 <- do.call(
  ggpubr::ggarrange,
  args = list(
    plotlist = pdp,
    common.legend = TRUE,
    legend = "right"))

# ------------------------------------------------------------------------------

ggplot2::ggsave(
  "../figure/compboost-illustration-1.png", p_1, height = 2.2, width = 7L)
ggplot2::ggsave(
  "../figure/compboost-illustration-2.png", p_4, height = 4L, width = 8L)
ggplot2::ggsave(
                "../figure/compboost-illustration-3.png", p_5, height = 4.5, width = 10L)
}
