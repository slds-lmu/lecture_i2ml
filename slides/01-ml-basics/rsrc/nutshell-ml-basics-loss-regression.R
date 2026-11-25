library(ggplot2)
## regression plot simple
data <- data.frame("Groesse" = c(9, 4, 8, 5, 1, 1.5, 8, 8, 6.5,
                                 1.5),
                   "Gewicht" = c(14, 4, 15.5, 9.5, 1, 2, 16.5, 9, 18.5, 8.5))

reg_plot <- ggplot(data = data, mapping = aes(x = Groesse, y = Gewicht),show.legend = TRUE) + 
  geom_point(size = 4) +
  geom_smooth(method = "lm", se = FALSE) + labs(color = "") +
  xlab("x") + ylab("y") + theme(axis.text=element_text(size=16),axis.title=element_text(size=30,face="bold"))

model <- lm(Gewicht ~ Groesse, data = data)

reg_loss <- reg_plot +
  annotate("text", x = 7, y = 2, size = 6, label = "bold(L)(y, f(4)) ==~ (4 - 7.86)^{2} == 14.87",
           parse = TRUE) +
  theme(axis.text=element_text(size=16),axis.title=element_text(size=30,face="bold")) +
  annotate("rect", xmin = 4, xmax = 4 + (predict.lm(model,
                                                    newdata = list("Groesse" = c(4)))[[1]] - 4),
           ymin = 4, ymax = predict.lm(model, newdata = list("Groesse" = c(4)))[[1]],
           alpha = .1,fill = "blue" ) + scale_x_continuous(limits=c(0, 10)) + 
  scale_y_continuous(limits=c(0, 20))

ggsave(filename = "figure/nutshell-ml-basics-loss-regression.png", 
       plot = reg_loss , width = 16, height = 11, units = "in")