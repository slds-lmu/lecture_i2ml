## Plotting a Gaussian Kernels over data points for a certain task

library(mlr)
library(ggplot2)
library(kernlab)

set.seed(1234)
makeSimulatedTask = function(size) {
  x1 = c(rnorm(size, mean = 0))
  x2 = c(rnorm(size, mean = 0))
  y = factor(sample(c(0, 1), size, replace = TRUE))
  sim.df = data.frame(x1 = x1, x2 = x2, y = y)
  makeClassifTask("simulated example", data = sim.df, target = "y")
}

kernel_gauss =  function(x, sigma) { exp(- x ^ 2 / (2 * sigma^2)) }

tsk = makeSimulatedTask(10)

plotKernelFunctions = function(tsk, sigma) {
  df = getTaskData(tsk)
  
  xx = seq(-4, 4, by = 0.01) 
  dfnew = data.frame()
  
  for (i in 1:nrow(df)){
    temp_df = data.frame(x = xx, y = ifelse(df[i, 1] - 1 - 3 * sigma < xx & xx < df[i, 1] + 1 + 3 * sigma , kernel_gauss(xx - df[i, 1], sigma) + df[i, 2] , NA), col = df[i, 3], gr = i)
    dfnew = rbind(dfnew, temp_df)
  }
  
  g = ggplot() + geom_point(aes(x = x1, y = x2, colour = y), data = df, size = 4) + scale_x_continuous(limits = c(-3, 2))

  
  
  g = g + geom_path(aes(x = x, y = y, group = gr, colour = col), data = dfnew, size = 1) + theme_bw() + theme(legend.position="none")
  g
}

plotKernelFunctions(tsk, 0.1)
ggsave("figure_man/kernels/sigest_narrow.pdf")

plotKernelFunctions(tsk, 1.5)
ggsave("figure_man/kernels/sigest_wide.pdf")


# Plotting the histogram

tsk = makeSimulatedTask(50)
tsk_data = getTaskData(tsk)[, 1:2]
x_dist = data.frame(x = as.vector(dist(tsk_data)))

plot = ggplot(data = x_dist, aes(x = x)) + geom_histogram(aes(y = ..density..), binwidth = 0.15)

# calculating the quantiles and adding them to the plot
quant = quantile(x_dist[x_dist != 0], probs=c( 0.9, 0.5, 0.1))
sigest = mean(quant)
plot = plot + geom_vline(xintercept = quant, color = "darkgrey", size = 1) 

# changing axes
plot = plot + xlab("distance") 
plot = plot + scale_x_discrete(limits = quant, label = c(expression(q[0.9]), expression(q[0.5]), expression(q[0.1])))
plot = plot + theme_bw(base_size = 22)

ggsave("figure_man/kernels/sigest_hist.pdf")


