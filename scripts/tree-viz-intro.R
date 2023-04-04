source("scripts/tree-viz.R")
# some of these graphics are also used for the treegrowing chunk
# some graphs are post processed using draw.io (see google drive)

p <- plot_boundaries(iris, Species ~ Sepal.Length + Sepal.Width, 
                     "Sepal.Length", "Sepal.Width", 
                     cols = c(virginica = "#0CB702", versicolor = "#00A9FF", setosa = "#FF68A1"), 
                     maxdepth = 4, alpha = 0.2)

png("slides/trees/figure_man/tree_depth3_structure.png", 
    width = 824, height = 824, pointsize = 20)
p$plot_tree(3)
dev.off()

png("slides/trees/figure_man/tree_depth3_structure_wide.png", 
    width = 1024, height = 724, pointsize = 22)
p$plot_tree(3)
dev.off()

ggsave("slides/trees/figure_man/tree_depth3_area.png",
       p$plot_area(3) + theme(legend.position="top"), units = "cm",
       width = 9.8, height = 9.8)

set.seed(19)
x <- runif(100, 0, 10)
y <- 2 * (0.5 * sin(x * 2 - 0.1) + 0.75 * cos(0.5 * x)) + rnorm(100, 0, 0.2)
df <- data.frame(x, y)

pp <- plot_contin(df, y ~x)
png("slides/trees/figure_man/tree_depth3_structure_regr.png", 
    width = 824, height = 824, pointsize = 20)
pp$plot_tree(3)
dev.off()
ggsave("slides/trees/figure_man/tree_depth3_area_regr.png",
       pp$plot_area(3) + theme_bw() , units = "cm",
       width = 9.8, height = 9.8)


png("slides/trees/figure_man/tree_depth1_structure.png", width = 1224, height = 754,
    pointsize = 25)
p$plot_tree(1)
dev.off()
ggsave("slides/trees/figure_man/tree_depth1_area.png",
       p$plot_area(1) + theme(legend.position="top") , units = "cm",
       width = 9.8, height = 9.8)

png("slides/trees/figure_man/tree_depth2_structure.png", 
    width = 824, height = 824, pointsize = 20)
p$plot_tree(2)
dev.off()
ggsave("slides/trees/figure_man/tree_depth2_area.png",
       p$plot_area(2) + theme(legend.position="top") , units = "cm",
       width = 9.8, height = 9.8)

pnp <- p$plot_area(2) + theme(legend.position="none")
pnp$layers[[1]] <- NULL
pnp <- pnp + xlim(c(4.3, 7.9)) + ylim(c(2, 4.4)) + geom_point(aes(x = 5, y = 3), col = "black", shape = 8)
pnp
ggsave("slides/trees/figure_man/tree_depth3_area_nopoints.png",
       pnp, units = "cm",
       width = 9.8, height = 9.8)

ggsave("slides/trees/figure/cart_intro_classification_tree_wide.pdf", 
       p$plot_area(3) + theme(legend.position="top"), units = "cm",
       width = 15.8, height = 8)

ggsave("slides/trees/figure/cart_intro_regression_tree_wide.pdf", 
       pp$plot_area(3) + theme_bw(), units = "cm",
       width = 15.8, height = 8)
