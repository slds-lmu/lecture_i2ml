# ------------------------------------------------------------------------------
# FIG: L2 REGULARIZATION HESSIAN PLOTS
# ------------------------------------------------------------------------------

source("utils.R")

lambda <- 50
beta_start <- c(0, 0)
step_size <- 0.005
grad <- R_emp_grad
num_steps <- 100

gd_betas <- gradient_descent(beta_start, step_size, grad, num_steps)

theta_min <- gd_betas[num_steps,]
hessian <- R_emp_hessian()

eig_dec <- eigen(hessian)
Q <- eig_dec$vectors
S <- diag(eig_dec$values)

theta_min_rot <-  t(Q) %*% t(as.matrix(theta_min))
theta_min_rot_data <- as.data.frame(t(theta_min_rot))

theta_proj1 <- Q[,1] * (Q[,1] %*% t(as.matrix(theta_min)))[1]
theta_proj2 <- Q[,2] * (Q[,2] %*% t(as.matrix(theta_min)))[1]

theta_proj1_data <- as.data.frame(t(theta_proj1))
theta_proj2_data <- as.data.frame(t(theta_proj2))

theta_min_skew <- solve(S + diag(rep(lambda, length(eig_dec$values)))) %*%
  S %*% theta_min_rot
theta_min_skew_data <- as.data.frame(t(theta_min_skew))

theta_min_ridge_data <- as.data.frame(t(Q %*% theta_min_skew))

x1 <- seq(-1.5,2,length.out = 100)
x2 <- seq(-1,3.5,length.out = 100)

# R_emp
init_cond_plot <- plot_r_emp(R_emp, x1, x2) +
  annotate("label", x = 0.75, y = 3, label = "hat(theta)",
           parse = TRUE, color = 'black', size = 3, fill = "red") +
  theme(legend.position="none") + coord_fixed() +
  geom_hline(yintercept = 0, colour="darkgrey", size=1.2) +
  geom_vline(xintercept = 0, colour="darkgrey", size=1.2) +
  geom_line(data=rbind(rep(0, num_features), theta_min),
            aes(x=V1, y=V2), colour="red", size=1, arrow = arrow(length = unit(0.09, "npc")))

rot_plot <- plot_r_emp(R_emp, x1, x2) +
  theme(legend.position="none") + coord_fixed() +
  geom_abline(slope = Q[2,1]/Q[1,1], colour="darkgrey", size=1.2) +
  geom_abline(slope = Q[2,2]/Q[1,2], colour="darkgrey", size=1.2) +
  geom_line(data=rbind(rep(0, num_features), theta_min),
            aes(x=V1, y=V2), colour="red", size=1, arrow = arrow(length = unit(0.09, "npc"))) +
  geom_segment(data=cbind(start=as.data.frame(t(c(0,0))), end=theta_proj1_data ), size=0.9,
               arrow=arrow(type="closed", length = unit(0.09, "npc")),
               linetype="dashed", aes(x=start.V1, y=start.V2, xend = end.V1, yend = end.V2),
               colour = "green", arrow.fill = "green") +
  geom_segment(data=cbind(start=as.data.frame(t(c(0,0))), end=theta_proj2_data ), size=0.9,
               arrow=arrow(type="closed", length = unit(0.09, "npc")),
               linetype="dashed", aes(x=start.V1, y=start.V2, xend = end.V1, yend = end.V2),
               colour = "green", arrow.fill = "green")

rs <- sapply(1:2, function(i) S[i,i] / (S[i,i] + lambda))

scale_rot_plot <- rot_plot +
  geom_segment(data=cbind(start=as.data.frame(t(c(0,0))), end=
                            theta_proj1_data*rs[1] ), size=0.9,
               arrow=arrow(type="closed", length = unit(0.09, "npc")),
               linetype="dashed", aes(x=start.V1, y=start.V2,
                                      xend = end.V1, yend = end.V2),
               colour = "orange", arrow.fill = "orange") +
  geom_segment(data=cbind(start=as.data.frame(t(c(0,0))), end=
                            theta_proj2_data*rs[2] ), size=0.9,
               arrow=arrow(type="closed", length = unit(0.09, "npc")),
               linetype="dashed", aes(x=start.V1, y=start.V2,
                                      xend = end.V1, yend = end.V2),
               colour = "orange", arrow.fill = "orange") +
  geom_segment(data=cbind(start=as.data.frame(t(c(0,0))), end=
                            theta_proj1_data*rs[1] +
                            theta_proj2_data*rs[2] ), size=0.9,
               arrow=arrow(length = unit(0.09, "npc")),
               linetype="solid", aes(x=start.V1, y=start.V2,
                                     xend = end.V1, yend = end.V2),
               colour = "yellow")

scale_plot <- init_cond_plot +
  annotate("label", x = 1.3, y = 1.5, label = "hat(theta)[Ridge]",
           parse = TRUE, color = 'black', size = 3, fill = "yellow") +
  geom_segment(data=cbind(start=as.data.frame(t(c(0,0))), end=
                            theta_proj1_data*rs[1] +
                            theta_proj2_data*rs[2] ), size=0.9,
               arrow=arrow(length = unit(0.09, "npc")),
               linetype="solid", aes(x=start.V1, y=start.V2,
                                     xend = end.V1, yend = end.V2),
               colour = "yellow")

p1 <- grid.arrange(init_cond_plot, rot_plot, ncol=2)

p2 <- grid.arrange(rot_plot, init_cond_plot, ncol=2)

p3 <- grid.arrange(scale_rot_plot, scale_plot, ncol=2)

ggsave("../figure/l2_reg_hess_01_plot.png", plot = p1, width = 5.5, height = 3.5, dpi="retina")
ggsave("../figure/l2_reg_hess_02_plot.png", plot = p2, width = 5.5, height = 3.5, dpi="retina")
ggsave("../figure/l2_reg_hess_03_plot.png", plot = p3, width = 5.5, height = 3.5, dpi="retina")