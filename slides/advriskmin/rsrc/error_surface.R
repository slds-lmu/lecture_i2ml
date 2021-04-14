library(checkmate)
library(numDeriv)
library(colorspace)
library(ggplot2)
library(akima)
library(plotly)

# ersetze durch funktion numGrad aus package numDeriv
# grad = function(..., FUN, eps = 0.001,
#                 type = c("centered", "forward")) {
#   type = match.arg(type)

#   gfun = switch(type,
#                 "forward" = function(vars, j) {
#                   vars2 = vars
#                   vars2[[j]] = vars2[[j]] + eps
#                   f1 = do.call(FUN, vars2); f2 = do.call(FUN, vars)
#                   return((f1 - f2) / eps)
#                 },
#                 "centered" = function(vars, j) {
#                   vars2 = vars
#                   vars2[[j]] = vars2[[j]] + eps
#                   vars[[j]] = vars[[j]] - eps
#                   f1 = do.call(FUN, vars2); f2 = do.call(FUN, vars)
#                   return((f1 - f2) / (2 * eps))
#                 }
#   )

#   vars = list(...)
#   k = length(vars)
#   rval = NULL
#   for(j in 1:k) {
#     rval = cbind(rval, gfun(vars, j))
#   }

#   if(length(vars) < 2)
#     rval = drop(rval)
#   else
#     colnames(rval) = names(vars)
#   return(rval)
# }

# creates plot
# persp2 = function(x, y, z, col = terrain_hcl, ...) {
#   require("colorspace")
#   ncz = ncol(z)
#   nrz = nrow(z)
#   if(is.function(col)) col = col(ncz * nrz)
#   zfacet = z[-1, -1] + z[-1, -ncz] + z[-nrz, -1] + z[-nrz, -ncz]
#   facetcol = cut(zfacet, length(col))
#   persp(x, y, z, col = col[facetcol], ...)
# }

####################################################################################################

grad_descent = function(f, x0, iters, step.size = 0.1, step.adaptive = FALSE, step.momentum = 0) {
  assert_function(f, "x")  
  assert_numeric(x0)
  i = 1
  n = length(x0)
  xevals = matrix(0, nrow = iters, ncol = n)
  grads = matrix(0, nrow = iters, ncol = n)
  ys = length(iters)
  # define velocity vector
  vs = length(iters+1)
  # init the starting velocity
  vs[1] = 0
  while (i <= iters) {
      xevals[i,] = x0
      y = f(x0)
      ys[i] = y
      g = grad(f, x0)
      grads[i,] = g
      # obtain the previous velocity
      vs[i+1] = (step.momentum * vs[i]) 
      if (step.adaptive) { vs[i+1] = vs[i+1] + (step.size * g)/i } else  { vs[i+1] = vs[i+1] + step.size * g }
      x0 = x0 - vs[i+1] 
      i = i + 1
  }
  res = as.data.frame(cbind(xevals, ys, grads))
  colnames(res) = c("x1", "x2", "f", "g1", "g2")
  return(res)
}


plot_grad_descent = function(f, res, x1lim, x2lim, resolution = 50L, three_d = FALSE) {
    x1seq = seq(x1lim[1], x1lim[2], length.out = resolution)
    x2seq = seq(x2lim[1], x2lim[2], length.out = resolution)
    surface = expand.grid(x1 = x1seq, x2 = x2seq)        
    surface$fx = apply(surface, 1, f)

    if(three_d){
      
      s = interp(x = surface$x1, y = surface$x2, z = surface$fx)
      p1 = plot_ly(x=  res$x1,     y = res$x2, z=res$f, type="scatter3d", color = "red")
      add_trace(p = p1, z=s$z, y=s$y, x=s$x, type = "surface")
    }
    else{
      pl = ggplot() + 
        geom_raster(data = surface, aes(x = x1, y = x2, fill = fx), show.legend = FALSE) +
        geom_contour(data = surface, aes(x = x1, y = x2, z = fx), colour = "white", alpha = 0.5, size = 0.5)
   
      n = nrow(res)
      pl = pl + geom_point(data = res, mapping = aes(x = x1, y = x2), shape = 4, size = 4) 
      pl = pl + geom_path(data = res, mapping = aes(x = x1, y = x2)) 
    }
}


f = function(x) sum(x^2)
z = grad_descent(f, c(2, 2), iters = 20)
p = plot_grad_descent(f, z, x1lim = c(-2, 2), x2lim = c(-2, 2), three_d = TRUE)
p
