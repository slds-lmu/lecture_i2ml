#SVM
library(mvtnorm)
library(quadprog)
library(gridExtra)
source("rsrc/plot_lin_svm.R")

set.seed(1)

num_obs <- 20
sigma <- matrix(c(1, -0.9, -0.9, 1), nrow = 2)
mu <- c(0.3, 0.3)
x_data <- rmvnorm(num_obs, mean = mu, sigma = sigma)
x_data <- rbind(x_data, rmvnorm(num_obs, mean = -mu, sigma = sigma))

all_data <- data.frame(x = x_data, y = factor("1", levels = c("1", "-1")))
all_data$y[num_obs:(2 * num_obs)] <- "-1"

data <- all_data[which(abs(all_data$x.1) < 1 & abs(all_data$x.2) < 1), ]
row.names(data) <- as.character(1:nrow(data))

data_plot <- ggplot(data, aes(x=x.1, y=x.2)) +
  geom_point(aes(colour=y), size=3) +
  xlab("") + ylab("") + theme(legend.position = "none")

pairwise_desc <- function(a, max_it = 100,
                          exit_if_a_valid = FALSE,
                          ids_mat = NULL){
  
  if(!is.null(ids_mat)){
    max_it = nrow(ids_mat)
  }
  
  for (l in 1:max_it) {
    if(exit_if_a_valid){
      if(all(a >= 0 & a <= C )){
        #print("a valid")
        break
      }
    }
    
    if(is.null(ids_mat)){
      ids <- sample(1:length(a), size = 2, replace = FALSE)
    }else{
      ids <- ids_mat[l,]
    }
    
    K <- y[ids] %*% a[ids]
    
    d <- c(0, 0)
    for (i in 1:length(ids)) {
      d[i] <- 1- y[ids[i]] * sum(((x * y * a) %*% x[ids[i], ])[-ids, ])
    }
    
    D <- matrix(rep(0, 4), nrow = 2)
    for (i in 1:length(ids)) {
      D[i, i] <- x[ids[i], ] %*% x[ids[i], ]
    }
    D[1, 2] <- (x[ids[1], ] %*% x[ids[2], ]) * y[ids[1]] * y[ids[2]]
    D[2, 1] <- D[1, 2]
    
    # check if zero:
    # print(cost(a, y, x) - (
    #   -(-t(d) %*% a[ids] + 0.5 * (t(a[ids]) %*% D %*% a[ids]))[1,1] +
    #       cost(a[-ids], y[-ids], x[-ids,]))) 
    
    
    A <- matrix(c(
      y[ids[1]], y[ids[2]],
      1, 0,
      -1, 0,
      0, 1,
      0, -1
    ),
    nrow = 2, byrow = FALSE
    )
    b <- c(
      K,
      0,
      -C,
      0,
      -C
    )
    
    result <- tryCatch({
      solve.QP(Dmat = D, dvec = d, Amat = A, bvec = b, meq = 1)
    }, error = function(error_condition) {
      NULL
    })
    if (!is.null(result)) {
      a_new <- a
      a_new[ids] <- result$solution
      
      new_cost <- cost(a_new, y, x)
      old_cost <- cost(a,y,x)
      
      if(new_cost != old_cost){
        a <- a_new 
        #print(new_cost)      
      }
    }
  }
  return(a)
  
}

cost <- function(a,y,x){
  sum(a) - 0.5* sum((a*y*x) %*% t(a*y*x))
}

y <- as.numeric(as.character(data$y))
x <- as.matrix(data[, c("x.1", "x.2")])


C <- 1
a_start <- qr.Q(qr(matrix(
  c(y, rep(1, length(y))),
  ncol = 2, byrow = FALSE
)))[, 2]

a <- a_start

set.seed(1)
a_valid <- pairwise_desc(a, exit_if_a_valid = TRUE)
ids <- c(1,18)
a_better <- pairwise_desc(a_valid, 
                          ids_mat = matrix(ids, nrow=1))

alpha_before <- plot_lin_svm(data, a = a_valid) +
  geom_point(data=data[ids,], aes(x=x.1, y=x.2),
             shape=1, size=5, colour="red") +
  annotate("label", x=data[ids[1],1] - 0.2, y=data[ids[1],2],
           label="bold(x[1])", parse=TRUE, fill="red") +
  annotate("label", x=data[ids[2],1] + 0.2, y=data[ids[2],2],
           label="bold(x[18])", parse=TRUE, fill="red")

grid.arrange(data_plot, alpha_before, ncol=2)

################################################################

a_v <- seq(-0.5,1.5,length.out = 100)

a_grid <- expand.grid(a_v, a_v)

insert <- function(a, x, ids){
  a[ids] <- x
  return(a)
}

a_grid$obj <- apply(a_grid, function(a_n)
  cost(insert(a_valid, as.matrix(a_n), ids), y, x), MARGIN = 1)

K <- y[ids] %*% a_valid[ids]
intercept <- K / y[ids[2]]
slope <- -y[ids[1]]/y[ids[2]]

as <- as.data.frame(rbind(a_valid[ids],
                          a_better[ids]))

alpha_opt <- ggplot() + 
  geom_raster(data = a_grid, aes(x=Var1, y=Var2, fill=obj)) +
  geom_contour(data = a_grid, aes(x=Var1, y=Var2, z=obj), colour="grey") + 
  geom_rect(data=data.frame(xmin = 0, ymin = 0, xmax = C, ymax = C),
            aes(xmin = xmin, ymin = ymin, xmax = xmax, ymax = ymax),
            colour = "white", fill="white", alpha=0) + 
  geom_abline(slope=slope, intercept = intercept) + 
  geom_point(data=as, aes(x=V1, y=V2), colour="red") +
  annotate("label", x=a_valid[ids[1]] - 0.2, y=a_valid[ids[2]] + 0.2, 
           label="(alpha[1]*','~alpha[18])^~'[old]'",
           fill="red", parse=TRUE) +
  annotate("label", x=a_better[ids[1]] -0.3, 
           y=a_better[ids[2]] + 0.2, 
           label="(alpha[1]*','~alpha[18])^~'[new]'",
           fill="red", parse=TRUE) +
  annotate("label", x=1, 
           y=1.4, label="y^(1)*alpha[1] + y^(18)*alpha[18] == s",
           fill="white", parse=TRUE) +
  xlab(expression(alpha[1])) +
  ylab(expression(alpha[18])) + 
  labs(fill="Obj.") +
  theme(legend.position = "bottom",
        legend.margin=margin(0,0,0,0),
        legend.box.margin=margin(-10,-10,-10,-10))

alpha_after <- plot_lin_svm(data, a = a_better)


grid.arrange(alpha_opt, alpha_after, ncol=2)

######################################################

a_i <- seq(0, 1)
a_j <- rep(K, length(a_i))/y[ids[2]] - y[ids[1]]/y[ids[2]]*a_i

a_line <- cbind(a_i, a_j)

df <- as.data.frame(cbind(a_line, apply(a_line, function(a_n)
  cost(insert(a_valid, as.matrix(a_n), ids), y, x), MARGIN = 1)))

df <- reshape2::melt(df, id.vars="a_i")

df_costs <- as.data.frame(cbind(c(a_valid[1], a_better[1]), c(cost(a_valid, y, x), 
                                                              cost(a_better, y, x))))


smo <- ggplot(df, aes(x=a_i, y=value)) + 
  geom_line(aes(colour=variable), size=1.5) +
  geom_hline(yintercept = 1, linetype="dashed", size=1) + 
  geom_vline(xintercept = a_better[1], linetype="dashed", size=1) +
  scale_y_continuous(breaks=c(1,2.5,5.0,7.5)) +
  xlab(expression(a[1])) + ylab("") +
  annotate("label", x = a_better[1], y = 5, label="a[18]==C", parse=TRUE) +
  scale_colour_discrete(name = "lines", labels = expression(a[18], 'Obj.')) +
  geom_point(data=df_costs, aes(x=V1, y=V2), colour="red", size=2)

grid.arrange(alpha_opt, smo, ncol=2)

################################################


