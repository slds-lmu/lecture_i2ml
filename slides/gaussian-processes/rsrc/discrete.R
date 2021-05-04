# Distributions over discrete functions

library(ggplot2)
library(gridExtra)
library(mvtnorm)
library(matrixcalc)
library(reshape2)


plotDiscreteFunction = function(x, y, xlim, ylim) {
	
	df = data.frame(x = x, y = y)

	p1 = ggplot() + xlim(xlim) + theme_bw() 
	if (nrow(df) >= 20) {
		# p1 = p1 + geom_line(data = df, aes(x = x, y = y, xend = x, yend = -Inf), colour = "grey", alpha = 0.5) 
		p1 = p1 + geom_point(data = df, aes(x = x, y = y, color = x), size = 1, shape = 15) 
  	} else {
  		p1 = p1 + geom_segment(data = df, aes(x = x, y = y, xend = x, yend = -Inf), color = "grey", lty = 2)
		p1 = p1 + geom_point(data = df, aes(x = x, y = y, color = x), size = 3, shape = 15) 	                                                      
  	}
	p1 = p1 + scale_x_continuous(breaks = x, labels = round(x, 1))
	p1 = p1 + scale_color_gradientn(colours = c(low = "#E0E0E0", high = "#004C99"))
	p1 = p1 + ylab("h(x)") + ylim(ylim)
	p1 = p1 + theme(
	  plot.background = element_blank(),
	  panel.grid.major = element_blank(),
	  panel.grid.minor = element_blank(),
	  legend.position = "none"
	  )

	return(p1)
}

plotBivariateDensity = function(xlim, ylim, mu, sigma) {

	grid = expand.grid(y1 = seq(xlim[1], xlim[2], length.out = 100), y2 = seq(ylim[1], ylim[2], length.out = 100))

	probs = cbind(grid, density = mvtnorm::dmvnorm(grid, mean = mu, sigma = sigma))

	p2 = ggplot() + xlab(expression(y[1])) + ylab(expression(y[2]))
	p2 = p2 + geom_raster(data = probs, aes(x = y1, y = y2, fill = density)) 
	p2 = p2 + geom_contour(data = probs, aes(x = y1, y = y2, z = density), colour = "white", bins = 5) 
	p2 = p2 + coord_fixed(xlim = xlim, ylim = ylim) + guides(fill = FALSE) 

	return(p2)
}


createMat = function(n, scaleFactor) {
  m = matrix(data = 1, nrow = n, ncol = n)
  if (scaleFactor< 0 | scaleFactor > 1) stop("Scaling factor must be between 0 and 1")
  
  for (row in 1:(n-1)) {
    for (col in 1:(n-1)) {
      if (row <= col) m[row, col+1] = round(m[row, col]*0.9, digits = 2)
      if (row >= col) m[row+1, col] = round(m[row, col]*0.9, digits = 2)
    }
  }
  return(m)
}


squared.exp = function(x1, x2, l = 0.1) {
  
  D = as.matrix(dist(c(x1, x2), method = "euclidean"))
  
  K = exp(-1 / 2 * D^2 / l^2)
  
  return(K)
}




# --- Initial Examples 

set.seed(1111)

for (ninputs in c(2, 5, 10)) {

	x = seq(0, 1, length.out = ninputs)

	for (i in 1:3) {
		
		y = runif(ninputs, -1, 1)

		p = plotDiscreteFunction(x, y, xlim = c(0, 1), ylim = c(- 2, 2))

		ggsave(filename = paste0("figure_man/discrete/example_", ninputs, "_", i, ".pdf"), plot = p, height = 2.5, width = 4)
	}
}



# --- Examples Created from an "arbitrary" matrix (not a kernel)

sigma = lapply(ninputs, function(n) {
	mat = createMat(n, scaleFactor = 0.8)
	diag(mat) = 1
	mat
	}
)

sigma[[1]] = matrix(c(1, 0.5, 0.5, 1), nrow = 2)

names(sigma) = ninputs


# Drawing functions from a normal distribution 
ninputs = c(2, 5, 10, 50, 100, 200)

# print(sigma)
for (input in ninputs) {

	x = seq(0, 1, length.out = input)

	muc = rep(0, input)
	sigmac = sigma[[as.character(input)]]

	for (i in 1:3) {

		# Draw a sample 
		y = as.vector(rmvnorm(1, mean = muc, sigma = sigmac))
				
		p1 = plotDiscreteFunction(x, y, xlim = c(0, 1), ylim = c(- 2, 3))
		p1 = p1 + ggtitle(paste0("Sample Function ", i, ", n = ", input))

		if (input == 2) {
			p2 = plotBivariateDensity(mu = muc, sigma = sigmac, xlim = c(-2, 3), ylim = c(-2, 3))
			p2 = p2 + geom_point(data = data.frame(), aes(x = y[1], y = y[2]), color = "orange", size = 3)
			p2 = p2 + theme_bw() + ggtitle("Density of a 2-D Gaussian") + ylab(expression(h[2])) + xlab(expression(h[1])) 
		} 

		if (input > 2) {
			melted_comat = reshape2::melt(sigmac)
			p2 = ggplot(data = melted_comat, aes(x=Var1, y=Var2, fill=value)) + 
			      geom_tile() + theme_bw() + ggtitle("Covariance Matrix") +
			      scale_fill_gradientn(colours = c(low = "white", high = "black")) +
			      scale_x_discrete(labels = 1:input, limits = 1:input) +
			      scale_x_reverse() +
			      scale_y_discrete(labels = 1:input, limits = 1:input) +
			  theme(axis.line=element_blank(),
			        axis.ticks=element_blank(),
			        axis.title.x=element_blank(),
			        axis.title.y=element_blank(),
			        panel.border=element_blank(),
			        axis.text.x=element_blank(),
			        axis.text.y = element_blank(),
			        panel.grid.major=element_blank())
		}

		ggsave(paste0("figure_man/discrete/example_norm_", input, "_", i, "-a.pdf"), p1, width = 3, height = 3)
		ggsave(paste0("figure_man/discrete/example_norm_", input, "_", i, "-b.pdf"), p2, width = 3, height = 3)

	}
}
 

# --- Two extreme Cases 

set.seed(123)

input = 50

muc = rep(0, input)
sigmac = matrix(0.999, input, input) + 0.01 * diag(input)

x = seq(0, 1, length.out = input)
y = as.vector(rmvnorm(1, mean = muc, sigma = sigmac))
		
p1 = plotDiscreteFunction(x, y, xlim = c(0, 4), ylim = c(- 2, 2))+ theme(axis.text.x=element_blank())
p1 = p1 + ggtitle(paste0("Sample Function for a)", ", n = ", input)) + ylim(c(-2, 2))

ggsave(paste0("figure_man/discrete/example_extreme_", input, "-1.pdf"), p1, width = 3.5, height = 3)

sigmac = diag(input)
y = as.vector(rmvnorm(1, mean = muc, sigma = sigmac))

p1 = plotDiscreteFunction(x, y, xlim = c(0, 4), ylim = c(- 2, 2)) + theme(axis.text.x=element_blank())
p1 = p1 + ggtitle(paste0("Sample Function for b)", ", n = ", input)) + ylim(c(-2, 2))

ggsave(paste0("figure_man/discrete/example_extreme_", input, "-2.pdf"), p1, width = 3.5, height = 3)

p1 = p1 + ggtitle(paste0("Sample Function for b) K = I", ", n = ", input)) + ylim(c(-2, 2))

ggsave(paste0("figure_man/discrete/example_extreme_", input, "-4.pdf"), p1, width = 3.5, height = 3)


sigmac = squared.exp(x, x, l = 0.1)[1:input, 1:input]
y = as.vector(rmvnorm(1, mean = muc, sigma = sigmac))

p1 = plotDiscreteFunction(x, y, xlim = c(0, 4), ylim = c(- 2, 2)) + theme(axis.text.x=element_blank())
p1 = p1 + ggtitle(paste0("Sample Function for c)", ", n = ", input)) + ylim(c(-2, 2))

ggsave(paste0("figure_man/discrete/example_extreme_", input, "-3.pdf"), p1, width = 3.5, height = 3)



# --- Drawing Functions From a True Kernel Matrix

# Drawing functions from a normal distribution 
ninputs = c(10, 50, 200)

plist = list()

# print(sigma)
plist = lapply(ninputs, function(input) {

	x = seq(0, 1, length.out = input)

	muc = rep(0, input)
	sigmac = squared.exp(x, x, l = 0.1)[1:input, 1:input]

	# Draw a sample 
	y = as.vector(rmvnorm(1, mean = muc, sigma = sigmac))
			
	p = plotDiscreteFunction(x, y, xlim = c(0, 4), ylim = c(- 2, 2))
	p = p + ggtitle(paste0("n = ", input)) + theme(axis.text.x = element_blank())
	p
})

ggsave(paste0("figure_man/discrete/example_limit.pdf"), do.call(grid.arrange, c(plist, nrow = 1)), width = 8, height = 3)



ninputs = c(5, 10, 50)

# print(sigma)
for (input in ninputs) {

		x = runif(input, 0, 1)

		muc = rep(0, input)
		sigmac = squared.exp(x, x, l = 0.1)[1:input, 1:input]

		# Draw a sample 
		y = as.vector(rmvnorm(1, mean = muc, sigma = sigmac))
				
		p1 = plotDiscreteFunction(x, y, xlim = c(0, 4), ylim = c(- 2, 2))
		p1 = p1 + ggtitle(paste0("Sample Function, n = ", input))  + theme(axis.text.x = element_blank())

		ggsave(paste0("figure_man/discrete/example_marginalization_", input, ".pdf"), p1, width = 3, height = 3)
}




# mu = c(2, 1) # mean vector
# sigma = matrix(c(1, 0.5, 0.5, 1), ncol = 2) # covariance matrix 

# grid = expand.grid(y1 = seq(-1, 4, length.out = 100), y2 = seq(-1, 4, length.out = 100))

# probs = cbind(grid, density = mvtnorm::dmvnorm(grid, mean = mu, sigma = sigma))

# p2 = ggplot() + xlab(expression(y[1])) + ylab(expression(y[2]))
# p2 = p2 + geom_raster(data = probs, aes(x = y1, y = y2, fill = density)) 
# p2 = p2 + geom_contour(data = probs, aes(x = y1, y = y2, z = density), colour = "white", bins = 5) 
# p2 = p2 + coord_fixed(xlim = c(- 0.5, 3.5), ylim = c(- 0.5, 3.5)) + guides(fill = FALSE) 

# ggsave(filename = "figure_man/bivariate_density.png", plot = p2, height = 3, width = 6)



# df1 = data.frame(x = x, y = t(y), label = "Sample 1")
# p1 = ggplot() + ylim(c(0, 3)) + xlim(c(0, 3)) + theme_bw() + geom_vline(data = df, aes(xintercept = x), color = "grey", lty = 2)
# p1 = p1 + geom_point(data = df1, aes(x = x, y = y, color = label), size = 3)
# p1 = p1 + guides(color = FALSE)

# g = grid.arrange(p1, p2, ncol = 2)

# ggsave(filename = "figure_man/discrete_sample1.png", plot = grid.arrange(p1, p2, ncol = 2), height = 3, width = 6)

# # Drawing another sample
# y = rmvnorm(1, mean = mu, sigma = sigma)
# df2 = rbind(df2, data.frame(x = y[1], y = y[2], label = "Sample 2"))

# p2 = ggplot() + xlab(expression(y[1])) + ylab(expression(y[2]))
# p2 = p2 + geom_raster(data = probs, aes(x = y1, y = y2, fill = density)) 
# p2 = p2 + geom_contour(data = probs, aes(x = y1, y = y2, z = density), colour = "white", bins = 5) 
# p2 = p2 + coord_fixed(xlim = c(- 0.5, 3.5), ylim = c(- 0.5, 3.5)) + guides(fill = FALSE) 
# p2 = p2 + geom_point(data = df2, aes(x = x, y = y, color = label), size = 3) 
# p2 = p2 + geom_text(data = df2, aes(x = x, y = y + 0.3, color = label, label = label), size = 4)
# p2 = p2 + geom_segment(data = df2, aes(x = x, xend = x, y = y, yend = -1, color = label), lty = 2)
# p2 = p2 + geom_segment(data = df2, aes(x = -1, xend = x, y = y, yend = y, color = label), lty = 2) 
# p2 = p2 + guides(color = FALSE)

# df1 = rbind(df1, data.frame(x = x, y = t(y), label = "Sample 2"))
# p1 = ggplot() + ylim(c(0, 3)) + xlim(c(0, 3)) + theme_bw() + geom_vline(data = df, aes(xintercept = x), color = "grey", lty = 2)
# p1 = p1 + geom_point(data = df1, aes(x = x, y = y, color = label), size = 3)
# p1 = p1 + guides(color = FALSE)

# g = grid.arrange(p1, p2, ncol = 2)

# ggsave(filename = "figure_man/discrete_sample2.png", plot = g, height = 3, width = 6)
