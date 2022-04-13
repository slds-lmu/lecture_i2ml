library(mlbench)
library(splines)
library(BBmisc)

data(Ozone)

R_emp_grad <- function(beta,
                       features = X,
                       target = y) {
  return(2 * t(features) %*% (features %*% beta - target))
}

gradient_descent <-
  function(beta_start,
           step_size,
           grad_fun,
           num_steps,
           features,
           target) {
    betas <- matrix(0, ncol = length(beta_start), nrow = num_steps)
    betas[1,] <- beta_start
    for (i in seq(2, num_steps)) {
      betas[i,] <-
        betas[i - 1,] - step_size * grad_fun(betas[i - 1, ], features,
                                             target)
    }
    
    betas <- as.data.frame(betas)
    return(betas)
  }

poly <- function(x, degree) {
  sapply(0:degree, function(i)
    x ^ i)
}

o_data <- Ozone[, c(4, 8)]
o_data$V8 <- o_data$V8 / 100
o_data <- o_data[complete.cases(o_data), ]

set.seed(6)

id_train <- sample(1:nrow(o_data), 20)
o_data$type <- "test"
o_data[id_train,]$type <- "train"
o_data$type <- as.factor(o_data$type)

train_data <-  as.matrix(o_data[id_train, 1:2])
test_data  <-  as.matrix(o_data[-id_train, 1:2])

degree <- 15

x_train <- poly(train_data[, 2], degree)
y_train <- o_data[id_train , 1]
x_test <- poly(test_data[, 2], degree)
y_test <- o_data[-id_train , 1]

num_steps <- 1000000
res <- gradient_descent(rep(0, ncol(x_train)),  0.02, #0.003,
                        R_emp_grad, num_steps, x_train, y_train)

errs <- matrix(0, nrow = 2000, ncol = 2)
it1 <- 1:1000
for (i in it1) {
  errs[i, 1] <-
    sum((x_train %*% t(res[i, ]) - y_train) ^ 2) / nrow(x_train)
  errs[i, 2]  <-
    sum((x_test %*% t(res[i, ]) - y_test) ^ 2) / nrow(x_test)
}
it2 <- seq(1000, num_steps, length.out = 1000)
for (i in it2) {
  errs[1000 + which(it2 == i), 1] <-
    sum((x_train %*% t(res[i, ]) - y_train) ^ 2) / nrow(x_train)
  errs[1000 + which(it2 == i), 2]  <-
    sum((x_test %*% t(res[i, ]) - y_test) ^ 2) / nrow(x_test)
}

df <- as.data.frame(errs)
colnames(df) <- c("train", "test")
df$id <- c(it1, it2)

min_te <- which.min(errs[, 2])

learning_df <- melt(df, id.vars = "id")
ggplot(learning_df, aes(x = id, y = value)) +
  geom_line(aes(colour = variable)) +
  geom_vline(xintercept = min_te, linetype = "dashed") +
  geom_vline(xintercept = num_steps) +
  scale_x_log10()

pl_data <- seq(min(o_data[, 2]), max(o_data[, 2]), length.out = 100)
pl_data <- poly(pl_data, degree)

y_overfit <- (pl_data) %*% t(res[num_steps, ])[,1]
y_best <- (pl_data) %*% t(res[min_te, ])[,1]

fitting_df <- data.frame(overfit = y_overfit, best = y_best, x = pl_data[, 2] * 100)
fitting_df <- melt(fitting_df, id.vars = "x")

ggplot(o_data, aes(x=V8*100, y=V4)) + 
  geom_point(aes(colour=type)) +
  geom_line(data=fitting_df, aes(linetype=variable, x=x, y=value), alpha = 0.7)

save2("early_stopping1.RData", o_learn = learning_df, o_fit = fitting_df, o_data = o_data, 
      best_it = min_te, max_it = num_steps)
