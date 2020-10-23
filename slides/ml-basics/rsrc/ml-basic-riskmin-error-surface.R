## Compare the risk functions of different possible models

load("ml-basic-riskmin-calculate_risk.R")
#######
# Create sample data
set.seed(1234)

#number of data points
n <- 15000

# errors
sd <- 2
eps <- rnorm(n = n , mean = 0, sd = sd)

# x values
x <- seq (1,10,length.out = n)

#calculate the values of the function with errors
##linear model 
b0 <- 1
b1 <- 0.5
y <- b0 + b1*x + eps

#propsed thetas
theta_1 <- c(  4, 3,1, -9)
theta_2 <- c( 1, 7,0.5, 1.8)

#------------------------------
risk  <- function (x, y, n, theta_1, theta_2){
  length <- length(theta_1)
  result <- rep(99,length)
  for (i in 1:length){
    result[i] <- sum (abs(y - (theta_1[i] + theta_2[i]*x)))
  }
  result
}

fun <- function(x1,x2) risk(x,y,n,x1, x2)

#-----------------------------
x1seq = seq(-5,5,0.2)
x2seq = seq(-5,5,0.2)
m = length(x1seq)
z = outer(x1seq,x2seq,FUN=fun)

png(file=sprintf("figure/ml-basic-riskmin-error-surface.png"))
par(mai=rep(0,4)); par(omi=rep(0,4))
pmat <- persp(x1seq, x2seq, z,
      #theta=75, 
      #phi=55, 
      theta=80, 
      phi=5, 
      r=1, 
      #shade = 0.4, 
      #axes = TRUE, 
      scale = TRUE, 
      #box = FALSE, 
      expand =  0.5,        # Shrinking/growing of z values
      #border = '#333333',
      nticks=3, 
      #ticktype="detailed", 
      #zlim = c(0, 3), 
      col = "cyan",
      xlab = expression("θ1"), 
      ylab = expression("θ2"),
      zlab="R")


mypoints = trans3d(1, 0.5, 1.56, pmat = pmat)
col = alpha("green")  
points(mypoints, pch = 19, col = "green", cex = 1.2)



dev.off()


