source("loss_functions.R")

df = data.frame(res = seq(-10, 10, length.out = 800))

losses = list(
  "C2" = function(res) Huber(res, c = 2),
  "C1" = function(res) Huber(res, c = 1),
  "C05" = function(res) Huber(res, c = 0.5)
)

p = plotLoss(df, losses)
p = p + scale_color_viridis_d(
  end = 0.9,
  name = bquote(delta), 
  labels = c(2, 1, 0.5))
p

ggsave(filename = "loss_huber_plot2.png", path = "figure_man", width = 4, height = 3)