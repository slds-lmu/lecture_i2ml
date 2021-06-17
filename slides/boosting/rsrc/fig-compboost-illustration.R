# ------------------------------------------------------------------------------
# FIG: COMPBOOST ILLUSTRATION
# ------------------------------------------------------------------------------

# Purpose: visualize base learner selection in compboost for titanic example

if (FALSE) devtools::install_github("schalkdaniel/compboost")

# DATA -------------------------------------------------------------------------

# Get titanic data

df_train <- data.table::as.data.table(na.omit(titanic::titanic_train))

# Drop non-informative cols

df_train <- df_train[
  , .(Survived, Pclass, Sex, Age, SibSp, Parch, Fare, Embarked)]

# Convert char to fact and reverse level order for target so prob of survival 
# is modeled rather than vice versa

df_train[, Survived := 1L - Survived]
fact_cols <- c("Survived", "Pclass", "Sex", "Embarked")
df_train[, c(fact_cols) := lapply(
  .SD, as.factor), .SDcols = fact_cols]

# TRAINING ---------------------------------------------------------------------

# Instantiate models

cboost_linear <- compboost::Compboost$new(
  data = df_train,
  target = "Survived",
  loss = compboost::LossBinomial$new(),
  oob_fraction = 0.3)

cboost_nonlinear <- compboost::Compboost$new(
  data = df_train,
  target = "Survived",
  loss = compboost::LossBinomial$new(),
  oob_fraction = 0.3)

num_cols <- setdiff(names(df_train), fact_cols)

for (i in colnames(df_train)) {
  
  if (i %in% num_cols) {
    
    cboost_linear$addBaselearner(
      i, "linear", compboost::BaselearnerPolynomial, intercept = FALSE)
    
    cboost_nonlinear$addBaselearner(
      i, "linear", compboost::BaselearnerPolynomial, intercept = FALSE)
    cboost_nonlinear$addBaselearner(
      i, "spline", compboost::BaselearnerPSpline, degree = 3L)
    
  } else if (i %in% fact_cols[fact_cols != "Survived"]) {
    
    cboost_linear$addBaselearner(
      i, "categorical", compboost::BaselearnerPolynomial, intercept = FALSE)
    
    cboost_nonlinear$addBaselearner(
      i, "categorical", compboost::BaselearnerPolynomial, intercept = FALSE)
    
  }}

# Train

learners <- list(cboost_linear, cboost_nonlinear)
n_iters <- 500L
invisible(lapply(learners, function(i) i$train(n_iters)))

# # PLOTS ------------------------------------------------------------------------

# Get traces of parameter values

traces <- lapply(
  
  learners,
  
  function(i) {
    
    par <- lapply(
      seq_len(n_iters), 
      function (j) i$model$getParameterAtIteration(j))
    par_unlisted <- lapply(par, unlist)
    par_dt <- lapply(par_unlisted, function(i) as.data.frame(t(i)))
    par_all <- data.table::as.data.table(do.call(dplyr::bind_rows, par_dt))
    par_all[, iteration := .I]
    par_long <- data.table::melt(par_all, id = "iteration")
    par_long[, value := ifelse(is.na(value), 0L, value)]
    
  }
)

# ------------------------------------------------------------------------------

p_1 <- ggplot2::ggplot(
  traces[[1]], 
  ggplot2::aes(x = iteration, y = value, col = variable)) +
  ggplot2::geom_line() +
  ggplot2::theme_minimal() +
  # ggplot2::scale_color_viridis_d(name = "base learner j") +
  ggplot2::scale_color_brewer(palette = "Dark2", name = "base learner j") +
  ggplot2::xlab("m") +
  ggplot2::ylab(ggplot2::expr(theta[j]))

p_2 <- p_1 + 
  ggplot2::geom_vline(xintercept = 100L, linetype = "dashed") +
  ggplot2::ggtitle(sprintf(
    "mstop = 100: %i base learners selected",
    sum(traces[[1]][iteration == 100]$value != 0)))

p_3 <- p_1 + 
  ggplot2::geom_vline(xintercept = 400L, linetype = "dashed") +
  ggplot2::ggtitle(sprintf(
    "mstop = 400: %i base learners selected",
    sum(traces[[1]][iteration == 400]$value != 0)))

p_4 <- ggpubr::ggarrange(
  p_2, p_3, ncol = 1L, common.legend = TRUE, legend = "right")

# ------------------------------------------------------------------------------

nonlinear_bl <- as.character(traces[[2]][iteration == n_iters]$variable)
nonlinear_bl <- unique(stringr::str_remove_all(nonlinear_bl, "[0-9]"))

p_nonlinear <- lapply(
  nonlinear_bl[endsWith(nonlinear_bl, "spline")],
  function(i) {
    cboost_nonlinear$plot(i, iters = seq(0L, n_iters, by = 50L)) +
      ggplot2::theme_minimal() +
      ggplot2::scale_color_viridis_d(
        end = 0.9, direction = -1L, labels = seq(0L, n_iters, by = 50L)) +
      ggplot2::labs(
        subtitle = "", 
        title = stringr::str_remove_all(i, "_spline"))})

p_5 <- do.call(
  ggpubr::ggarrange, 
  args = list(plotlist = p_nonlinear, common.legend = TRUE, legend = "right"))

# ------------------------------------------------------------------------------

ggplot2::ggsave(
  "../figure/compboost-illustration-1.png", p_1, height = 4L, width = 10L)
ggplot2::ggsave(
  "../figure/compboost-illustration-2.png", p_4, height = 4L, width = 8L)
ggplot2::ggsave(
  "../figure/compboost-illustration-3.png", p_5, height = 4L, width = 10L)
