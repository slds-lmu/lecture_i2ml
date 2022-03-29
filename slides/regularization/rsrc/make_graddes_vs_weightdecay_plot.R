# ------------------------------------------------------------------------------
# FIG: GRADIENT DESCENT VS WEIGHT DECAY PLOT
# ------------------------------------------------------------------------------

source("utils.R")

x1 <- seq(0,1.5,length.out = 100)
x2 <- seq(0,3.5,length.out = 100)

beta_start <- c(0, 0)
step_size <- 0.005
grad <- R_emp_grad
num_steps <- 100

gd_betas <- gradient_descent(beta_start, step_size, grad, num_steps)

# R_emp plot
remp_plot <- plot_r_emp(R_emp, x1, x2) +
  geom_path(data = gd_betas, aes(x=V1, y=V2), colour = "red", size=1.1) +
  geom_point(data = gd_betas, aes(x=V1, y=V2), colour = "white") +
  labs(fill=expression(R[emp]), caption=expression(~Gradient~descent~over~R[emp]))  +
  theme(legend.position="none")

# R_reg plot

lambda <- 10
num_steps <- 100
gd_l2_betas <- gradient_descent(beta_start, step_size,
                                function(beta) R_reg_l2_grad(beta, lambda), num_steps)

ret <- weight_decay(beta_start, lambda, step_size, R_emp_grad, num_steps)

remp_l2_plot <-  plot_r_emp(R_emp, x1, x2) +
  geom_path(data = ret$betas_gd, aes(x=V1, y=V2), colour = "red", size=1.1) +
  geom_path(data = ret$betas_wd, aes(x=V1, y=V2), colour = "yellow", size=1.1) +
  geom_point(data = gd_l2_betas, aes(x=V1, y=V2), colour = "white") +
  labs(fill=expression(R[reg]), caption=expression(~Weight~decay~over~R[emp])) +
  theme(legend.position="none")

p <- grid.arrange(remp_plot, remp_l2_plot, ncol=2)

ggsave("../figure/graddes_vs_weightdecay.png", plot = p, width = 5.2, height = 3.2, dpi="retina")