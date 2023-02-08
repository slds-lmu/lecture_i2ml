#install.packages("rpart")
#install.packages("rpart.plot")
#install.packages("tidyverse")
#install.packages("parttree")
library(rpart)
library(rpart.plot)
library(tidyverse)
library(parttree)

plot_boundaries <- function(data, formula, x_axis, y_axis, cols, alpha = 1, 
                            verbose = FALSE, maxdepth = 5L) {
  res <- vector("list", 0L)
  cols2 <- res
  res$trees <- vector("list", maxdepth)
  splits_old <- NULL
  splits_list <- res
  counter <- 0
  for (i in 1:maxdepth) { 
    tree <- rpart(formula, data = data, maxdepth = i)
    plot_splits <- parttree(tree)
    if (identical(plot_splits, splits_old[, 1:ncol(plot_splits)])) {
      break
    }
    counter <- counter + 1
    plot_splits$depth <- i
    splits_old <- plot_splits
    splits_list[[i]] <- plot_splits
    res$trees[[i]] <- tree
    target_present <- levels(data[[colnames(plot_splits)[2]]]) %in% plot_splits[, 2]
    cols2 <- append(cols2, list(cols[levels(data[[colnames(plot_splits)[2]]])][target_present]))
  }
  target <- colnames(plot_splits)[2]
  res$trees <- res$trees[1:counter]
  cols2 <- cols2[1:counter]
  cols <- cols[levels(data[[target]])]
  base_plot <- ggplot(data, aes(.data[[x_axis]], .data[[y_axis]],
                                color = .data[[target]], 
                                shape = .data[[target]])) +
    geom_point() + scale_color_manual(values = cols)
  pfs <- Reduce(rbind, splits_list)
  pfs <- pfs[!duplicated(pfs[, -ncol(pfs)]), ]
  pfs_i <- vector("list", counter)
  for (i in 1:counter) {
    pfs_i[[i]] <- pfs[pfs$depth %in% 1:i, ]
    pfs_i[[i]] <- correct_rectangles(pfs_i[[i]])
  }
  res$plot_area <- function(i) base_plot %>% annotate_all(pfs_i[[i]], cols = cols, alpha = alpha)
  res$plot_tree <- function(i) rpart.plot(res$trees[[i]], box.palette = as.list(cols2[[i]]))
  res
}

correct_rectangles <- function(rect) {
  for (i in (nrow(rect) - 1):1) {
    old <- rect[nrow(rect):(i + 1), , drop = FALSE]
    new <- rect[i, , drop = FALSE]
    for (j in 1:nrow(old)) {
      l1_x <- old$xmin[j]
      l1_y <- old$ymax[j]
      r1_x <- old$xmax[j]
      r1_y <- old$ymin[j]
      l2_x <- new$xmin
      l2_y <- new$ymax
      r2_x <- new$xmax
      r2_y <- new$ymin
      
      # check if overlap first
      # edge case: check if area of one rectangle is 0
      overlap_area_0 <- (l1_x == r1_x || l1_y == r1_y || r2_x == l2_x || l2_y == r2_y)
      # if one is left of other
      is_left <- l1_x >= r2_x || l2_x >= r1_x
      # or above
      is_above <- r1_y >= l2_y || r2_y >= l1_y
      # tangential is considered too
      
      if ((overlap_area_0 + is_left + is_above) <= 0) {
        
        if ((r2_x <= r1_x) & (l2_x <= l1_x)) { # left overlap
          x_overlap_l <- c(l2_x, l1_x)
        } else {
          x_overlap_l <- c(NA, NA)
        }
        
        if ((r2_x >= r1_x) & (l2_x >= l1_x)) { # right overlap
          x_overlap_r <- c(r1_x, r2_x)
        } else {
          x_overlap_r <- c(NA, NA)
        }
        
        
        if ((r2_y <= r1_y) & (l2_y <= l1_y)) { # bottom overlap
          y_overlap_b <- c(r2_y, r1_y)
        } else {
          y_overlap_b <- c(NA, NA)
        }
        
        if ((r2_y >= r1_y) & (l2_y >= l1_y)) { # top overlap
          y_overlap_t <- c(l1_y, l2_y)
        } else {
          y_overlap_t <- c(NA, NA)
        }
        
        x_coords <- c(min(c(x_overlap_l[1], x_overlap_r[1]), na.rm = T),
                      max(c(x_overlap_l[2], x_overlap_r[2]), na.rm = T))
        y_coords <- c(min(c(y_overlap_b[1], y_overlap_t[1]), na.rm = T),
                      max(c(y_overlap_b[2], y_overlap_t[2]), na.rm = T))
        
        new$xmin <- x_coords[1]
        new$xmax <- x_coords[2]
        new$ymin <- y_coords[1]
        new$ymin <- y_coords[2]
      } 
    }
    rect[i, ] <- new
  }
  rect
}

annotate_all <- function(base_plot, plot_splits, cols, alpha = .25) {
  target <- colnames(plot_splits)[2]
  for (i in 1:nrow(plot_splits)) {
    base_plot <- base_plot + 
      annotate("rect", xmin = plot_splits$xmin[i], 
               xmax = plot_splits$xmax[i], 
               ymin = plot_splits$ymin[i], 
               ymax = plot_splits$ymax[i], 
               alpha = alpha, 
               fill = cols[plot_splits[[target]][i]]) 
  }
  base_plot
}

p <- plot_boundaries(iris, Species ~ Sepal.Length + Sepal.Width, 
                     "Sepal.Length", "Sepal.Width", 
                     cols = c(virginica = "blue", versicolor = "green", setosa = "red"), 
                     maxdepth = 4, alpha = 0.2)
p$plot_tree(1)
p$plot_area(1)
p$plot_tree(2)
p$plot_area(2)
p$plot_tree(3)
p$plot_area(3)

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

