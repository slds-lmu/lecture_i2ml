#### Linear constraints plot

# a functions that draws a circle
circle = function(center = c(0,0), diameter = 2, npoints = 100){
  r = diameter / 2
  tt = seq(0,2*pi,length.out = npoints)
  xx = center[1] + r * cos(tt)
  yy = center[2] + r * sin(tt)
  return(data.frame(x1 = xx, x2 = yy))
}

# first plot for violated constraints
dat = circle()
#geom_path will do open circles, geom_polygon will do filled circles
plot = ggplot(dat,aes(x1,x2)) + scale_x_continuous(limits = c(-1.5, 2.5)) + scale_y_continuous(limits = c(-2, 2))
# fixing the axes
plot = plot + coord_fixed(ratio = 1, xlim = NULL, ylim = NULL, expand = TRUE)
plot = plot + theme(legend.position="none", axis.text=element_text(size=12), axis.title=element_text(size=12)) 
# drawing the circle
plot = plot + geom_path(color = "darkred", size = 1) + annotate("text", x = 0.5, y = -1.2, label = "x[1]^{2} + x[2]^{2} == 1 ", parse = TRUE, color = "darkred")
plot = plot + geom_abline(intercept = 2, slope = -1, color = "#666666", size = 1) + annotate("text", label ="x[1] + x[2] == 2", x = -0.2, y = 1.7, parse = TRUE, color = "#666666")
plot = plot + geom_abline(intercept = 3, slope = -1, color = "#666666", size = 1) + annotate("text", label ="x[1] + x[2] == 3", x = 2, y = 1.5, parse = TRUE, color = "#666666")
plot = plot + geom_segment(aes(x = 1.5, y = 1.5, xend = 1, yend = 1), colour = "#999999", arrow = arrow(length = unit(0.03, "npc")), lwd = .5)
plot
ggsave("figure_man/optimization/constraints_violated.pdf")


# second plot for satisfied constraints
dat = circle()
#geom_path will do open circles, geom_polygon will do filled circles
plot = ggplot(dat,aes(x1,x2)) + scale_x_continuous(limits = c(-1.5, 2.5)) + scale_y_continuous(limits = c(-2, 2))
# fixing the axes
plot = plot + coord_fixed(ratio = 1, xlim = NULL, ylim = NULL, expand = TRUE)
plot = plot + theme(legend.position="none", axis.text=element_text(size=12), axis.title=element_text(size=12)) 
# drawing the circle
plot = plot + geom_path(color = "darkred", size = 1) + annotate("text", x = 0.5, y = -1.2, label = "x[1]^{2} + x[2]^{2} == 1 ", parse = TRUE, color = "darkred")
plot = plot + geom_abline(intercept = 0, slope = -1, color = "slateblue", size = 1) + annotate("text", label ="x[1] + x[2] == 0", x = -0.5, y = -0.1, parse = TRUE, color = "slateblue")
plot = plot + geom_abline(intercept = 1, slope = -1, color = "slateblue", size = 1) + annotate("text", label ="x[1] + x[2] == 1", x = 0.5, y = 1.2, parse = TRUE, color = "slateblue")
plot = plot + geom_segment(aes(x = 0, y = 0, xend = .5, yend = .5), colour = "slateblue", arrow = arrow(length = unit(0.03, "npc")), lwd = .5)
plot
ggsave("figure_man/optimization/constraints_satisfied.pdf")


# second plot for satisfied constraints
dat = circle()

#geom_path will do open circles, geom_polygon will do filled circles
plot = ggplot(dat,aes(x1,x2)) + scale_x_continuous(limits = c(-1.5, 2.5)) + scale_y_continuous(limits = c(-2, 2))

# fixing the axes
plot = plot + coord_fixed(ratio = 1, xlim = NULL, ylim = NULL, expand = TRUE)
plot = plot + theme(legend.position = "none", axis.text = element_text(size = 12), axis.title = element_text(size = 12)) 

# drawing the circle
plot = plot + geom_path(color = "darkred", size = 1) + annotate("text", x = 0.5, y = -1.2, label = "x[1]^{2} + x[2]^{2} == 1 ", parse = TRUE, color = "darkred")
plot = plot + geom_abline(intercept = 1.42, slope = -1, color = "green3", size = 1) + annotate("text", label = "x[1] + x[2] == 1.41", x = 1.9, y = 0.3, parse = TRUE, color = "green3")
plot = plot + geom_point(x = 1.41/2, y = 1.41/2, color = "green3", shape = 1)
plot = plot + geom_segment(aes(x = 1.41/2, y = 1.41/2, xend = 1.5, yend = 1.5), colour = "darkred", arrow = arrow(length = unit(0.03, "npc")), lwd = .6)
plot = plot + geom_segment(aes(x = 1.41/2 + 0.02, y = 1.41/2 - 0.02, xend = 1.22, yend = 1.18), colour = "green3", arrow = arrow(length = unit(0.03, "npc")), lwd = .6)
plot
ggsave("figure_man/optimization/constraints_opt.pdf")

