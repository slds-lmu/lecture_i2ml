library(ggplot2)

# DATA -------------------------------------------------------------------------

set.seed(pi)

x = 1:5
y = x + rnorm(5, 0, 2)
m = lm(y ~ x)

coef1 <- c(1.8, .3)
coef2 <- c(1, .1)
coef3 <- c(0.5, .8)

# FUNCTIONS --------------------------------------------------------------------

colBlue = function(alpha) { rgb(135, 206, 255, alpha, maxColorValue = 255) }
colGreen = function(alpha) { rgb(188, 238, 104, alpha, maxColorValue = 255) }

data_plot = function(x, y) {
  
  plot(x, 
       y, 
       ylim = c(-2, 6), 
       xlim = c(0, 8), 
       cex = 2, 
       pch = 4, 
       las = 1, 
       ann = "false")
  
  grid()
  
}

add_lm = function(coef, color, coef_label) {
  
  abline(coef = coef, col = color(255), lwd = 3)
  coef <- round(coef, 1)
  
  text(x = coef_label[1], 
       y = coef_label[2], 
       labels = bquote(theta == "("~.(coef[1])~","~.(coef[2])~")"),
       col = color(255))
  
}

add_errors = function(x, y, coef, color, sse_label) {
  
  hat_y = cbind(1, x) %*% coef
  w = abs(y - hat_y)
  
  rect(xleft = x, 
       ybottom = y, 
       xright = x + w, 
       ytop = hat_y, 
       col = color(90),
       border = color(120), 
       lwd = 2)
  
  text(x = sse_label[1], 
       y = sse_label[2], 
       labels = bquote(R[emp] == ~ .(sum(round(w^2, 2)))), #paste0("SSE: ", sum(round(w^2, 2))),
       col = color(255))
  
  points(x, y, cex = 2, pch = 4, lwd = 2)
  
}

frame_plot = function(x, y, coef, color, coef_label, sse_label) {
  
  data_plot(x, y)
  add_lm(coef, color, coef_label)
  add_errors(x, y, coef, color, sse_label)
  
}

pdf("../figure/lm_reg1.pdf", height = 3, width = 4)
frame_plot(x, y, coef1, colBlue, c(2, 5.5), c(x = 6.5, y = -0.5))
dev.off()

pdf("../figure/lm_reg2.pdf", height = 3, width = 4)
frame_plot(x, y, coef(m), colGreen, c(2, 5.5), c(x = 6.5, y =  -0.5))
dev.off()


pdf("../figure/lm_reg3.pdf", height = 3, width = 4)
data_plot(x,y) 
num_lines <- 6
offset <- 3
set.seed(234)
cl <- rainbow(offset+num_lines)
for(i in 1:num_lines){
  abline( coef = runif(2,-5,5), lwd=1, col=cl[offset+i], lty=i)
}
dev.off()


