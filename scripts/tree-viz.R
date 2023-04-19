#' This script combines code and examples for a visualization function for
#' classification trees using the rpart package.
#' The function(s) visualizes:
#' a) the tree structure (using rpart.plot)
#' b) the resulting prediction areas (using ggplot2)
#' The function harmonizes both plots so they can be printed vis-a-vis
#' and corrects the areas of plot b) so there is no overlap


#install.packages("rpart")
#install.packages("rpart.plot")
#install.packages("tidyverse")
#install.packages("parttree")
library(rpart)
library(rpart.plot)
library(tidyverse)
library(parttree)

#' Main function
#' This function creates tree structure and area plots for classification trees.
#' The tree structure is plotted using the rpart.plot function.
#' The area is plotted using ggplot2. The resulting plot visualizes 
#' the predictive surface with rectangles of different color.
#' There is one tree plot and area plot per depth of the tree.
#' @param data a data.frame containing the data for the tree fit.
#' @param formula a formula, as specified when passed to the rpart function.
#' must consist of two features
#' @param x_axis a single character, the feature displayed on the area plot on 
#' the x-axis. Must be contained in the formula.
#' @param y_axis a single character, the feature displayed on the area plot on 
#' the x-axis. Must be contained in the formula.
#' @param cols a named vector that has the same length as there are classes. 
#' The names must correspond with the classes. The values must be explicit colours
#' recognized by both rpart.plot and ggplot2
#' @param alpha a single numeric value between 0 and 1, the alpha value of ggplot2
#' steering the opacity of the retangles in the area plot.
#' @param maxdepth a single integer value, the maximum depth of the tree.
#' @return a list of length 3, a) the tree at the current depth,
#' b) the corresponding classification plot ($plot_tree), c) the corresponding
#' area plot ($plot_area). Both latter elements are functions that can be supplied
#' with an index. The index corresponds to the current depth of the tree.
#' That means $plot_area(2) produces the area plot for the tree at depth = 2.
plot_boundaries <- function(data, formula, x_axis, y_axis, cols, 
                            alpha = 0.25, maxdepth = 5L, boundary_col = NULL, ...) {
  res <- vector("list", 0L)
  cols2 <- res
  res$trees <- vector("list", maxdepth)
  splits_old <- NULL
  splits_list <- res
  counter <- 0
  for (i in 1:maxdepth) { 
    tree <- rpart(formula, data = data, maxdepth = i, ...)
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
  res$plot_area <- function(i) base_plot %>% annotate_all(pfs_i[[i]], cols = cols, alpha = alpha, boundary_col = boundary_col)
  res$plot_tree <- function(i) rpart.plot(res$trees[[i]], box.palette = as.list(cols2[[i]]))
  res
}

#' Function that corrects rectangles when they overlap.
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

#' Function using the annotate function of ggplot2 to plot rectangles for the
#' area plot. 
annotate_all <- function(base_plot, plot_splits, cols, alpha = .25, boundary_col = NULL) {
  target <- colnames(plot_splits)[2]
  for (i in 1:nrow(plot_splits)) {
    if (is.null(boundary_col)) {
    base_plot <- base_plot + 
      annotate("rect", xmin = plot_splits$xmin[i], 
               xmax = plot_splits$xmax[i], 
               ymin = plot_splits$ymin[i], 
               ymax = plot_splits$ymax[i], 
               alpha = alpha, 
               fill = cols[plot_splits[[target]][i]]) 
    } else {
      base_plot <- base_plot + 
        annotate("rect", xmin = plot_splits$xmin[i], 
                 xmax = plot_splits$xmax[i], 
                 ymin = plot_splits$ymin[i], 
                 ymax = plot_splits$ymax[i], 
                 alpha = alpha, 
                 fill = cols[plot_splits[[target]][i]], 
                 col = boundary_col) 
    }
  }
  base_plot
}

plot_contin <- function(data, formula, maxdepth = 5L, vertical = TRUE, ...) {
  vars <- all.vars(formula)
  y <- vars[1]
  x <- vars[2]
  res <- vector("list", 0L)
  res$trees <- vector("list", maxdepth)
  splits_old <- NULL
  splits_list <- res
  counter <- 0
  for (i in 1:maxdepth) { 
    tree <- rpart(formula, data = data, maxdepth = i, ...)
    plot_splits <- parttree(tree)
    if (identical(plot_splits, splits_old[, 1:ncol(plot_splits)])) {
      break
    }
    counter <- counter + 1
    plot_splits$depth <- i
    splits_old <- plot_splits
    splits_list[[i]] <- plot_splits
    res$trees[[i]] <- tree
  }
  target <- colnames(plot_splits)[2]
  res$trees <- res$trees[1:counter]
  base_plot <- ggplot(data, aes(.data[[x]], .data[[y]])) +
    geom_point()
  res$plot_area <- function(i) base_plot %>% annotate_contin(splits_list[[i]], vertical = vertical)
  res$plot_tree <- function(i) rpart.plot(res$trees[[i]])
  res
}


annotate_contin <- function(base_plot, plot_splits, vertical = TRUE) {
  target <- colnames(plot_splits)[2]
  for (i in 1:nrow(plot_splits)) {
    if (vertical) {
    base_plot <- base_plot + 
      annotate("rect", xmin = plot_splits$xmin[i], 
               xmax = plot_splits$xmax[i], 
               ymin = plot_splits$ymin[i], 
               ymax = plot_splits$ymax[i], 
               alpha = 0,
               col = "black") 
    }
    base_plot <- base_plot + annotate("rect", xmin = plot_splits$xmin[i], 
               xmax = plot_splits$xmax[i],
               ymin = plot_splits[i, target], 
               ymax = plot_splits[i, target], 
               col = "red", alpha = 0)
  }
  base_plot
}



