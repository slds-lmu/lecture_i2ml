################################################################################
# EXAMPLE: LASSO VS RIDGE WITH MULTICOLLINEARITY
################################################################################

# PREREQ -----------------------------------------------------------------------

library(dplyr)
library(ggrepel)
library(MASS)
library(mlr)
library(BBmisc)
library(data.table)
library(gridExtra)
library(grid)
options(scipen = 10000)

# FICTIONAL DATA ---------------------------------------------------------------

set.seed(20200611)

# Create 4 normally distributed, uncorrelated RV

Sigma = diag(rep(2, 4))

design_matrix = data.frame(mvrnorm(100, mu = rep(0, 4), Sigma = Sigma,
                                   empirical = TRUE))

# Add X5 - almost perfectly correlated to X4

colnames(design_matrix) = c("X1", "X2", "X3", "X4")
design_matrix = design_matrix %>% 
  mutate(X5 = X4 + rnorm(nrow(design_matrix), 0, 0.3))

# Create target variable

design_matrix = design_matrix %>% mutate(y = 0.2 * X1 + 0.2 * X2 + 0.2 * X3
                                             + 0.2 * X4 + 0.2 * X5 + 
                                           rnorm(nrow(design_matrix), 0, 1))

# REGRESSION TASK --------------------------------------------------------------

task_mc = makeRegrTask("fictional", design_matrix, "y")
featnames_mc = getTaskFeatureNames(task_mc)

# COEFFICENT PATHS -------------------------------------------------------------

compute_coef_paths = function(task, lambda_name, lambda_seq) {
  
  lrn = makeLearner("regr.penalized", trace = FALSE, lambda1 = 0, lambda2 = 0)
  path = list()
  
  # Compute coefficients for each model (on entire data)
  
  for (i in seq_along(lambda_seq)) {
    
    lamval = lambda_seq[[i]]
    pv = namedList(lambda_name, lamval)
    lrn2 = setHyperPars(lrn, par.vals = pv)
    m1 = train(lrn2, task)
    mm1 = getLearnerModel(m1)
    cc = coefficients(mm1)
    cc = as.list(cc)
    cc$lambda = lamval
    path[[i]] = cc
    
  }
  
  path = rbindlist(path, fill = TRUE)
  path[is.na(path)] = 0
  
  # Perform cross validation
  
  ps = makeParamSet(
    makeDiscreteParam(id = lambda_name, values = lambda_seq)
  )
  ctrl = makeTuneControlGrid()
  tr = tuneParams(lrn, task, cv3, par.set = ps, control = ctrl, show.info = 
                    FALSE)
  cv_lam = as.data.frame(tr$opt.path)[, c(lambda_name, "mse.test.mean")]
  colnames(cv_lam) = c("lambda", "mse")
  cv_lam$lambda = as.numeric(as.character(cv_lam$lambda))
  list(path = path, cv_lam = cv_lam)
  
}

# PLOT PATHS -------------------------------------------------------------------

plot_coef_paths_mc = function(obj, featnames, xlab) {
  ggd = melt(obj$path, efs, id.var = "lambda", measure = featnames, 
             variable.name = "featname", value.name = "coefval")
  ggd$label = ifelse(ggd$lambda == min(lambda_seq_mc), 
                     as.character(ggd$featname), NA)
  ggd$mse = rep(obj$cv_lam[, "mse"], 5)
  pl = ggplot(data = ggd, mapping = aes(x = lambda, y = coefval, 
                                        group = featname, col = featname))
  pl = pl + geom_line()
  pl = pl + geom_label_repel(aes(label = label), na.rm = TRUE)
  pl = pl + scale_x_log10()
  pl = pl + xlab(xlab)
  pl = pl + theme_bw()
  pl = pl + scale_color_manual(values = c(rep("black", 3),"#7FFF32","#067B7F"),
                               guide = FALSE)
  pl = pl + geom_line(mapping = aes(x = ggd$lambda, y = ggd$mse * 0.5),
                      col = "black", linetype = "longdash")
  pl = pl + geom_text(x = max(log(ggd$lambda, 10)), 
                      y = 0.5 * (max(ggd$mse)) - 0.01, vjust = 1, hjust = 1, 
                      label = "MSE", col = "black")
  pl = pl + scale_y_continuous(sec.axis = sec_axis(~. * 2, name = "MSE"))
  pl = pl + geom_hline(aes(yintercept = 0), col = "black", linetype = "dotted")

}

#Visualize shrinkage in presence of multicollinearity
library(ggplot2)
lambda_seq_mc = 2^seq(-10, 20, length.out = 50)

path_l1_mc = compute_coef_paths(task_mc, "lambda1", lambda_seq_mc)
path_l2_mc = compute_coef_paths(task_mc, "lambda2", lambda_seq_mc)

p_l1 = plot_coef_paths_mc(path_l1_mc, featnames_mc, "Lasso / lambda")
p_l2 = plot_coef_paths_mc(path_l2_mc, featnames_mc, "Ridge / lambda")

g = grid.arrange(p_l1, p_l2, nrow = 1)
ggsave("figure_man/regu_example_multicollinearity.png", g, width= 8, height =3 )
#x = capture.output(print(g))

