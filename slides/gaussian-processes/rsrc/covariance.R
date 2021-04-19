# ----------------------------------------------------------------------- #
# Generation of Samples for different Covariance Functions                #
# ----------------------------------------------------------------------- #

# Initialization -------------------------------------------------------- #
library(mvtnorm)
library(ggplot2)
library(RandomFieldsUtils)

n = 1000 # number of points
x = seq(-2, 2, length.out = n) # n equally spaced points
D = as.matrix(dist(x, method = "euclidean")) # distance matrix 
# ----------------------------------------------------------------------- #

# Squared exponential Covariance Function ------------------------------- #

## parameters to try out
l = c(0.1, 1, 10) # parameters to try out 
## Corresponding kernel matrixes
squared.exp = lapply(l, function(l) exp(-1 / 2 * D^2 / l^2))
## Sampling from corresponding Gaussian
df.squared.exp = sapply(squared.exp, function(x) as.vector(rmvnorm(1, sigma = x)))
df.squared.exp = as.data.frame(df.squared.exp)
names(df.squared.exp) = as.character(l)
df.squared.exp$x = x

## Plot
df.m = melt(df.squared.exp, id.vars = "x")
p1 = ggplot(data = df.m, aes(x = x, y = value, colour = variable)) 
p1 = p1 + geom_line()
p1 = p1 + xlab("x") + ylab("f(x)") + ylim(c(-5, 5))
p1 = p1 + scale_colour_discrete(name = "Length Scale") 
p1 = p1 + theme_bw() + theme(legend.position = "top", legend.direction = "horizontal")
p1 = p1 + ggtitle("Squared Exponential Covariance Function")

# ------------------------------------------------------------------------ #

# Polynomial Covariance Function ----------------------------------------- #

## parameters to try out
p = c(1, 2, 3)
## Corresponding kernel matrixes
poly = lapply(p, function(l) as.matrix((x %*% t(x))^l))
## Sampling from corresponding Gaussian
df.poly = sapply(poly, function(x) as.vector(rmvnorm(1, sigma = x)))
df.poly = as.data.frame(df.poly)
names(df.poly) = as.character(p)
df.poly$x = x

## Plot
df.m = melt(df.poly, id.vars = "x")
p2 = ggplot(data = df.m, aes(x = x, y = value, colour = variable)) 
p2 = p2 + geom_line() 
p2 = p2 + xlab("x") + ylab("f(x)") + ylim(c(-5, 5))
p2 = p2 + scale_colour_discrete(name = "Degree") 
p2 = p2 + theme_bw() + theme(legend.position = "top", legend.direction = "horizontal")
p2 = p2 + ggtitle("Polynomial Covariance Function")

# ------------------------------------------------------------------------ #


# Matérn Covariance Function --------------------------------------------- #

## parameters to try out
nu = c(0.5, 2, 10)
## Corresponding kernel matrixes
matern = lapply(nu, function(l) matrix(matern(D, nu = l, scaling = "matern"), 
                                nrow = n, ncol = n))
## Sampling from corresponding Gaussian
df.matern = sapply(matern, function(x) as.vector(rmvnorm(1, sigma = x)))
df.matern = as.data.frame(df.matern)
names(df.matern) = as.character(nu)
df.matern$x = x

## Plot
df.m = melt(df.matern, id.vars = "x")
p3 = ggplot(data = df.m, aes(x = x, y = value, colour = variable)) 
p3 = p3 + geom_line()
p3 = p3 + xlab("x") + ylab("f(x)") + ylim(c(-5, 5)) 
p3 = p3 + theme_bw() + theme(legend.position = "top", legend.direction = "horizontal")
p3 = p3 + scale_colour_discrete(name = expression(paste(nu))) 
p3 = p3 + ggtitle("Matérn Covariance Functions")

# ------------------------------------------------------------------------ #

# Save the Plot ---------------------------------------------------------- #

g = grid.arrange(p1, p2, p3, ncol = 3)

ggsave(filename = "figure_man/covariance.png", plot = g, width = 10, height = 5)

# ------------------------------------------------------------------------ #

