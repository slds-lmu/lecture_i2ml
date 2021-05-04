grad = function(..., FUN, eps = .Machine$double.eps^0.5,
                type = c("centered", "forward")) {
  type = match.arg(type)

  gfun = switch(type,
                "forward" = function(vars, j) {
                  vars2 = vars
                  vars2[[j]] = vars2[[j]] + eps
                  f1 = do.call(FUN, vars2); f2 = do.call(FUN, vars)
                  return((f1 - f2) / eps)
                },
                "centered" = function(vars, j) {
                  vars2 = vars
                  vars2[[j]] = vars2[[j]] + eps
                  vars[[j]] = vars[[j]] - eps
                  f1 = do.call(FUN, vars2); f2 = do.call(FUN, vars)
                  return((f1 - f2) / (2 * eps))
                }
  )

  vars = list(...)
  k = length(vars)
  rval = NULL
  for(j in 1:k) {
    rval = cbind(rval, gfun(vars, j))
  }

  if(length(vars) < 2)
    rval = drop(rval)
  else
    colnames(rval) = names(vars)
  return(rval)
}

persp2 = function(x, y, z, col = terrain_hcl, ...) {
  require("colorspace")
  ncz = ncol(z)
  nrz = nrow(z)
  if(is.function(col)) col = col(ncz * nrz)
  zfacet = z[-1, -1] + z[-1, -ncz] + z[-nrz, -1] + z[-nrz, -ncz]
  facetcol = cut(zfacet, length(col))
  persp(x, y, z, col = col[facetcol], ...)
}

####################################################################################################
optim0 = function(..., FUN, tol = 1e-08,
                  maxit = 100, maximum = TRUE) {
  rval = list()
  start = list(...)
  i = 1
  do = TRUE
  while(do & (i < maxit)) {
    f0 = do.call(FUN, start) * if(maximum) -1 else 1
    d = as.numeric(-1 * do.call(grad, c(start, "FUN" = FUN)) *
                     if(maximum) -1 else 1)
    start2 = start
    for(j in seq_along(start))
      start2[[j]] = start[[j]] + d[j]
    f1 = do.call(FUN, start2) * if(maximum) -1 else 1
    start = start2
    do = all.equal(d, rep(0.0, length(d)), tol = tol)
    do = if(!is.logical(do)) TRUE else !do
    rval[[i]] = start
    i = i + 1
  }
  return(rval)
}

sd_plot = function(col = terrain_hcl, theta = 40, phi = 40, xlab = "x", ylab = "y") {
  if(is.function(col)) col = col(nrow(z) * ncol(z))
  par(mfrow = c(1, 2))
  par(mar = rep(0.5, 4))
  require("colorspace")
  pmat = persp2(x, y, z, theta = theta, phi = phi, ticktype = "detailed",
      xlab = xlab, ylab = ylab, zlab = "", col = col, lwd = 0.5)
  for(j in seq_along(p)) {
    t3d = trans3d(p[[j]][[1]], p[[j]][[2]], do.call(foo, p[[j]]), pmat)
    if(j > 1) {
      t3d2 = trans3d(p[[j - 1]][[1]], p[[j - 1]][[2]], do.call(foo, p[[j- 1]]), pmat)
      lines(c(t3d$x, t3d2$x), c(t3d$y, t3d2$y))
      points(x = t3d2$x, y = t3d2$y, pch = 16, col = heat_hcl(1))
    }
    points(x = t3d$x, y = t3d$y, pch = 16, col = heat_hcl(1))
  }
  par(mar = c(4.1, 4.1, 1.1, 1.1))
  image(x, y, z, col = col, xlab = xlab, ylab = ylab)
  contour(x, y, z, add = TRUE)
  for(j in seq_along(p)) {
    if(j > 1) {
      lines(c(p[[j]][1], p[[j - 1]][1]), c(p[[j]][2], p[[j - 1]][2]))
      points(p[[j - 1]][1], p[[j - 1]][2], pch = 16, col = heat_hcl(1))
    }
    points(p[[j]][1], p[[j]][2], pch = 16, col = heat_hcl(1))
  }
  invisible(NULL)
}


