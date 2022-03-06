# ------------------------------------------------------------------------------
# FIG: HARD MARGIN SVM CLASSIFICATION PLOTS
# ------------------------------------------------------------------------------
library(ggplot2)
library(mlr)
library(BBmisc)
library(mvtnorm)
library(gridExtra)

source("utils.R")

theme_set(theme_minimal())

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
tmp$y <- relevel(as.factor(tmp$y), "1")

bad_dec <- plot_lin_svm(tmp, show_gamma = FALSE, C=100, 
                        show_points = FALSE,
                        show_margin = FALSE,
                        highlight_mc = FALSE,
                        sw_labels = -1) + 
  geom_point(data=data, aes(x=x.1, y=x.2, colour=y), size=3)

linear_classif_1_plot <- grid.arrange(bad_dec, good_dec, ncol=2)

ggsave(filename = "../figure/linear_classif_1.png", plot = linear_classif_1_plot, width = 6, height = 3)

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

linear_classif_2_plot <- grid.arrange(bad_dec, good_dec, ncol=2)

ggsave(filename = "../figure/linear_classif_2.png", plot = linear_classif_2_plot, width = 6, height = 3)

####################################################

svm_geo <- plot_lin_svm(data, C=100,
             show_margin = TRUE, 
             show_distances = TRUE,
             gamma_offset = c(0.05, -0.05))

ggsave(filename = "../figure/svm_geometry.png", plot = svm_geo, width = 3, height = 3)

####################################################

support_vects <- plot_lin_svm(data, C=100,
             show_margin = TRUE, 
             show_distances = TRUE,
             gamma_offset = c(0.1, -0.1), 
             highlight_sv = TRUE)

ggsave(filename = "../figure/support_vectors.png", plot = support_vects, width = 3, height = 3)
####################################################
