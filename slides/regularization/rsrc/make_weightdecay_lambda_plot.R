source("utils.R")

x1 <- seq(0,1.5,length.out = 100)
x2 <- seq(0,3.5,length.out = 100)
lambda <- 5
num_steps <- 100
beta_start <- c(0, 0)
step_size <- 0.005
grad <- R_emp_grad
num_steps <- 100
gd_l2_betas <- gradient_descent(beta_start, step_size,
                                function(beta) R_reg_l2_grad(beta, lambda), num_steps)

ret <- weight_decay(beta_start, lambda, step_size, R_emp_grad, num_steps)

remp_l2_plot_1 <-  plot_r_emp(R_emp, x1, x2) +
  geom_path(data = ret$betas_gd, aes(x=V1, y=V2), colour = "red", size=1.1) +
  geom_path(data = ret$betas_wd, aes(x=V1, y=V2), colour = "yellow", size=1.1) +
  geom_point(data = gd_l2_betas, aes(x=V1, y=V2), colour = "white") +
  labs(fill=expression(R[reg]),
       caption=expression(~Weight~decay~'(small '~lambda~')'~over~R[emp])) +   theme(legend.position="none")

lambda <- 50
gd_l2_betas <- gradient_descent(beta_start, step_size,
                                function(beta) R_reg_l2_grad(beta, lambda), num_steps)

ret <- weight_decay(beta_start, lambda, step_size, R_emp_grad, num_steps)

remp_l2_plot_2 <-  plot_r_emp(R_emp, x1, x2) +
  geom_path(data = ret$betas_gd, aes(x=V1, y=V2), colour = "red", size=1.1) +
  geom_path(data = ret$betas_wd, aes(x=V1, y=V2), colour = "yellow", size=1.1) +
  geom_point(data = gd_l2_betas, aes(x=V1, y=V2), colour = "white") +
  labs(fill=expression(R[reg]),
       caption=expression(~Weight~decay~'(large '~lambda~')'~over~R[emp])) +
  theme(legend.position="none")


p <- grid.arrange(remp_l2_plot_1 , remp_l2_plot_2 , ncol=2)

ggsave("../figure/weightdecay_lambda_plot.png", plot = p, width = 5.2, height = 3.2, dpi="retina")