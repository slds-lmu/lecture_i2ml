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


# scatter plot rentals on temp
ggplot(data = bike_data, aes(x = temp, y = rentals)) + geom_point() +
  theme_bw()

# scatter plot rentals on mnth
ggplot(data = bike_data, aes(x = mnth, y = rentals)) + geom_point() +
  theme_bw()


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
  # Berechnung des Mittelwertes der RMSEs aller Teildatens¨atze:
  cv_mod_test <- mean(vapply(X = folds, FUN = function(i) {
    model <- lm(rentals ~ poly(temp, degree = degree0) , data = data[-i, ])
    rmse(observed = data[i, "rentals"],
         predicted = predict(object = model, newdata = data[i,]))
  }, FUN.VALUE = numeric(1)))
  
  cv_mod_train <- mean(vapply(X = folds, FUN = function(i) {
    model <- lm(rentals ~ poly(temp, degree = degree0) , data = data[-i, ])
    rmse(observed = data[-i, "rentals"],
         predicted = predict(object = model, newdata = data[-i,]))
  }, FUN.VALUE = numeric(1)))
  
  # fit model on whole data set
  mod_data = lm(rentals ~ poly(temp, degree = degree0) , data = data)
  
  # generate effect plots:
  plot <- effect_plot(mod_data, pred = temp, data = data, plot.points = TRUE, 
              interval = TRUE, line.color = "blue", y.label = "number of rentals",
              x.lab  = "normalized temperature", main.title = paste0("effect plot | degree: ", degree0))
  
  
  
  # save coefficient estimates:
  estimated_effects <- mod_data$coefficients
  
  
  # Ausgabe des Kreuzvalidierungs-RMSEs:
  attr(x = cv_mod_test, which = "degree") <- degree0
  attr(x = cv_mod_train, which = "degree") <- degree0
  attr(x = cv_mod_test, which = "data") <- "test set: predicted GE"
  attr(x = cv_mod_train, which = "data") <- "train set: training error"
  return(list(cv_mod_test, cv_mod_train, estimated_effects, plot))
}



do_cvs <- function(data, folds, degrees) {
  # Generierung aller m¨oglichen Modellspezifikationen:
  
  # Durchf¨uhrung der Kreuzvalidierung f¨ur die einzelnen Modellspezifikationen:
  res_all <- lapply(degrees, FUN = function(z) do_cv(data = data, folds = folds, degree0 = z))
  # Extraktion des gem¨aß des RMSEs besten Modells:
  # model_best <- lm(formula = attr(x = get_best(res_all), which = "formula"),
  #                  data = data)
  # return(coef(model_best))
  return(res_all)
  
}


# run CV + plots + coefficient estimates
# set highest degree for polynomials
degrees0 <- seq_len(8)
# set number of folds for CV
n_folds <- 10
# run CV
set.seed(1)
folds0 = get_folds(n = nrow(bike_data))
set.seed(1)
CV_results <- do_cvs(bike_data, folds = folds0, degrees = degrees0)

# extract results for train and test error
error_list <- lapply(CV_results, function(i) i[c(1,2)])
error_dt <- rbindlist(error_list)
error_dt <- cbind(degrees0, error_dt)
colnames(error_dt) <- c("degree", "test_error", "train_error")

# plotting test and training error
jpeg(file= "plot: train vs test error.jpeg")
plot(x = error_dt$degree, y = error_dt$test_error, type = "l", ylim = c(122,130), 
     ylab = "rmse", xlab = "degree", main = "test & training error")
lines(x = error_dt$degree, y = error_dt$train_error, col = "red")
legend(x = "topright",          # Position
       legend = c("test", "train"),  # Legend texts
       lty = c(1, 2),           # Line types
       col = c("black", "red"),           # Line colors
       lwd = 2)  
dev.off()

# extract results for coefficient estimates
coeff_list <- lapply(CV_results, function(i) i[[3]])

# extract plots
plot_list <- lapply(CV_results, function(i) i[[4]])

# save plots
for(i in degrees0){
  plot <- plot_list[[i]]
  jpeg(file= paste0("effect_plot_degree_", i, ".jpeg"))
  print(plot)
  dev.off()
}




