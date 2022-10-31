# PREREQ -----------------------------------------------------------------------

library(scatterplot3d)

# PLOT -------------------------------------------------------------------------

data(mtcars)

png("../figure/lm_3d.png", width = 280L, height = 260L)

p <- scatterplot3d(
  x = mtcars$disp,
  y = mtcars$cyl, 
  z = mtcars$mpg,
  color = "blue",
  pch = 19,
  xlab = bquote(x[1]),
  ylab = bquote(x[2]),
  zlab = "y",
  type = "h",
)

model <- lm(mpg ~ disp + cyl, mtcars)
p$plane3d(model)

dev.off()
