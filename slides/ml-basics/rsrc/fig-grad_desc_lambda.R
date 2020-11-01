R <- function(x) (x[1]^2 + 3*x[2]^2)
d_R <- function(x) c(2*x[1], 6*x[2])

d = 50

theta_1 <- seq(-5, 5, length.out = d)
theta_2 <- seq(-5, 5, length.out = d)
thetas <- as.data.frame(expand.grid(x = theta_1, y = theta_2))
thetas$R <- apply(thetas, 1,function(theta) R(theta)) 


lambda_plot <- function(lambda, n){

  theta_0 <- c(-2.5, 3)
  theta_i <- theta_0
  theta_trace <- theta_i
  
  for(i in seq(n)){
    theta_i_n <- theta_i - lambda * d_R(theta_i)
    theta_trace <- rbind(theta_trace, theta_i_n)
    theta_i <- theta_i_n
  }
  
  p <- ggplot(thetas, aes(x=x, y=y)) + 
    geom_raster(aes(fill=R)) +
    geom_contour(aes(z=R), colour="white")+
    xlab(expression(theta[1])) +
    ylab(expression(theta[2])) +
    theme(legend.position = "none")
  for (i in seq(n-1)){
    p <- p +   geom_path(data=as.data.frame(theta_trace[i:(i+1),]), aes(x=V1, y=V2), colour="red", arrow = arrow(),
                         size=1.1)
  }
  p +   annotate("label", label=expression(theta^{"["*0*"]"}), x=theta_0[1], y=theta_0[2]+0.5, fill="cyan") +
    geom_point(data=as.data.frame(t(theta_0)), aes(x=V1, y=V2), colour="cyan") 

}

ggsave(filename = "../figure/grad_desc_lambda1.pdf", 
       plot = lambda_plot(0.15, 10), 
       width = 8, height = 8, units = "cm")
ggsave(filename = "../figure/grad_desc_lambda2.pdf", 
       plot = lambda_plot(0.3, 5), 
       width = 8, height = 8, units = "cm")
ggsave(filename = "../figure/grad_desc_lambda3.pdf", 
       plot = lambda_plot(0.355, 5), 
       width = 8, height = 8, units = "cm")



