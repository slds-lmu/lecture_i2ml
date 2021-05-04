# Hyperplane in 2D - positive and negative halfspace

set.seed(1123)
x = runif(15)
y = runif(15)
z = ifelse(x + y - 1 > 0, "+", "-")

df = data.frame(x = x, y = y, z = as.factor(z))
p = ggplot(data = df,aes(x = x, y = y,shape = z, color = z)) + geom_point(color = "white", size = 0.2)
p = p + geom_text(aes(label = z),hjust = 0, vjust = 0, size = 12) + theme(legend.position = "none", axis.text = element_text(size = 12),
  axis.title=element_text(size = 12)) 
p = p + geom_abline(intercept = 1, slope = -1, lwd = 1) 
p = p + geom_segment(aes(x = 0.5, y = 0.5, xend = 0.65, yend = 0.65, colour = "blue"), arrow = arrow(length = unit(0.03, "npc")), lwd = 1.2)
p = p + annotate("text", x = 0.57, y = 0.53, label = "theta", parse = TRUE, color = "#6699FF", size = 8)
p = p + coord_fixed(ratio = 1, xlim = NULL, ylim = NULL, expand = TRUE) + theme_bw() + theme(legend.position = "none", , axis.text = element_text(size = 12), axis.title = element_text(size = 12))

p

ggsave("figure_man/introduction/hyperplane_posneg.pdf")
