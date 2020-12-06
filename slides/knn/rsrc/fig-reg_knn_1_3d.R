################################################################################
############## 3D Plot of reg_knn_1 ############################################
################################################################################


# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(mlr3)
library(mlr3learners)
library(tidyverse)


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





# Plot function  -------------------------------------------------------------------------


#last point is the point we are looking at
#function: give the index of the points with the minimal distance of the features
find_k_nearest_neighbors<- function (train_data, k = 2){
  euc_dist <- function(x1, x2) sqrt(sum((x1 - x2) ^ 2))
  point <- train_data[nrow(train_data),1:2]
  distance<- apply(train_data[-nrow(train_data),1:2],1, function(x){sqrt(sum((x - point) ^ 2))})
  
  k_smallest_index <- as.vector(t(apply(t(as.matrix(distance)), 1, order)[ 1:k, ]))
  k_smallest_index
}

#plot a 3d plot with all points + a surface for the knn prediction + the knns
#train_data: data we plot
# k: number of neighbors 
# resolution: how we choose the grid of the surface
plot_knn_3d <- function(train_data, k = 2, resolution_surface = 0.2) {
  #test_data --> predicted surface
  x1seq = seq(-2,2,resolution_surface)
  x2seq = seq(-2,2,resolution_surface)
  test_data = expand.grid(x1 = x1seq, x2 = x2seq)
  test_data = cbind(test_data, y = rep(0,nrow(test_data)))
  
  # all data
  data = rbind(train_data, test_data)
  id_train = seq(1,nrow(train_data))
  begin_test_id <- nrow(train_data)+1
  id_test = seq(begin_test_id,(nrow(data)))
  
  #Task
  task_knn <- TaskRegr$new(id = "knn", backend = data, target = "y")
  learner_knn <- lrn("regr.kknn", k = k)
  learner_knn$train(task_knn, row_ids = id_train)
  pred_knn <- learner_knn$predict(task_knn)
  
  data <- cbind(data, response = pred_knn$response)
  
  prediction_matrix <- data%>%
    slice(id_test) %>%
    select(-y) %>%
    spread(key = x2, value = response)%>%
    column_to_rownames(var = "x1")
  prediction_matrix <- data.matrix(prediction_matrix)
  
  #surface plot
  # https://pj.freefaculty.org/guides/Rcourse/plot-3d/plots-3d.pdf
  # 
#--------- Color
  #source: http://www.imsbio.co.jp/RGM/R_rdfile?f=graphics/man/persp.Rd&d=R_rel
  z <- prediction_matrix
  nrz <- nrow(z)
  ncz <- ncol(z)
  # Create a function interpolating colors in the range of specified colors
  jet.colors <- colorRampPalette( c("white", "black") )
  # Generate the desired number of colors from this palette
  nbcol <- 100
  color <- jet.colors(nbcol)
  # Compute the z-value at the facet centres
  zfacet <- z[-1, -1] + z[-1, -ncz] + z[-nrz, -1] + z[-nrz, -ncz]
  # Recode facet z-values into color indices
  facetcol <- cut(zfacet, nbcol)
  #--------- Color (end) 
  
  
  
  #surface plot 
  predicted_surface <- persp(x = x1seq, 
                             y = x2seq, 
                             z = prediction_matrix,
                             xlim = c(-2,2),
                             ylim = c(-2,2),
                             zlim = c(0,4),
                             xlab = "x1",
                             ylab = "x2",
                             zlab = "y",
                             theta = 32, #angle left and right
                             phi = 15, #moves graph up and down (default: 15)
                             box = TRUE,
                             axes = TRUE,
                             ticktype = "detailed",
                             #shade = FALSE,
                             border = NA,
                             col =  color[facetcol],#"grey97",#drapecol(volcano), (libary (shape))
                             main = paste0("k = ",k)
  )
  
  
  # all points in violet
  train_points <- trans3d(train_data$x1, 
                          train_data$x2, 
                          train_data$y, 
                          pmat = predicted_surface)
  
  
  points(train_points, 
         pch = 20, 
         col = "darkviolet")
  
  #segment all 
  v_ground <- trans3d(train_data$x1, 
                      train_data$x2, 
                      rep(0, nrow(train_data)), 
                      pmat = predicted_surface)
  
  
  segments(train_points$x, 
           train_points$y,
           v_ground$x,
           v_ground$y, 
           col = "darkviolet",
           lty = 5)
  
  #center point in light green 
  center_point <- trans3d(train_data$x1[nrow(train_data)], 
                          train_data$x2[nrow(train_data)], 
                          train_data$y[nrow(train_data)], 
                          pmat = predicted_surface)
  
  
  points(center_point, 
         pch = 19, 
         col = "green2")
  
  #k neighbors 
  index_knn <- find_k_nearest_neighbors (train_data, k = k)
  center_point <- trans3d(train_data$x1[index_knn], 
                          train_data$x2[index_knn], 
                          train_data$y[index_knn], 
                          pmat = predicted_surface)
  
  
  points(center_point, 
         pch = 19, 
         col = "darkcyan")
  #segment all 
  v_ground_knn <- trans3d(train_data$x1[index_knn], 
                      train_data$x2[index_knn], 
                      rep(0, k), 
                      pmat = predicted_surface)
  
  
  segments(train_points$x[index_knn], 
           train_points$y[index_knn],
           v_ground_knn$x,
           v_ground_knn$y, 
           col = "darkcyan",
           lty = 5)
  
  
}



# Plot -------------------------------------------------------------------------
# plot_knn_3d (train_data, k = 15, resolution_surface = 0.1)
# plot_knn_3d (train_data, k = 7, resolution_surface = 0.1)
# plot_knn_3d (train_data, k = 3, resolution_surface = 0.1)

# all the ks we want to plot
all_k <- c(15,7,3)

#save the png's
for (x in all_k) {
  png(file=sprintf("figure/knn-reg-3d-%i.png", x))
  par(mai=c(0,0,1,0)); par(omi=rep(0,4))
  plot_knn_3d (train_data, k = x, resolution_surface = 0.1)
  dev.off()
}

