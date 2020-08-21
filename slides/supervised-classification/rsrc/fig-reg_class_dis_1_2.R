 
library(knitr)
library(mlbench)
library(mlr)
library(OpenML)

library(ggplot2)
library(viridis)
library(gridExtra)
library(ggrepel)
library(repr)
library(MASS)
library(data.table)
library(BBmisc)


library(party)
library(kableExtra)
library(kknn)
library(e1071)
library(car)

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))


pdf("../figure/reg_class_dis_1_2.pdf", width = 8, height = 2.5)

n = 300
classa = data.frame(mvrnorm(n = n, mu = c(2,2), Sigma = matrix(c(2, 0, 0, 2), ncol = 2, byrow = TRUE)))
classb = data.frame(mvrnorm(n = n, mu = c(10,7), Sigma = matrix(c(8, -6, -6, 8), ncol = 2, byrow = TRUE)))

# Target data frame
df = cbind(classa, rep("a", ncol(classa)))
colnames(df) = c("x1", "x2", "y")
foo = cbind(classb, rep("b", ncol(classb)))
colnames(foo) = c("x1", "x2", "y")
df = rbind(df, foo)

####### LDA
## all from scratch:
mu_a = c(mean(df[which(df$y == "a"), 1]), mean(df[which(df$y == "a"), 2]))
mu_b = c(mean(df[which(df$y == "b"), 1]), mean(df[which(df$y == "b"), 2]))

foo = matrix(c(0, 0, 0, 0), ncol = 2)
for (i in 1:nrow(df)) {
  if (df[i, "y"] == "a") {
    # i = 1
    foo = foo +  as.matrix(t(df[i, c(1, 2)] - mu_a)) %*% as.matrix(df[i, c(1, 2)] - mu_a)
  }
  else {
    foo = foo +  as.matrix(t(df[i, c(1, 2)] - mu_b)) %*% as.matrix(df[i, c(1, 2)] - mu_b)
  }
}
var_lda = 1 / (nrow(df) - 2) * foo

# create ellipsoids
a_ell = as.data.frame(ellipse(center = mu_a, shape = var_lda, radius = 2, draw = FALSE))
colnames(a_ell) = c("x1", "x2")
b_ell = as.data.frame(ellipse(center = mu_b, shape = var_lda, radius = 2, draw = FALSE))
colnames(b_ell) = c("x1", "x2")

dens_a =
  dens_b = expand.grid(
    X1 = seq(min(c(classa$X1, classb$X1)), max(c(classa$X1, classb$X1)), l = 50),
    X2 = seq(min(c(classa$X2, classb$X2)), max(c(classa$X2, classb$X2)), l = 50))
dens_a$dens = sqrt(mvtnorm::dmvnorm(dens_a[,1:2], m = mu_a, sigma = var_lda))
dens_b$dens = sqrt(mvtnorm::dmvnorm(dens_b[,1:2], m = mu_b, sigma = var_lda))

## ggplot
plot1 = ggplot(data = classa, aes(x = X1, y = X2, alpha = 0.2)) +
  geom_contour(data = dens_a, aes(z = dens), col = "blue", alpha = .2, lwd = 1, bins = 5) +
  geom_contour(data = dens_b, aes(z = dens), col = "red", alpha = .2, lwd = 1, bins = 5) +
  geom_point(col = "blue", show.legend = FALSE) +
  geom_point(data = classb, aes(x = X1, y = X2, alpha = 0.2), col = "red", show.legend = FALSE) +
  coord_fixed()
plot1
ggsave("../figure/reg_class_dis_1_2.pdf", width = 8, height = 2.5)
dev.off()

