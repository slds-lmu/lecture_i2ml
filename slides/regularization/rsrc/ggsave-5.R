
library(knitr)
library(mlr)
library(mlbench)
library(ggplot2)
library(BBmisc)
library(reshape)

X <- as.data.frame(matrix(c(0, 1, 1,    0.25, 0,    0.75, 0.75, 0.25,
                            1, 0, 0.75, 0,    0.25, 1,    0.25, 0.75),
                          ncol=2, byrow = FALSE))
colnames(X) <- c("x1", "x2")
X$type <- as.factor(as.character(c(-1, 1, 1, 1, -1, -1, -1, 1)))

plot_data <- ggplot(X, aes(x=x1, y=x2)) +
  geom_point(aes(colour=type), size=2) +
  labs(colour="Class") + #theme(legend.position = "bottom") +
  coord_fixed() + theme(legend.margin=margin(t = 0, unit='cm')) +
  xlab(expression(x[1])) +
  ylab(expression(x[2])) + 
  annotate("label", x=0.9, y=0.3, label="x^(7)", parse=TRUE) +
  annotate("label", x=0.4, y=0.8, label="x^(8)", parse=TRUE) 

dec_bounds <- rbind(data.frame(x = c(-Inf, Inf, -Inf), y = c(-Inf, Inf, Inf), type=-1),
                    data.frame(x = c(-Inf, Inf, Inf), y = c(-Inf, Inf, -Inf), type=1)
)

dec_bounds$type <- as.factor(dec_bounds$type)

plot_dec_bound <- plot_data +
  geom_polygon(data = dec_bounds,
               aes(x,y, fill=type), alpha=0.3) +
  guides(fill=FALSE)

grid.arrange(plot_data, plot_dec_bound, ncol=2) 

###############################################################

mat_X <- as.matrix(X[,c(1,2)])
cor_X <- as.matrix(X[1:6,c(1,2)])
incor_X <-  as.matrix(X[7:8,c(1,2)])

theta_dir <- c(1/sqrt(2), -1/sqrt(2))

emp_risk_cor <- function(theta_len){
  sum(log(1 + exp(- abs(theta_len * cor_X %*% theta_dir))))
}

emp_risk_incor <- function(theta_len){
  sum(log(1 + exp(abs(theta_len * incor_X %*% theta_dir))))
}

theta_lens <- seq(1,10,length.out = 100)
emp_data <- data.frame(t_len = theta_lens, 
                       cor = sapply(theta_lens, emp_risk_cor),
                       incor = sapply(theta_lens, emp_risk_incor))

emp_data$emp <- emp_data$cor + emp_data$incor
min_t_len <- emp_data$t_len[which.min(emp_data$emp)]

plot_df <- melt(emp_data, id.vars="t_len")
theta_pl <- ggplot(plot_df, aes(t_len, value)) +
  geom_line(aes(colour=variable)) + 
  geom_vline(xintercept = min_t_len, linetype="dashed") +
  xlab(expression('Length of '~theta)) +
  ylab("") +
  labs(colour="") +
  scale_colour_discrete(labels = expression(f[cor], f[incor], R[emp])) +
  annotate("label", x=min_t_len, y=6, label="bar(theta)", parse=TRUE)

loss_score <- function(score){
  log(1 + exp(-score))
}

scores <- seq(-5.5, 5.5, length.out = 100)

loss_1 <- loss_score(scores)
loss_m1 <- loss_score(-scores)

plot_df_1 <- data.frame(loss = loss_1, scores = scores)
plot_df_m1 <- data.frame(loss = loss_m1, scores = scores)

X_m1 <- X[X$type == "-1", c(1,2)]
X_1 <- X[X$type == "1", c(1,2)]

theta_scale <- 8

X_m1$class <- "cor"
X_m1$class[4] <- "incor"
X_m1 <- rbind(X_m1, X_m1)
X_m1$score <- as.matrix(X_m1[,c(1,2)]) %*% theta_dir
X_m1$score[5:8] <- X_m1$score[5:8] * theta_scale
X_m1$theta <- "1"
X_m1$theta[5:8] <- as.character(theta_scale)

X_1$class <- "cor"
X_1$class[4] <- "incor"
X_1 <- rbind(X_1, X_1)
X_1$score <- as.matrix(X_1[,c(1,2)]) %*% theta_dir
X_1$score[5:8] <- X_1$score[5:8] * theta_scale
X_1$theta <- "1"
X_1$theta[5:8] <- as.character(theta_scale)

loss_pl <-
  ggplot() +
  geom_line(data=plot_df_1, aes(x=scores, y=loss)) +
  geom_line(data=plot_df_m1, aes(x=scores, y=loss)) +    
  geom_point(data = X_1, aes(score, loss_score(score), colour=class,
                             shape=theta), size=2.1,
             alpha=0.7) +
  geom_point(data = X_m1, aes(score, loss_score(-score), colour=class,
                              shape=theta), size=2.1,
             alpha=0.7) +
  labs(colour="classified", shape=expression(bar(theta))) +
  scale_colour_discrete(labels = c("correctly", "incorrectly")) +
  theme(legend.spacing.y = unit(0, 'cm')) +
  ylab("log loss") +
  guides(colour = guide_legend(order = 1),
         shape = guide_legend(order = 2)) +
  annotate("label", x=-3.5, y=4, label="1") +
  annotate("label", x=3.5, y=4, label="-1")

grid.arrange(theta_pl, loss_pl, ncol=2)

#####################################################

y <- as.numeric(as.character(X$type[1:6]))
emp_risk_all_cor <- function(theta){
  sum(log(1 + exp(-y * (cor_X %*% theta))))
}

emp_risk_all_cor_ridge <- function(theta, lambda=0.5){
  sum(log(1 + exp(-y * (cor_X %*% theta)))) + lambda/2*sqrt(sum(theta^2))
}

x1 <- seq(0,20,length.out = 200)
x2 <- seq(0,-20,length.out = 200)

eval_grid <- expand.grid(x1,x2)

res <- eval_grid
res$r_emp <- apply(eval_grid, 1, emp_risk_all_cor)
res$r_reg <- apply(eval_grid, 1, emp_risk_all_cor_ridge)

plot_emp <-ggplot(res) +
  geom_raster(aes(x=Var1, y=Var2, fill=r_emp)) + 
  geom_contour(aes(x=Var1, y=Var2, z=r_emp), colour="white") + 
  xlab(expression(theta[1])) +
  ylab(expression(theta[2])) +
  labs(fill=expression(R[emp]), caption=expression('non-regularized '~R[emp])) + 
  coord_fixed() + 
  coord_fixed() + geom_abline(slope = -1, intercept=0, colour="white", 
                              linetype="dashed", size=2)
plot_reg <- ggplot(res) +
  geom_raster(aes(x=Var1, y=Var2, fill=r_emp)) + 
  geom_contour(aes(x=Var1, y=Var2, z=r_reg), colour="white") + 
  xlab(expression(theta[1])) +
  ylab(expression(theta[2])) +
  labs(fill=expression(R[reg]), caption=expression('L2 regularized '~R[emp])) + 
  coord_fixed() + geom_abline(slope = -1, intercept=0, colour="white", 
                              linetype="dashed", size=2)


grid.arrange(plot_emp, plot_reg, ncol=2) 

##############################################



