library(ISLR)
library(purrr)
library(gridExtra)
# To save plotly-based figures to static images, plotly uses the kaleido python
# library, which is accessed via reticulate. You might need to run:
if (FALSE) {
  install.packages("reticulate")
  reticulate::install_miniconda()
  reticulate::conda_install("r-reticulate", "python-kaleido")
  reticulate::conda_install("r-reticulate", "plotly", channel = "plotly")
  reticulate::use_miniconda("r-reticulate")
}
# R might throw an error about not finding the `sys` library -- circumvent with
if (FALSE) reticulate::py_run_string("import sys")

source("libfuns_lm.R")

credit_data <- Credit
credit_data <- credit_data[, c("Rating", "Age","Income",  "Limit", "Balance")]
credit_data$Limit <- credit_data$Limit
credit_data$Balance <- credit_data$Balance*2
set.seed(1)
rows <- rdunif(10, 0, 400)
data <- credit_data[c(rows),c("Limit", "Balance")]
data <- data[-c(2),]
lm_univariate <- lm(Balance ~ Limit, data = data)
data$residual <- lm_univariate$residuals
data$Balance_hat <- predict(lm_univariate)
lm_univariate$data<- data



# LOSS PLOT L2 --------------------------------------------------------------------

lm_univ_quad <- readRDS("lm_univariate_quadratic.Rds")

idx_highlight <- c(19, 49)
residuals_highlight <- lm_univ_quad$data$residual[idx_highlight]
loss_fun <- function(x) x**2

plot_loss <- LossPlotter$new(seq(-1.5, 1.5, by = 1))
plot_loss$initLayer()
plot_loss$addLossCurve("l2", loss_fun, col = "black")
plot_loss$addAnnotation(loss_fun, residuals_highlight, linetype = 2, linewidth = 2)
plot_loss$addAnnotation(loss_fun, residuals_highlight, type = "point", linewidth = 2)
plot_loss$addAnnotation(
  loss_fun, residuals_highlight, type = "text", nudge_x = 0.6, size = 12
)

plot <- plot_loss$plot()
plot <- plot + theme(axis.text=element_text(size=20),axis.title=element_text(size=30,face="bold"))

ggsave(filename = "figure/nutshell-regression-L2.pdf", 
       plot = plot , width = 8, height = 8, units = "in")




x=0
f=expression (x^2)
dx=D(f,'x')
y1=eval(f)
m=eval(dx)
x1=x
a=y1-(m*x1)
b=m
xs = c(-1,1)
beta = c(a, b)
ys = cbind(1, xs) %*% beta

plot_loss <- LossPlotter$new(seq(-2, 2, by = 1))
plot_loss$initLayer()
plot_loss$addLossCurve("l2", loss_fun, col = "black")
loss_plot <- plot_loss$plot()

loss_plot <- loss_plot +  
  # geom_abline(color = "blue", intercept = a, 
  #                                     slope = b,
  #                                     linewidth = 1, alpha = 1) +
  annotate("text", x = 1.5, y = 0.9, size = 10, label = expression(paste(partialdiff,"L","/",partialdiff,theta, "="))) +
  annotate("text", x = 1.5, y = 0.6, size = 10, label = expression(paste("(y - ", theta^T, "x)", x^T, "=", 0))) +
  geom_segment(aes(x = xs[1], xend = xs[2], y = ys[1], yend = ys[2]),
               colour = "red",lty = "dashed", linewidth = 2) + 
                          xlab(expression(paste("y - ", theta^T, "x"))) +
                          ylab(expression(paste("L(", theta^T, "x, y)"))) +
  theme(axis.text=element_text(size=20),axis.title=element_text(size=30,face="bold"))

ggsave(filename = "figure/nutshell-regression-derivative-L2.pdf", 
       plot = loss_plot , width = 8, height = 8, units = "in")


# REGRESSION PLOT L2 --------------------------------------------------------------

regr_plot_L2 <- ggplot(data = data, mapping = aes(x = Limit, y = Balance),show.legend = TRUE) + 
  geom_point(size = 4) +
  geom_abline(color = "blue", intercept = lm_univariate$coefficients[1], 
              slope = lm_univariate$coefficients[2],
              linewidth = 1, alpha = 1) 


regr_plot_L2 <- regr_plot_L2 +
  theme(axis.text=element_text(size=16),axis.title=element_text(size=30,face="bold")) +
  annotate("text", x = 7000, y = 230, size = 7, label = "bold(L)(y, f(x)) ==~ (0 - 436)^{2} == 190096",
           parse = TRUE)+
  annotate("rect", xmin = data$Limit[2], xmax = data$Limit[2] + (predict.lm(lm_univariate,
                                                    newdata = list("Limit" = c(data$Limit[2])))[[1]] - data$Balance[2]),
           ymin = data$Balance[2], ymax = predict.lm(lm_univariate, newdata = list("Limit" = c(data$Limit[2])))[[1]],
           alpha = 1,fill = "orange") + scale_x_continuous(limits=c(0, 9700)) + 
  scale_y_continuous(limits=c(0, 1450)) +  xlab("Limit") + ylab("Balance")

ggsave(filename = "figure/nutshell-regression-L2-regr-line.pdf", 
       plot = regr_plot_L2 , width = 8, height = 8, units = "in")



# LOSS PLOT L1 ---------------------------------------------------------------------

my_l1 <- function(x, Xmat, y) sum(abs(Xmat %*% x - y))
loss_cols <- c("blue", "darkorange")

lm_univ <- list(
  readRDS("lm_univariate_absolute.Rds"),
  readRDS("lm_univariate_quadratic.Rds")
)

loss_funs <- list(function(x) abs(x), function(x) x**2)
residuals_highlight <- lm_univ[[2]]$data$residual[idx_highlight]

plot_loss <- LossPlotter$new(seq(-1.5, 1.5, by = 1))
plot_loss$initLayer()
plot_loss$addLossCurve("l1", loss_funs[[1]], col = "black")
plot_loss$addAnnotation(loss_funs[[1]], residuals_highlight, linetype = 2, linewidth = 2)
plot_loss$addAnnotation(loss_funs[[1]], residuals_highlight, type = "point", linewidth = 2)
plot_loss$addAnnotation(
  loss_funs[[1]], residuals_highlight, type = "text", nudge_x = 0.6, size = 12
)

plot <- plot_loss$plot()
plot <- plot + theme(axis.text=element_text(size=20),axis.title=element_text(size=30,face="bold"))

ggsave(filename = "figure/nutshell-regression-L1.pdf", 
       plot = plot , width = 8, height = 8, units = "in")


# REGRESSION PLOT L1

loss = function(y, yhat){
  sum(abs(y - yhat))
}

fn = function(par){
  a = par[1]
  b = par[2]
  loss(y = data$Balance, yhat = (a + b * data$Limit))
}

set.seed(1)
par = optim(
  par = c(a = 0, b = 0),
  fn = fn
)$par


data$Balance_hat <- c(par[1] + par[2] * data$Limit)

L1_regr_plot <- ggplot(data = data, mapping = aes(x = Limit, y = Balance),show.legend = TRUE) + 
  geom_point(size = 4)

L1_regr_plot <- L1_regr_plot + geom_abline(color = "blue", intercept = par[1], 
                           slope = par[2],
                           linewidth = 1, alpha = 1) + 
  theme(axis.text=element_text(size=16),axis.title=element_text(size=30,face="bold")) +
  annotate("text", x = 6000, y = 180, size = 7, label = "bold(L)(y, f(x)) ==~ abs(0 - 292) == 292",
           parse = TRUE) +
  annotate("segment", x = data$Limit[2], xend = data$Limit[2], y = data$Balance[2], 
           yend =  data$Balance_hat[2] ,
           alpha = 1, colour = "orange", lwd = 2) + scale_x_continuous(limits=c(0, 9700)) + 
  scale_y_continuous(limits=c(0, 1450)) +  xlab("Limit") + ylab("Balance")


ggsave(filename = "figure/nutshell-regression-L1-regr-line.pdf", 
       plot = L1_regr_plot , width = 8, height = 8, units = "in")


# Polynomial plots
polynomial_plots <- function(degree0){
  poly_data = lm(
    Balance ~ poly(Limit, degree = degree0), data = data
  )
  
  poly_plot <- effect_plot(
    poly_data, 
    pred = Limit, 
    data = data, 
    plot.points = TRUE,
    interval = FALSE, 
    line.color = "blue", 
    y.label = "Balance",
    x.lab  = "Limit", 
    point_size = 1
  )
  
  poly_plot <- poly_plot +  theme(axis.text=element_text(size=20),axis.title=element_text(size=30,face="bold"))
  
  return(poly_plot)
  
}


plot_list <- lapply(list(1,2,3), polynomial_plots)

ggsave(filename = "figure/nutshell-regression-poly-plot-1.pdf", 
       plot = plot_list[[1]] , width = 8, height = 8, units = "in")

ggsave(filename = "figure/nutshell-regression-poly-plot-2.pdf", 
       plot = plot_list[[2]] , width = 8, height = 8, units = "in")

ggsave(filename = "figure/nutshell-regression-poly-plot-3.pdf", 
       plot = plot_list[[3]] , width = 8, height = 8, units = "in")


