source("scripts/tree-viz.R")
p <- plot_boundaries(iris, Species ~ Sepal.Length + Sepal.Width, 
                     "Sepal.Length", "Sepal.Width", 
                     cols = c(virginica = "#0CB702", 
                              versicolor = "#00A9FF", setosa = "#FF68A1"), 
                     maxdepth = 4, alpha = 0.2)

png("scripts/tree-viz-png/tree-wide.png", width = 650, height = 350)
p$plot_tree(3)
dev.off()

png("scripts/tree-viz-png/tree-squared.png", width = 350, height = 350)
p$plot_tree(3)
dev.off()

