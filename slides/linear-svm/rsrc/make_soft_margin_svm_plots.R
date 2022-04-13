# ------------------------------------------------------------------------------
# FIG: SOFT MARGIN SVM CLASSIFICATION PLOTS
# ------------------------------------------------------------------------------
library(mvtnorm)
library(ggplot2)
library(viridis)
library(gridExtra)

source("utils.R")


set.seed(1)

num_obs <- 20
sigma <- matrix(c(1,-0.9,-0.9,1), nrow=2)
mu <- c(0.3,0.3)                      
x_data <- rmvnorm(num_obs, mean=mu, sigma = sigma)
x_data <- rbind(x_data, rmvnorm(num_obs, mean=-mu, sigma = sigma))

all_data <- data.frame(x = x_data, y = factor("1", levels=c("1", "-1")))
all_data$y[num_obs:(2*num_obs)] <- "-1"

data <- all_data[which(abs(all_data$x.1) < 1 & abs(all_data$x.2) < 1), ]
row.names(data) <- as.character(1:nrow(data))

ds_p <- ggplot(data, aes(x=x.1, y=x.2)) +
  geom_point(aes(colour=y), size=3) +
  xlab("") + ylab("") + theme(legend.position = "none") +
  scale_color_viridis(end = 0.9, discrete = TRUE)

ggsave(filename = "../figure/non_separable_data.png", plot = ds_p, width = 5, height = 2.5)

#############################################################
boundary_violation <- plot_lin_svm(data, show_slack = TRUE) +
  annotate("label", fill="white", label="zeta", parse=TRUE, x=1.1, y=-0.5) +
  annotate("label", fill="white", label="zeta", parse=TRUE, x=-0.35, y=0.55) 

ggsave(filename = "../figure/boundary_with_violations.png", plot = boundary_violation, width = 3, height = 3)
##########################################################

p1 <- plot_lin_svm(data, show_slack = TRUE, C=0.5) + 
  labs(caption = "C = 0.5")
p2 <- plot_lin_svm(data, show_slack = TRUE, C=100) + 
  labs(caption = "C = 100")

margin_violations <- grid.arrange(p1, p2, ncol=2)

ggsave(filename = "../figure/margin_violations.png", plot = margin_violations, width = 6, height = 3)

#########################################################

soft_margin_svs <- plot_lin_svm(data, show_slack = TRUE, C=1, highlight_sv = TRUE)

ggsave(filename = "../figure/soft_margin_svs.png", width = 3, height = 3)