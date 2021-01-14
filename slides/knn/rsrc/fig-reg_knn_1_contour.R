################################################################################
############## Surface Plot of reg_knn_1 ############################################
################################################################################


# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(mlr3)
library(mlr3learners)
library(tidyverse)
library(ggnewscale)


# DATA -------------------------------------------------------------------------
#train_data
set.seed(123)
n = 30L
x1 = rnorm(n)
x2 = rnorm(n)

#same values as in the 3D plot
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


# FUNCTION 1 -------------------------------------------------------------------

#plot circle 

circleFun = function(center = c(0,0), diameter = 1, npoints = 100) {
  
  r = diameter / 2
  tt = seq(0, 2* pi, length.out = npoints)
  xx = center[1L] + r * cos(tt)
  yy = center[2L] + r * sin(tt)
  return(data.frame(x1 = xx, x2 = yy, class = NA))
  
}
# FUNCTION 2 -------------------------------------------------------------------
# plot points including the KNN regression values
# 
# train_data: see above, data of the 3d plot
# k: number of nearest neighbors
# resolution_surface: resolution of the raster of the prediction
knn_plot_surface = function(train_data, k, resolution_surface = 0.1) {
  
  n = nrow(train_data) - 1
  
  dists = sort(as.matrix(dist(train_data[,1:2]))[n + 1L, ])
  neighbs = as.numeric(names(dists[1:(k + 1)]))

  circle.dat = circleFun(c(0, 0), 2.01 * dists[k + 1], npoints = 100)
  
  train_data$class = ifelse(1:(n+1) %in% neighbs, 1L, 0L)
  train_data[n + 1L, "class"] = 2L
  train_data$class = as.factor(train_data$class)
  
  
  ###############################################################
  # add regression values 
  ###############################################################
  
  x1seq = seq(-2,2,resolution_surface)
  x2seq = seq(-2,2.2,resolution_surface)
  test_data = expand.grid(x1 = x1seq, x2 = x2seq)
  test_data = cbind(test_data, y = rep(0,nrow(test_data)), class = as.factor(rep(0, nrow(test_data))))
  
  # all data
  data = rbind(train_data, test_data)
  id_train = seq(1,nrow(train_data))
  begin_test_id <- nrow(train_data)+1
  id_test = seq(begin_test_id,(nrow(data)))
  
  #predict values with mlr
  task_knn <- TaskRegr$new(id = "knn", backend = data, target = "y")
  learner_knn <- lrn("regr.kknn", k = k)
  learner_knn$train(task_knn, row_ids = id_train)
  pred_knn <- learner_knn$predict(task_knn)
  data <- cbind(data, response = pred_knn$response)
  #############################################################
  q = ggplot() + 
    geom_raster(data = data[id_test,], 
                aes(x = x1, 
                    y = x2, 
                    fill = response)) +
    scale_fill_gradientn(colours=c("white","grey20"))+
    theme(legend.position = "none") + 
    labs(subtitle = bquote(k == .(k))) +
    new_scale_fill() + #scale changes from con to discrete
    geom_point(data = data[id_train,], aes(x = x1, y = x2, color = class),size = 2) + 
    scale_color_viridis_d(end = .9) + 
    scale_fill_viridis_d(end = .9) + 
    geom_polygon(data = circle.dat,aes(x = x1, y = x2, color = class), alpha = 0.2, fill = "#619CFF") + 
    theme(legend.position = "none") + 
    labs(subtitle = bquote(k == .(k)))
  q
}


# PLOT -------------------------------------------------------------------------
res <- 0.01

# all the k's we want to plot
all_k <- c(15,7,3)

pdf("figure/reg_knn_contour.pdf", width = 8, height = 3)

gridExtra::grid.arrange( knn_plot_surface (train_data, k = all_k[1], resolution_surface = res), 
                         knn_plot_surface (train_data, k = all_k[2], resolution_surface = res), 
                         knn_plot_surface (train_data, k = all_k[3], resolution_surface = res),
                        nrow = 1)

ggsave("figure/reg_knn_contour.pdf", width = 8, height = 3)
dev.off()
