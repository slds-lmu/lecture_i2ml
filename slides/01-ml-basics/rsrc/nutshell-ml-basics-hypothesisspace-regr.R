library(ggplot2)
## regression plot simple
data <- data.frame("Groesse" = c(9, 4, 8, 5, 1, 1.5, 8, 8, 6.5,
                                 1.5),
                   "Gewicht" = c(14, 4, 15.5, 9.5, 1, 2, 16.5, 9, 18.5, 8.5))


reg_plot <- ggplot(data = data, mapping = aes(x = Groesse, y = Gewicht),show.legend = TRUE) + 
  geom_point(size = 4) +
  geom_smooth(method = "lm", se = FALSE) + labs(color = "") +
  xlab("x") + ylab("y") + theme(axis.text=element_text(size=16),axis.title=element_text(size=30,face="bold"))

hyp_reg <- reg_plot +
  geom_abline(color = "skyblue1", intercept = 5, 
              slope = 0.8,
              linewidth = 0.4, alpha = 0.8) + 
  geom_abline(color = "skyblue1",intercept = 10, 
              slope = - 0.7, 
              linewidth = 0.4, alpha = 0.8) +
  geom_abline(color = "skyblue1", intercept = - 1, 
              slope = 2, 
              linewidth = 0.4, alpha = 0.8) +
  geom_abline(color = "skyblue1", intercept = - 2, 
              slope = 2.5, 
              linewidth = 0.4, alpha = 0.8) +
  geom_abline(color = "skyblue1", intercept = 4.5, 
              slope = 0.7,
              linewidth = 0.4, alpha = 0.8) +
  geom_abline(color = "skyblue1", intercept = 0.8, 
              slope = 1.7, 
              linewidth = 0.4, alpha = 0.8) 

ggsave(filename = "figure/nutshell-ml-basics-hypothesisspace-regr.png", 
       plot = hyp_reg , width = 16, height = 11, units = "in")