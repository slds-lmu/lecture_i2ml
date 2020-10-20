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
theta_1 <- c(10, 2, 4, 3,1)
theta_2 <- c(10, 0.5, 1, 2,0.5)

#risk function
risk  <- function (x, y, n, theta_1, theta_2){
  length <- length(theta_1)
  result <- rep(99,length)
  for (i in 1:length){
    result[i] <- sum (abs(y - (theta_1[i] + theta_2[i]*x)))/n
  }
  result
}

#empirical risk for the differen thetas
r_emp <- risk(x,y,n, theta_1, theta_2)

#show table
calculated_table <- data.frame( theta_1 = theta_1, theta_2 = theta_2, r_emp = round(r_emp,2)) 
calculated_table
