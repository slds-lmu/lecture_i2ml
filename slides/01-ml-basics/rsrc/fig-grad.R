library(grid) 
library(ggplot2)

f <- function(x) (x[1]^2 + 3*x[2]^2)
d_f <- function(x) c(2*x[1], 6*x[2])

d = 50

theta_1 <- seq(-5, 5, length.out = d)
theta_2 <- seq(-5, 5, length.out = d)
thetas <- as.data.frame(expand.grid(x = theta_1, y = theta_2))

thetas$R <- apply(thetas, 1,function(theta) f(theta))

d <- 5
theta_1 <- seq(-3, 3, length.out = d)
theta_2 <- seq(-3, 3, length.out = d)
thetas_a <- as.data.frame(expand.grid(x = theta_1, y = theta_2))

thetas_a <- thetas_a[!(thetas_a[,1] == 0 & thetas_a[,2] == 0),]

res_df <- cbind(thetas_a ,thetas_a + 0.1*as.data.frame(t(apply(thetas_a, 1, d_f))))
colnames(res_df) = c("x", "y", "xend", "yend")

p <- ggplot() +
         geom_raster(data=thetas, aes(x=x,y=y, fill=R)) +
         geom_contour(data=thetas, aes(x=x,y=y, z=R), colour="grey") +
         geom_segment(data=res_df, aes(x=x, y=y,xend=xend, yend=yend), 
                      arrow = arrow(length = unit(0.3,"cm")), colour="white") +
         xlab(expression(theta[1])) +
         ylab(expression(theta[2])) +
         labs(fill=expression(R[emp])) +
         theme(axis.ticks = element_blank(),
               axis.text = element_blank()) 
  
ggsave(filename = "../figure/grad.pdf", plot = p, width = 8, height = 8, units = "cm")


