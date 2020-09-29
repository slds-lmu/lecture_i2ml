# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(MASS)
library(car)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

set.seed(123)

n = 300

classa = data.frame(mvrnorm(n = n, 
                            mu = c(2, 2), 
                            Sigma = matrix(c(2, 0, 0, 2), 
                                           ncol = 2, 
                                           byrow = TRUE)))

classb = data.frame(mvrnorm(n = n, 
                            mu = c(10, 7), 
                            Sigma = matrix(c(8, -6, -6, 8), 
                                           ncol = 2, 
                                           byrow = TRUE)))

# Target data frame

df = cbind(classa, rep("a", ncol(classa)))
colnames(df) = c("x1", "x2", "y")

foo = cbind(classb, rep("b", ncol(classb)))
colnames(foo) = c("x1", "x2", "y")

df = rbind(df, foo)

####### LDA
## All from scratch:

mu_a = c(mean(df[which(df$y == "a"), 1]), 
         mean(df[which(df$y == "a"), 2]))

mu_b = c(mean(df[which(df$y == "b"), 1]), 
         mean(df[which(df$y == "b"), 2]))

foo = matrix(c(0, 0, 0, 0), ncol = 2)
foo_a = foo_b = matrix(c(0, 0, 0, 0), ncol = 2)

for (i in 1:nrow(df)) {
  
  if (df[i, "y"] == "a") {
    
    foo = foo + as.matrix(t(df[i, c(1, 2)] - mu_a)) %*% 
      as.matrix(df[i, c(1, 2)] - mu_a)
    
  } else {
    
    foo = foo + as.matrix(t(df[i, c(1, 2)] - mu_b)) %*% 
      as.matrix(df[i, c(1, 2)] - mu_b)
    
  }
  
}

var_lda = 1 / (nrow(df) - 2) * foo

for (i in 1:nrow(df[which(df$y == "a"), ])) {
  
  temp = as.matrix(df[which(df$y == "a"), ][i, c(1, 2)] - mu_a)
  foo_a = foo_a + crossprod(temp)
  
}

var_qda_a = (1 / (nrow(classa) - 1)) * foo_a

for (i in 1:nrow(df[which(df$y == "b"), ])) {
  
  temp = as.matrix(df[which(df$y == "b"), ][i, c(1, 2)] - mu_b)
  foo_b = foo_b + crossprod(temp)
  
}

var_qda_b = (1 / (nrow(classb) - 1)) * foo_b

# Create ellipsoids

a_ell_lda = as.data.frame(ellipse(center = mu_a, 
                                  shape = var_lda, 
                                  radius = 2, 
                                  draw = FALSE))

a_ell_qda = as.data.frame(ellipse(center = mu_a, 
                                  shape = var_qda_a, 
                                  radius = 2, 
                                  draw = FALSE))

b_ell_lda = as.data.frame(ellipse(center = mu_b, 
                                  shape = var_lda, 
                                  radius = 2, 
                                  draw = FALSE))
b_ell_qda = as.data.frame(ellipse(center = mu_b, 
                                  shape = var_qda_b, 
                                  radius = 2, 
                                  draw = FALSE))

colnames(a_ell_lda) = 
  colnames(a_ell_qda) = 
  colnames(b_ell_lda) = 
  colnames(b_ell_qda) = 
  c("x1", "x2")

dens_a_lda =
  dens_a_qda = 
  dens_b_lda = 
  dens_b_qda = 
  expand.grid(
    X1 = seq(min(c(classa$X1, classb$X1)), 
             max(c(classa$X1, classb$X1)), 
             l = 50),
    X2 = seq(min(c(classa$X2, classb$X2)), 
             max(c(classa$X2, classb$X2)), 
             l = 50))

dens_a_lda$dens = sqrt(mvtnorm::dmvnorm(dens_a_lda[, 1:2], 
                                        m = mu_a, 
                                        sigma = var_lda))
dens_a_qda$dens = sqrt(mvtnorm::dmvnorm(dens_a_qda[, 1:2], 
                                        m = mu_a, 
                                        sigma = var_qda_a))
dens_b_lda$dens = sqrt(mvtnorm::dmvnorm(dens_b_lda[, 1:2], 
                                        m = mu_b, 
                                        sigma = var_lda))
dens_b_qda$dens = sqrt(mvtnorm::dmvnorm(dens_b_qda[, 1:2], 
                                        m = mu_b, 
                                        sigma = var_qda_b))

# FUNCTIONS --------------------------------------------------------------------

plot_ellipses = function(dens_1, dens_2) {
  
  ggplot(data = classa, aes(x = X1, y = X2, alpha = 0.2)) +
    geom_contour(data = dens_1, 
                 aes(z = dens), 
                 col = "blue", 
                 alpha = .2, 
                 lwd = 1, 
                 bins = 5) +
    geom_contour(data = dens_2, 
                 aes(z = dens), 
                 col = "red", 
                 alpha = .2, 
                 lwd = 1, 
                 bins = 5) +
    geom_point(col = "blue", 
               show.legend = FALSE) +
    geom_point(data = classb, 
               aes(x = X1, y = X2, alpha = 0.2), 
               col = "red", 
               show.legend = FALSE) +
    coord_fixed()
  
}

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/reg_class_dis_1.pdf", width = 8, height = 3.5)

plot1 = plot_ellipses(dens_a_lda, dens_b_lda)
plot1

ggsave("../figure/reg_class_dis_1.pdf", width = 8, height = 3.5)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/reg_class_dis_1_2.pdf", width = 8, height = 2.2)

plot1

ggsave("../figure/reg_class_dis_1_2.pdf", width = 8, height = 2.2)
dev.off()

# PLOT 3 -----------------------------------------------------------------------

pdf("../figure/reg_class_dis_3.pdf", width = 8, height = 4.5)

plot2 = plot_ellipses(dens_a_qda, dens_b_qda)
plot2

ggsave("../figure/reg_class_dis_3.pdf", width = 8, height = 4.5)
dev.off()