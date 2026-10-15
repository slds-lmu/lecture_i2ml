# ------------------------------------------------------------------------------
# FIG: ROC HORIZONTAL (STEP BY STEP)
# ------------------------------------------------------------------------------

library("ggplot2")
library("viridis")
library("glue")

# DATA -------------------------------------------------------------------------

df <- data.frame(
  Truth = c("Pos", "Pos", "Pos", "Neg", "Pos", "Neg", "Pos", "Neg", "Neg", "Neg", "Pos", "Neg"),
  Score = c(0.95, 0.86, 0.69, 0.65, 0.59, 0.52, 0.51, 0.39, 0.28, 0.18, 0.15, 0.06)
)

c_list <- c(0.9, 0.85, 0.66, 0.6, 0.55, 0.3, 0)

# PLOTS ------------------------------------------------------------------------

generate_roc_horizontal <- function(c = 0.8) {
  p <- ggplot(data = df, aes(x = Score, y = 0, color = Truth, shape = Truth)) +
    geom_segment(aes(x = 0, y = 0, xend = 1, yend = 0), color = "black")

  for (tick in seq(from = 0, to = 1, by = 0.25)) {
    p <- p +
      geom_segment(x = tick, y = 0.03, xend = tick, yend = -0.02, color = "black") +
      geom_text(label = tick, x = tick, y = -0.05, color = "black", size = 5)
  }

  colors = viridis_pal(end = 0.9)(2)
  p <- p +
    geom_rect(aes(xmin = 0, xmax = c, ymin = -0.08, ymax = 0.08), linetype = 0, alpha = 0.01, fill = colors[1]) +
    geom_rect(aes(xmin = c, xmax = 1, ymin = -0.08, ymax = 0.08), linetype = 0, alpha = 0.01, fill = colors[2]) +
    geom_segment(aes(x = c, y = 0.08, xend = c, yend = -0.08), color = "orange") +
    geom_text(label = "c", x = c + 0.015, y = -0.06, color = "orange", size = 10) +
    geom_point(size = 5) +
    geom_text(label = expression(pi), x = 1, y = 0.06, color = "black", size = 10) +
    scale_x_continuous(expand=c(0.01,0)) +
    scale_y_continuous(expand=c(0.02,0)) +
    theme(axis.line=element_blank(),
          axis.text.x=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks=element_blank(),
          axis.title.x=element_blank(),
          axis.title.y=element_blank(),
          legend.background=element_blank(),
          legend.position="right",
          legend.text=element_text(size=15),
          legend.title=element_text(size=15),
          panel.background=element_blank(),
          panel.border=element_blank(),
          panel.grid.major=element_blank(),
          panel.grid.minor=element_blank(),
          plot.background=element_blank(),
          plot.margin=grid::unit(c(0,0,0,0), "in")
    ) +
    scale_color_viridis(discrete = TRUE, end = 0.9)

  p
}

for (i in 1:length(c_list)) {
  p <- generate_roc_horizontal(c_list[i])
  ggsave(filename = glue("../figure/roc_horizontal_step_{i}.png"), plot = p, width = 8, height = 1.5)
}
