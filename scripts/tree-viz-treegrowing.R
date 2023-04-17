source("scripts/tree-viz.R")

py <- ggplot(data = iris,
             aes(.data[["Sepal.Length"]], .data[["Sepal.Width"]],
                 color = .data[["Species"]], 
                 shape = .data[["Species"]])) +
  geom_point() + theme_bw() +
  scale_color_manual(values = c(virginica = "#0CB702", versicolor = "#00A9FF", setosa = "#FF68A1")) 


py <- py + annotate("rect", xmin = -Inf, xmax = Inf, ymin = 2.1, ymax = 2.1, col = "darkblue") +   
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = 2.675, ymax = 2.675, col = "darkblue") + 
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = 3.25, ymax = 3.25, col = "black")   +
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = 3.825, ymax = 3.825, col = "darkblue")   +
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = 4.45, ymax = 4.45, col = "darkblue") +
  theme(legend.position="top")

ggsave("slides/trees/figure_man/tree-growing-y.png", py, units = "cm",
       width = 9.8, height = 9.8)

px <- ggplot(data = iris,
             aes(.data[["Sepal.Length"]], .data[["Sepal.Width"]],
                 color = .data[["Species"]], 
                 shape = .data[["Species"]])) +
  geom_point() + theme_bw() +
  scale_color_manual(values = c(virginica = "#0CB702", versicolor = "#00A9FF", setosa = "#FF68A1")) 


px <- px + annotate("rect", ymin = -Inf, ymax = Inf, xmin = 4.35, xmax = 4.35, col = "darkblue") +   
  annotate("rect", ymin = -Inf, ymax = Inf, xmin = 5.45, xmax = 5.45, col = "black") + 
  annotate("rect", ymin = -Inf, ymax = Inf, xmin = 6.15, xmax = 6.15, col = "darkblue")   +
  annotate("rect", ymin = -Inf, ymax = Inf, xmin = 6.95, xmax = 6.95, col = "darkblue")   +
  annotate("rect", ymin = -Inf, ymax = Inf, xmin = 7.95, xmax = 7.95, col = "darkblue") +
  theme(legend.position="top")

ggsave("slides/trees/figure_man/tree-growing-x.png", px, units = "cm",
       width = 9.8, height = 9.8)

p <- plot_boundaries(iris, Species ~ Sepal.Length + Sepal.Width, 
                     "Sepal.Length", "Sepal.Width", 
                     cols = c(virginica = "#0CB702", versicolor = "#00A9FF", 
                              setosa = "#FF68A1"), 
                     maxdepth = 4, alpha = 0.2, boundary_col = "black")


ggsave("slides/trees/figure/tree-depth3-area-withblacklines.pdf", p$plot_area(3), units = "cm",
       width = 13.8, height = 9.8)

