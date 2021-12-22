source("../../advriskmin/rsrc/helpers/loss_functions.R")
library(viridis)
library(ggplot2)

df = data.frame(res = seq(-10, 10, length.out = 800))

losses = list(
  "2" = function(res) Huber(res, c = 2),
  "0.5" = function(res) Huber(res, c = 0.2)
)

p <- plotLoss(df, losses) + 
  theme(plot.title = element_text(hjust = 0.5)) +
  ggtitle("Huber Loss") +
  xlim(c(-3,3)) +
  ylim(c(0,3.5)) +
  xlab(expression(paste( y - f(bold(x)) ))) +
  ylab(expression(paste("L(",y, ",", y - f(bold(x)), ")"))) +
  geom_segment(aes(x=-Inf,xend=Inf,y=2,yend=2), color = "#481567FF", linetype = "dashed"  ) +
  geom_segment(aes(x=0,xend=2,y=2,yend=2), size = 1,  color = "#2D708EFF" ) +
  annotate(geom = 'text', x = 0.6, y = 1.9, label = expression(paste(delta, ""=="",2)), hjust = 0, vjust = 1, parse = TRUE, color = "#2D708EFF") +
  annotate(geom = 'text', x = -0.8, y = 1.6, label = expression(paste(frac(1,2), " ",y-f(bold(x))^2)), hjust = 0, vjust = 1, parse = TRUE, color = "#481567FF", size =4) +
  annotate(geom = 'text', x = -1.4, y = 3.4, label = expression(paste(delta, "|", y - f(bold(x)), "| ",""-"", frac(1,2)," ", delta^2)), hjust = 0, vjust = 1, parse = TRUE, size = 4, color = "#481567FF") +
  #annotate(geom = 'text', x = 2.5, y = 1.75, label = expression(paste("|", y - f(bold(x)), "|", ""<="",  delta)), hjust = 0, vjust = 1, parse = TRUE, color = "#481567FF") +
  #annotate(geom = 'text', x = 2.5, y = 2.5, label = expression(paste("|", y - f(bold(x)), "|", "">"",  delta)), hjust = 0, vjust = 1, parse = TRUE, color = "#481567FF") +
  scale_colour_viridis_d(end=0.9, name = expression(delta), labels = c(2,0.2)) 
  

p

ggsave(filename = "fig-loss-huber-delta.png", path="../figure", width = 3.5, height = 2.1)
##############################p

#ggsave(filename = "loss_huber_delta.png", path = "figure_man", width = 200, height = 100, units = "mm")#


