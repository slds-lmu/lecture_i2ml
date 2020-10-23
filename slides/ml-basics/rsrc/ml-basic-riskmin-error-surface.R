## Compare the risk functions of different possible models

#######
# Create sample data
set.seed(1234)

#number of data points
n <- 15

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
  result <- rep(0,length)
  for (i in 1:length){
    result[i] <- sum (abs(y - (theta_1[i] + theta_2[i]*x)))
  }
  result
}

########################################################################
#show table
##empirical risk for the differen thetas
r_emp <- risk(x,y,n, theta_1, theta_2)
theta_risk_df <- data.frame( theta_1 = theta_1, theta_2 = theta_2, r_emp = round(r_emp,2)) 
theta_risk_df
########################################################################
#-----------------------------
x1seq = seq(-10,10,1)
x2seq = seq(-10,10,1)
m = length(x1seq)
z = outer(x1seq,x2seq,FUN=function(x1,x2) risk(x,y,n,x1, x2))

##############
#create interpolating colors
##############
#source: http://www.imsbio.co.jp/RGM/R_rdfile?f=graphics/man/persp.Rd&d=R_rel
nrz <- nrow(z)
ncz <- ncol(z)
# Create a function interpolating colors in the range of specified colors
jet.colors <- colorRampPalette( c("green", "blue") )
# Generate the desired number of colors from this palette
nbcol <- 100
color <- jet.colors(nbcol)
# Compute the z-value at the facet centres
zfacet <- z[-1, -1] + z[-1, -ncz] + z[-nrz, -1] + z[-nrz, -ncz]
# Recode facet z-values into color indices
facetcol <- cut(zfacet, nbcol)
#> persp(x, y, z, col = color[facetcol], phi = 30, theta = -30)

#################
#create surface plot
##################
png(file=sprintf("figure/ml-basic-riskmin-error-surface.png"))
#par(mai=rep(0,4)); par(omi=rep(0,4))
pmat <- persp(x1seq, x2seq, z,
      #theta=75, 
      #phi=55, 
      theta=80, 
      phi=5, 
      r=1, 
      #shade = 1, 
      #axes = TRUE, 
      scale = TRUE, 
      #box = FALSE, 
      expand =  0.5,        # Shrinking/growing of z values
      #border = NA,
      nticks=3, 
      #ticktype="detailed", 
      #zlim = c(0, 3), 
      col = color[facetcol],#col = "lightblue",
      xlab = expression("θ1"), 
      ylab = expression("θ2"),
      zlab="R")

# add example thetas as dots 
mypoints = trans3d(theta_1, theta_2, r_emp, pmat = pmat)
col = alpha("blueviolet")  
points(mypoints, pch = 19, col = "blueviolet", cex = 1.2)



dev.off()


