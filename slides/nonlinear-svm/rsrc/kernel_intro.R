# introduction plots for kernels with explicit feature maps

library("scatterplot3d")
library(geomnet)
set.seed(1234)

# function to draw a circle with noise
circleFun = function(center = c(0, 0), diameter = 1, npoints = 100, sd = 0.05){
  r = diameter / 2
  tt = seq(0, 2 * pi, length.out = npoints)
  xx = center[1] + r * cos(tt) + rnorm(npoints, 0, sd)
  yy = center[2] + r * sin(tt) + rnorm(npoints, 0, sd)
  return(data.frame(x = xx, y = yy))
}

# two classes: circle with diameter 1, circle with diameter 2
x1 = circleFun( c(0, 0), diameter = 1, npoints = 50)
x2 = circleFun( c(0, 0), diameter = 2, npoints = 50)
class = as.factor(c(rep(1, 50), rep(2, 50)))
df = data.frame(x1 = c(x1$x, x2$x), x2 = c(x1$y, x2$y), class = class)
colors = c('#00BFC4', '#F8766D')
colors = colors[as.numeric(df$class)]

plot = ggplot(data = df, aes(x = x1, y = x2, col = colors)) + theme_bw()
plot = plot + geom_point() + theme(legend.position = "none") 
plot
ggsave("figure_man/kernels/kernel_intro_1.pdf")


# mapping the circle to 3D
y = df$x1^2 + df$x2^2
df = cbind(df, y)

scatterplot3d(df[, c(1, 2, 4)], pch = 16, color=colors, angle = 55, xlab = expression(x[1]), ylab = expression(x[2]), zlab = "y")
ggsave("figure_man/kernels/kernel_intro_2.pdf")

# drawing a separating hyperplane
s3d = scatterplot3d(df$x1[y < 0.62], df$x2[y < 0.62], y[y < 0.62], zlim = range(y), xlim = range(df$x1), ylim = range(df$x2), color = '#00BFC4', pch = 20, angle = 55, xlab = expression(x[1]), ylab = expression(x[2]), zlab = "y")
s3d$plane3d(0.6, 0, 0,  lty.box = "solid", col = "black", draw_polygon = TRUE, polygon_args = list(col = rgb(0.745098, 0.745098, 0.745098,0.8)))
s3d$points3d(df$x1[y > 0.62], df$x2[y > 0.62], y[y > .62], pch = 20, col = '#F8766D')
ggsave("figure_man/kernels/kernel_intro_3.pdf")


# projecting it back to the 2D setting
plot = plot + geom_circle(aes(x = 0, y = 0), radius=0.6^2, col = "darkgreen", alpha = 0.8)
plot
ggsave("figure_man/kernels/kernel_intro_4.pdf")

