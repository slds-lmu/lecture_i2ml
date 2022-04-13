
library(knitr)
library(qrmix)
library(quantreg)
library(reshape2)
library(mvtnorm)
library(data.table)
library(ggpubr)

theme_set(theme_bw())

source("optimal_constant_model.R")

x = runif(50, -2, 2)
df = data.frame(x = x, y = rnorm(50, mean = 0, sd = 0.5))

# manually add an outlier
df_outlier = rbind(df, data.frame(x = -1.8, y = 100))


#############################################
#L2-loss
p = plotConstantModel(df, loss_type = "L2")
p

ggsave("../figure/L2-loss.png", width = 4, height = 3)


#############################################
#L1-loss 
p = plotConstantModel(df, loss_type = c("L1"))
p

ggsave("../figure/L1-loss.png", width = 4, height = 3)


#############################################
#L1-loss vs. L2-loss
p = plotConstantModel(df, loss_type = c("L1", "L2"))
p

ggsave("../figure/l1_vs_l2.png", width = 4, height = 3)

#############################################

p1 = plotConstantModel(df_outlier, loss_type = c("L1", "L2"))
p1 = p1 + ggtitle("Manually adding an outlier")
p2 = p1 + ylim(c(-3, 3)) + ggtitle("Zoomed to -3 < y < 3")  
ggarrange(p1, p2, nrow = 1, common.legend = TRUE, legend = "top")

#############################################
#Huber
p1 = plotConstantModel(df_outlier, loss_type = c("L1", "L2", "Huber1"))
p1 = p1 + ggtitle("Manually adding an outlier")
p2 = p1 + ylim(c(-3, 3)) + ggtitle("Zoomed to -3 < y < 3")  
ggarrange(p1, p2, nrow = 1, common.legend = TRUE, legend = "top")

ggsave("../figure/Huber1.png", width = 7, height = 4)


#############################################

# Log Barrier
p = plotConstantModel(df, loss_type = c("L1", "L2", "log_barrier"), a = 1)
p = p + ylim(c(-0.5, 0.5))
p

ggsave("../figure/log_barrier1.png", width = 7, height = 4)

p = plotConstantModel(df, loss_type = c("L1", "L2", "log_barrier"), a = 2)
p = p + ylim(c(-0.5, 0.5))
p

ggsave("../figure/log_barrier2.png", width = 7, height = 4)


# Log barrier

p1 = plotConstantModel(df, loss_type = c("L1", "L2", "log_barrier"), a = 1)
p1 = p1 + ggtitle("Not Feasible for a = 1")
p2 = plotConstantModel(df, loss_type = c("L1", "L2", "log_barrier"), a = 2)
p2 = p2 + ggtitle("Feasbile for a = 2") # + ylim(c(-0.5, 0.5))
ggarrange(p1, p2, nrow = 1, common.legend = TRUE, legend = "top")

ggsave("../figure/log_barrier_2_1.png", width = 7, height = 5)




#############################################

p1 = plotConstantModel(df_outlier, loss_type = c("L1", "L2", "Huber1"))
p1 = p1 + ggtitle("Manually adding an outlier")
p2 = p1 + ylim(c(-2, 2)) + ggtitle("Zoomed to -2 < y < 2")  
ggarrange(p1, p2, nrow = 1, common.legend = TRUE, legend = "top")

ggsave("../figure_man/Huber-outlier.png", width = 7, height = 3)
