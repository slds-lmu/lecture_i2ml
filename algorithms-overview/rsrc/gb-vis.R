# PREREQ -----------------------------------------------------------------------

library(knitr)
library(tidyverse)
library(ggplot2)

# FUNCTIONS --------------------------------------------------------------------

basisTrafo = function (x) {
  
  margin = 0.1 * (max(x) - min(x))
  splines::splineDesign(
    knots = seq(min(x) - margin, max(x) + margin, length.out = 40), 
    x = x)
  
}

plot_gb_2d <- function (x, 
                        y, 
                        nboost, 
                        learning_rate, 
                        basis_fun = function (x) cbind(1, x)) {
  
  X = basis_fun(x)
  
  overall_pred = rep(mean(y), length(y))
  pseudo_resids = y
  coefs = matrix(0, nrow = nboost, ncol = ncol(X))
  ylim = c(min(y), max(y))
  
  for (i in seq_len(nboost)) {
    
    if (i == nboost) {
      
      plot(
        x = x, 
        y = y, 
        ylim = ylim, 
        xlab = "Feature x", 
        ylab = "Target y",
        cex.lab = 2, 
        cex.axis = 2)
      grid()
      segments(
        x0 = x, 
        y0 = y, 
        x1 = x, 
        y1 = overall_pred, 
        lty = 2, 
        col = "blue")
      
      # Add earlier models:
    
      if (i > 1) {
        
        lines(x = x, y = rep(mean(y), length(y)), col = "black")
        ccoefs = apply(coefs[seq_len(i), ], 2, cumsum)
        alphas = seq(0.4, 0.8, length.out = nrow(ccoefs))
        
        for (j in seq_along(alphas)) {
          
          lines(
            x = x, 
            y = mean(y) + X %*% ccoefs[j,], 
            col = rgb(0, 0, 0.255, alphas[j]))
          
        }
      }
      
      lines(x = x, y = overall_pred, col = "blue", lwd = 2)
      
    }
    
    # Update step:
    
    pseudo_resids = y - overall_pred
    coefs[i,] = learning_rate * solve(t(X) %*% X) %*% t(X) %*% pseudo_resids
    
    # browser()
    
    blearner_pred = X %*% coefs[i,]
    overall_pred = overall_pred + blearner_pred
    
  }
  
}

# DATA -------------------------------------------------------------------------

nsim = 50L

set.seed(31415)
x = seq(0, 10, length.out = nsim)
y = 4 + 3 * x + 5 * sin(x) + rnorm(nsim, 0, 2)

plot(x = x, y = y, xlab = "Feature x", ylab = "Target y")



# PLOT -------------------------------------------------------------------------

pdf("../figure/gb-2d.pdf", width = 12, height = 6)

boosting_iters = c(1, 2, 3, 5, 10, 100)

for (nboost in boosting_iters) { 
  plot_gb_2d(x, y, nboost, 0.2, basis_fun = basisTrafo)
}

ggsave("../figure/gb-2d.pdf", width = 12, height = 6)
dev.off()