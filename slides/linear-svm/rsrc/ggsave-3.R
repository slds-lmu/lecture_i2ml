
library(mvtnorm)


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

ggplot(data, aes(x=x.1, y=x.2)) +
  geom_point(aes(colour=y), size=3) +
  xlab("") + ylab("") + theme(legend.position = "none")

#############################################################

source("rsrc/plot_lin_svm.R")
plot_lin_svm(data, show_slack = TRUE) +
  annotate("label", fill="white", label="zeta", parse=TRUE, x=1.1, y=-0.5) +
  annotate("label", fill="white", label="zeta", parse=TRUE, x=-0.35, y=0.55) 

##########################################################

library(gridExtra)

p1 <- plot_lin_svm(data, show_slack = TRUE, C=0.5) + 
  labs(caption = "C = 0.5")
p2 <- plot_lin_svm(data, show_slack = TRUE, C=100) + 
  labs(caption = "C = 100")

grid.arrange(p1, p2, ncol=2)

#########################################################

plot_lin_svm(data, show_slack = TRUE, C=1, highlight_sv = TRUE) 