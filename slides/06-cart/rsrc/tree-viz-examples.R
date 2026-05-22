source("scripts/tree-viz.R")

####### Examples

p <- plot_boundaries(iris, Species ~ Sepal.Length + Sepal.Width, 
                     "Sepal.Length", "Sepal.Width", 
                     cols = c(virginica = "#0CB702", versicolor = "#00A9FF", setosa = "#FF68A1"), 
                     maxdepth = 4, alpha = 0.2)
p$plot_tree(1)
p$plot_area(1)
p$plot_tree(2)
p$plot_area(2)
p$plot_tree(3)

iris2 <- iris[1:100,] %>% mutate(Species = as.factor(as.character(Species)))
p2 <- plot_boundaries(iris2, Species ~ Sepal.Length + Sepal.Width, 
                      "Sepal.Length", "Sepal.Width", 
                      cols = c(setosa = "red", versicolor = "green"), 
                      maxdepth = 4, alpha = 0.2)

p2$plot_tree(1)
p2$plot_area(1)
p2$plot_tree(2)
p2$plot_area(2)
p2$plot_tree(3) #should obviously fail
p2$plot_area(3) #as well

######################## continuous ######
set.seed(19)
x <- runif(100, 0, 10)
y <- 2 * (0.5 * sin(x * 2 - 0.1) + 0.75 * cos(0.5 * x)) + rnorm(100, 0, 0.2)
df <- data.frame(x, y)

pp <- plot_contin(df, y ~x)
pp$plot_area(1) + theme_bw()
pp$plot_tree(1) 
pp$plot_tree(3) 
pp$plot_area(3) + theme_bw()


