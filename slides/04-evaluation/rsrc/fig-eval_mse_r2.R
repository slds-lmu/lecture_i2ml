library("mlr3")
library("mlr3learners")
library("ggplot2")
library("gridExtra")


set.seed(12)
n = 800
x = seq(0, 1, length.out = n)
y = 1.1*x +  rnorm(length(x), 0, 0.15)

learner = lrn("regr.lm")
task = TaskRegr$new(data.frame(x=x, y=y), target="y", id="example")

learner$train(task)
pred_all = learner$predict(task)$response
lines(x, learner$predict(task)$response)
r2_all = round(cor(pred_all, y)^2, 2)
mse_all = round(sd(pred_all - y)^2, 2)

half_rows = 1:(0.5*n)
y_half = y[1:(0.5*n)]
x_half = x[1:(0.5*n)]
learner$train(task, row_ids = half_rows)
pred_half = learner$predict(task, row_ids = half_rows)$response
r2_half = round(cor(pred_half, y_half), 2)
mse_half = round(sd(pred_half - y_half)^2, 2)

plot_half = ggplot() + geom_point(aes(x=x_half, y=y_half), 
                      data = data.frame(x=x_half, y=y_half),
                      alpha = 0.5) +
  geom_line(aes(x=x, y=y), data = data.frame(x=x_half, y=pred_half),
            colour="blue", size=1.5) + xlim(0, 1) + ylim(-0.5, 1.5) +
  theme(legend.position = "none") + ylab("y") + xlab("x") +
  annotate(geom="label", x=0.75, y=0, 
           label=deparse(bquote(R^2 == .(r2_half))), parse=TRUE,
           fill=NA, label.size = NA) +
  annotate(geom="label", x=0.75, y=-0.2, 
           label=deparse(bquote(MSE == .(mse_half))), parse=TRUE,
           fill=NA, label.size = NA) 

plot_full = ggplot() + geom_point(aes(x=x, y=y, colour=c), data = data.frame(x=x, y=y, 
                                                       c=(1:n < n/2)),
                      alpha = 0.5) +
  geom_line(aes(x=x, y=y), data = data.frame(x=x, y=pred_all),
            colour="blue", size=1.5) + xlim(0, 1) + ylim(-0.5, 1.5) +
    theme(legend.position = "none") + ylab("y") + xlab("x") +
    scale_color_manual(values=c("red", "black")) +
  annotate(geom="label", x=0.75, y=0, 
           label=deparse(bquote(R^2 == .(r2_all))), parse=TRUE,
           fill=NA, label.size = NA) +
  annotate(geom="label", x=0.75, y=-0.2, 
           label=deparse(bquote(MSE == .(mse_all))), parse=TRUE,
           fill=NA, label.size = NA) 

ggsave(grid.arrange(plot_half, plot_full, ncol=2), 
       filename="../figure/eval_mse_r2.pdf", width = 7, height = 2.5)
