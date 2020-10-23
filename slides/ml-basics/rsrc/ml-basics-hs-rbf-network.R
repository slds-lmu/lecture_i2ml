# PREREQ -----------------------------------------------------------------------

library(knitr)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

set.seed(2310)

x_1 = rnorm(1000, 0, 1)

# HELPERS ----------------------------------------------------------------------

plot_basis_fun_2d = function(coeff, center, bandwidth = 1) {
  
  get_basis_fun = function(x, coeff, center, bandwidth = 1) {
    
    coeff * dnorm(x, center, 1 / bandwidth)
    
  }
  
  get_weighted_sum = function(x, coeff, center, bandwidth = 1) {
    
    # get_basis_fun(x, coeff[1], center[1]) +
    #   get_basis_fun(x, coeff[2], center[2]) +
    #   get_basis_fun(x, coeff[3], center[3])
    
    # sum(mapply(get_basis_fun, x, coeff, center))
    
    apply(
      sapply(c(1:3), function(i) get_basis_fun(x, coeff[i], center[i])), 
      1, 
      sum)
    
    }
  
  p = ggplot(data.frame(x_1 = c(-5, 5)), aes(x_1)) +
    theme_bw() + 
    ylim(c(-0.05, 0.3)) +
    labs(
      x = expression(paste(x[1])),
      y = expression(paste(f(x[1]))))
  
  for (i in 1:length(coeff)) {
    
    p = p + stat_function(
      fun = get_basis_fun, 
      args = list(coeff[i], center[i]),
      linetype = "dashed")
    
    p = p + geom_segment(
      x = center[i],
      xend = center[i],
      y = 0,
      yend = coeff[i] * dnorm(0, 0, bandwidth),
      size = 1.4,
      color = "orange"
    )
    
    p = p + annotate(
      "text",
      x = center[i],
      y = -0.02,
      label = expr(paste(c[!!i], " = ", !!center[i])),
      size = 6,
      angle = 45,
      color = "orange"
    )
    
    p = p + annotate(
      "text",
      x = center[i],
      y = coeff[i] * dnorm(0, 0, bandwidth) + 0.01,
      label = expr(paste(a[!!i], " = ", !!coeff[i])),
      size = 6,
      color = "blue"
      
    )
    
    p = p + stat_function(
      fun = get_weighted_sum, 
      args = list(coeff, center))
    
  }

  p
  
}

plot_basis_fun_3d = function(coeff, center, bandwidth = 1) {
  
  get_basis_fun = function(x, coeff, center, bandwidth = 1) {
    
    coeff * dnorm(x, center, 1 / bandwidth)
    
  }
  
  get_weighted_sum = function(x, coeff, center, bandwidth = 1) {
    
    get_basis_fun(x, coeff[1], center[1]) +
      get_basis_fun(x, coeff[2], center[2]) +
      get_basis_fun(x, coeff[3], center[3])
    
  }
  
  p = ggplot(data.frame(x_1 = c(-5, 5)), aes(x_1))
  
  for (i in 1:length(coeff)) {
    
    p = p + stat_function(
      fun = get_basis_fun, 
      args = list(coeff[i], center[i]),
      linetype = "dashed")
    
    p = p + geom_segment(
      x = center[i],
      xend = center[i],
      y = 0,
      yend = coeff[i] * dnorm(0, 0, bandwidth),
      size = 1.4,
      color = "orange"
    )
    
    p = p + annotate(
      "text",
      x = center[i] + 0.5,
      y = 0.02,
      label = expr(paste(c[!!i], " = ", !!center[i])),
      size = 6,
      color = "orange"
    )
    
    p = p + annotate(
      "text",
      x = center[i],
      y = coeff[i] * dnorm(0, 0, bandwidth) + 0.01,
      label = expr(paste(a[!!i], " = ", !!coeff[i])),
      size = 6,
      color = "blue"
      
    )
    
    p = p + stat_function(
      fun = get_weighted_sum, 
      args = list(coeff, center))
    
  }
  
  p
  
}

# PLOT -------------------------------------------------------------------------

pdf("../figure/ml-basics-hs-rbf-network.pdf", width = 8, height = 4)

p_1 = plot_basis_fun_2d(c(0.2, 0.5, 0.3), c(-3, 0, 2))
p_2 = plot_basis_fun_2d(c(0.2, 0.5, 0.3), c(-2, 1, 2))
p_3 = plot_basis_fun_2d(c(0.6, 0.2, 0.2), c(-3, 0, 2))
grid.arrange(p_1, p_2, p_3, ncol = 3)

ggsave("../figure/ml-basics-hs-rbf-network.pdf", width = 8, height = 4)
dev.off()