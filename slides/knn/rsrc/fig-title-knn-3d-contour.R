################################################################################
################### Create Title picture #######################################
################################################################################
library(gridGraphics)
library(cowplot)
#add both source codes
source("rsrc/fig-reg_knn_1_3d.R")
source("rsrc/fig-reg_knn_1_contour.R")

# DATA -------------------------------------------------------------------------
#train_data
set.seed(123)
n = 30L
x1 = rnorm(n)
x2 = rnorm(n)
######################################
y =  c( 1.22076452,
        0.56734044,
        2.05508440,
        0.28635076,  
        1.64796340,  
        1.32789451,
        2.39977707,  
        2.49271993,
        0.03303868,
        0.93479029,  
        0.02098021,
        0.33006921,
        1.16341521,  
        3.76159346,  
        0.11506933,  
        1.16247805, 
        0.66888878,
        0.60179677,
        0.15215771,  
        1.05282591,
        0.11692928,  
        0.63646053, 
        0.98631103,  
        1.54495294,
        0.74805760,
        3.75181486,
        1.33063806, 
        0.52668935,
        0.2,
        0.3)
train_data = as.data.frame(cbind(x1, x2, y))
train_data = rbind(train_data, c(0, 0, 0))


#-------------------------------------------------------------------------------
#Paramters
k <- 3


knn_plot_surface(train_data, k = k, resolution_surface = 0.01)+ theme(aspect.ratio=1)
ggsave("figure/knn-surface-3.png")


png(file="figure/knn-3d-3.png")
par(mai=c(0,0,0,0)); par(omi=rep(0,4))
plot_knn_3d(train_data, k = k, resolution_surface = 0.1)
dev.off()



rl <- lapply(list("figure/knn-surface-3.png", "figure/knn-3d-3.png"), png::readPNG)
gl <- lapply(rl, grid::rasterGrob)

png(filename = "figure/fig-title-knn-3d-contour.png", width = 1000, height = 1000)
do.call(gridExtra::grid.arrange, gl)
dev.off()




