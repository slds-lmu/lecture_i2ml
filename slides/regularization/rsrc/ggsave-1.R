
library(knitr)
library(mlr)
library(mlbench)
library(ggplot2)
library(tidyr)
library(colorspace)
library(gridExtra)
library(BBmisc)
library(reshape)


load("data/ozone_example.RData")

dfp =df_incdata[nobs == 50, ]

p = ggplot(data = dfp, aes(x = 0, y = value, fill = variable))
p = p + geom_boxplot() + labs(colour = " ")
p = p + scale_colour_discrete(labels = c("Train error", "Test error"))
p = p + xlab(" ") + ylab("Mean Squared Error")
p = p + ylim(c(0, 400)) + theme(axis.title.x=element_blank(),
                                axis.text.x=element_blank(),
                                axis.ticks.x=element_blank()) +
  scale_fill_brewer(palette="Dark2")
p
######################################################

library(data.table)

dfp = setDT(df_incdata)[, .(mean.mse = median(value)), by = c("nobs", "variable")]

p = ggplot(data = dfp, aes(x = nobs, y = mean.mse, colour = variable))
p = p + geom_line(lwd = 1.2) + ylim(c(0, 100)) + labs(colour = " ")
p = p + scale_colour_discrete(labels = c("Train error", "Test error"))
p = p + xlab("Size of data set") + ylab("MSE") +
  scale_color_brewer(palette="Dark2")
p
######################################################
load("data/ozone_example.RData")

p = ggplot(data = df_incfeatures, aes(x = type, y = mean.mse, colour = variable))
p = p + geom_line(lwd = 1.2) + labs(colour = " ")
p = p + scale_colour_discrete(labels = c("Train error", "Test error"))
p = p + xlab("Number of features") + ylab("Mean Squared Error")
p = p + ylim(c(0, 150))
p = p + scale_x_continuous(breaks = 0:12) 
p = p + scale_color_brewer(palette="Dark2")
p
######################################################

load("rsrc/early_stopping1.RData")

o_data$type <- factor(o_data$type, levels=c("train", "test"))

p1 <- ggplot(o_learn, aes(x = id, y = value)) +
  geom_line(aes(colour = variable), lwd = 1.2) +
  geom_vline(xintercept = best_it, linetype = "solid", lwd = 2,
             colour="darkgrey") +
  geom_vline(xintercept = max_it, lwd = 2, colour="darkgrey",
             linetype = "dashed") +
  annotate("label", x = 30, y = 180, label = "stopped early") +
  annotate("label", x = 4e5, y = 180, label = "overfitted") +
  scale_x_log10() + 
  xlab("Iterations") +
  ylab("Mean Squared Error") +
  labs(colour = " ")  +
  theme(legend.position="bottom") +
  scale_color_brewer(palette="Dark2")

p2 <- ggplot(o_data, aes(x=V8*100, y=V4)) + 
  geom_point(data=o_data, aes(colour=type, alpha=type)) +
  scale_alpha_manual(values = c(1, 0.2), guide = "none") + 
  geom_line(data=o_fit, aes(linetype=variable, x=x, y=value), alpha = 1,
            lwd = 2, colour="darkgrey") +
  scale_linetype_manual(values = c("dashed", "solid")) +
  xlab("Temperature (degrees F)") +
  ylab("Ozone level") +
  theme(legend.position="bottom") +
  guides(linetype = FALSE) +
  # scale_alpha(guide = "none") + 
  labs(colour = " ") +
  scale_color_brewer(palette="Dark2")

grid.arrange(p1, p2, ncol=2)
###################################################



