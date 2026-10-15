## regression plot simple
data <- data.frame("Groesse" = c(9, 4, 8, 5, 1, 1.5, 8, 8, 6.5,
                                 1.5),
                   "Gewicht" = c(14, 4, 15.5, 9.5, 1, 2, 16.5, 9, 18.5, 8.5))

reg_plot <- ggplot(data = data, mapping = aes(x = Groesse, y = Gewicht),show.legend = TRUE) + 
  geom_point(size = 4) +
  geom_smooth(method = "lm", se = FALSE) + labs(color = "") +
  xlab("x") + ylab("y") + theme(axis.text=element_text(size=16),axis.title=element_text(size=30,face="bold"))

model <- lm(Gewicht ~ Groesse, data = data)

predictions <- predict.lm(model, newdata = list("Groesse" = data$Groesse))
diff_y <- predictions - data$Gewicht
y_loss_max <- c(data$Gewicht[diff_y < 0], predictions[which(diff_y > 0)])
y_loss_min <- c(predictions[which(diff_y < 0)], data$Gewicht[diff_y > 0])
x_loss_min <-  data$Groesse[c(which(diff_y < 0),which(diff_y > 0) )]
x_loss_max <- abs(x_loss_min + (y_loss_max - y_loss_min))

reg_risk <- reg_plot +
  #geom_abline(color = "blue", intercept = coef(lm(Gewicht ~ Groesse, data = data))[[1]], 
  #           slope = coef(lm(Gewicht ~ Groesse, data = data))[[2]], 
  #          linewidth = 1) + labs(color = "") +
  annotate("text", x = 11, y = 2, size = 6, label = "bold(R)[emp](f) == 125.90",
           parse = TRUE) +
  annotate("rect", xmin = x_loss_min, xmax = x_loss_max, 
           ymin = y_loss_min, ymax = y_loss_max,
           alpha = .1,fill = "blue") + scale_x_continuous(limits=c(0, 14)) + 
  scale_y_continuous(limits=c(0, 20))

ggsave(filename = "figure/nutshell-ml-basics-empirical-risk-regression.png", 
       plot = reg_risk , width = 16, height = 11, units = "in")