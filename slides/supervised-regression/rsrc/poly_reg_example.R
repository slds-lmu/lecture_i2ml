library(remotes)
library(ellipsis)
library(farff)
library(RWeka)
library(OpenML)
library(vctrs)
library(tibble)
library(pillar)
library(ggplot2)
library(jtools)
library(effects)
library(gridExtra)
library(GGally)
library(cvTools)
library(data.table)

# load bike data set from OpenML
bike_openML <- getOMLDataSet(data.id = 45103)

# extract data
bike_data <- bike_openML$data

# overview
summary(bike_data)

# transformation of variable "rentals" into numeric variable
bike_data$rentals <- as.numeric(bike_data$rentals)
# transformation of variable "mnth" into factor variable
bike_data$mnth <- as.factor(bike_data$mnth)
# transformation of variable "season" into factor variable
bike_data$season <- as.factor(bike_data$season)


# Code for CV
rmse <- function(observed, predicted) {
  return(sqrt(sum((observed - predicted)^2) / length(observed)))
}

get_folds <- function(n, K = n_folds) {
  cv_folds <- cvTools::cvFolds(n = n, K = K)
  cv_folds <- split(x = cv_folds$subsets[, 1], f = cv_folds$which)
  return(cv_folds)
}

do_cv <- function(data, folds, degree0) {
  # computes RMSE mean of all folds. 
  cv_mod_test <- mean(vapply(X = folds, FUN = function(i) {
    model <- lm(rentals ~ poly(temp, degree = degree0) + season  + hum, data = data[-i, ])
    rmse(observed = data[i, "rentals"],
         predicted = predict(object = model, newdata = data[i,]))
  }, FUN.VALUE = numeric(1)))
  
  cv_mod_train <- mean(vapply(X = folds, FUN = function(i) {
    model <- lm(rentals ~ poly(temp, degree = degree0) + season + hum, data = data[-i, ])
    rmse(observed = data[-i, "rentals"],
         predicted = predict(object = model, newdata = data[-i,]))
  }, FUN.VALUE = numeric(1)))
  
  # fit model on whole data set
  mod_data = lm(rentals ~ poly(temp, degree = degree0) , data = data)
  
  # generate effect plots:
  plot <- effect_plot(mod_data, pred = temp, data = data, plot.points = TRUE, 
              interval = TRUE, line.color = "blue", y.label = "number of rentals",
              x.lab  = "normalized temperature", main.title = paste0("effect plot degree ", degree0))
  
  # save coefficient estimates:
  estimated_effects <- mod_data$coefficients
  
  attr(x = cv_mod_test, which = "degree") <- degree0
  attr(x = cv_mod_train, which = "degree") <- degree0
  attr(x = cv_mod_test, which = "data") <- "test set: predicted GE"
  attr(x = cv_mod_train, which = "data") <- "train set: training error"
  return(list("cv_test_error" = cv_mod_test,"cv_train_error" = cv_mod_train, 
              "coeff_estimates" =  estimated_effects, "plots" = plot))
}

do_cvs <- function(data, folds, degrees) {
  # generate all possible specifications. 
  # computes cv for each specification. 
  res_all <- lapply(degrees, FUN = function(z) do_cv(data = data, folds = folds, degree0 = z))
  return(res_all)
}

# run CV + plots + coefficient estimates
# set highest degree for polynomials
degrees0 <- seq_len(10)
# set number of folds for CV
n_folds <- 10
# run CV
set.seed(1)
folds0 = get_folds(n = nrow(bike_data))
set.seed(1)
CV_results <- do_cvs(bike_data, folds = folds0, degrees = degrees0)

# extract results for train and test error
error_list <- lapply(CV_results, function(i) i[c("cv_test_error","cv_train_error")])
error_dt <- rbindlist(error_list)
error_dt <- cbind(degrees0, error_dt)
colnames(error_dt) <- c("degree", "test_error", "train_error")

# plotting test and training error
ggplot() + geom_line(data = error_dt, aes(x = degree, y = test_error, color = "test error")) + 
  geom_line(data = error_dt, aes(x = degree, y = train_error, color = "train error")) + 
  xlab("Degree") + ylab("rmse") + theme_bw() + 
  labs(color='') 
ggsave("figure/ploynomial_regression_test_train_error.png")

# extract results for coefficient estimates
coeff_list <- lapply(CV_results, function(i) i[["coeff_estimates"]])

# extract plots
plot_list <- lapply(CV_results, function(i) i[["plots"]])

# save plots
for(i in degrees0){
  plot <- plot_list[[i]]
  jpeg(file= paste0("figure/polynomial_regr_effect_plot_degree_", i, ".png"))
  print(plot)
  dev.off()
}




