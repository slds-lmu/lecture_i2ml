
library(knitr)
library(ggplot2)
library(mlr)
library(BBmisc)

source("rsrc/plot_lin_svm.R")

library(mvtnorm)
library(gridExtra)
set.seed(3)

num_obs <- 20
sigma <- matrix(c(1,-0.95, -0.95,1), nrow=2)
mu <- c(0.3,0.3)                      
x_data <- rmvnorm(num_obs, mean=mu, sigma = sigma)
x_data <- rbind(x_data, rmvnorm(num_obs, mean=-mu, sigma = sigma))

all_data <- data.frame(x = x_data, y = factor("1", levels=c("1", "-1")))
all_data$y[num_obs:(2*num_obs)] <- "-1"

data <- all_data[which(abs(all_data$x.1) < 1 & abs(all_data$x.2) < 1), ]
row.names(data) <- as.character(1:nrow(data))      

good_dec <- plot_lin_svm(data, show_gamma = FALSE, C=100, 
                         show_margin = FALSE)

tmp <- rbind(data.frame(x.1=-0.5, x.2=0.6, y="-1"),
             data)
tmp$y <- relevel(tmp$y, "1")

bad_dec <- plot_lin_svm(tmp, show_gamma = FALSE, C=100, 
                        show_points = FALSE,
                        show_margin = FALSE,
                        highlight_mc = FALSE,
                        sw_labels = -1) + 
  geom_point(data=data, aes(x=x.1, y=x.2, colour=y), size=3)

grid.arrange(bad_dec, good_dec, ncol=2)

#####################################################

good_dec <- plot_lin_svm(data, show_gamma = FALSE, C=100, 
                         show_margin = TRUE)

bad_dec <- plot_lin_svm(tmp, show_gamma = FALSE, C=100, 
                        show_points = FALSE,
                        show_margin = TRUE, 
                        highlight_mc = FALSE,
                        sw_labels = -1) + 
  geom_point(data=data, aes(x=x.1, y=x.2, colour=y), size=3) 

grid.arrange(bad_dec, good_dec, ncol=2)

####################################################

plot_lin_svm(data, C=100, 
             show_margin = TRUE, 
             show_distances = TRUE,
             gamma_offset = c(0.05, -0.05))
####################################################

plot_lin_svm(data, C=100, 
             show_margin = TRUE, 
             show_distances = TRUE,
             gamma_offset = c(0.05, -0.05))

####################################################

plot_lin_svm(data, C=100, 
             show_margin = TRUE, 
             show_distances = TRUE,
             gamma_offset = c(0.1, -0.1), 
             highlight_sv = TRUE)
####################################################
