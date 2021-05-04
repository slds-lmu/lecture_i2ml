
library(mlr)
library(mlbench)
library(ggplot2)
library(gridExtra)



#############################################
#entropy
plot_ent = function(p) {
  n = length(p)
  lp = -log(p)
  lp = ifelse(p == 0, 0, lp)
  r = p * lp
  H = sum(r)
  dd = data.frame(x = 1:n, p = p, lp = lp, r = r)
  pl = ggplot(data = dd, aes(x = x))
  pl = pl + geom_bar(aes(y = p),stat = "identity")
  # pl = pl + geom_line(aes(y = r))
  pl = pl + ggtitle(sprintf("Entropy H(p) = %.1f", H))
  # pl = pl + ylab(sprintf("p [bar] and -plog(p) [line] ", H))
  return(pl)
}

p = c(0.2, 0.2, 0.2, 0.2, 0.2)
pl1 = plot_ent(p)
p = c(0.1, 0.2, 0.4, 0.2, 0.1)
pl2 = plot_ent(p)
p = c(0.4, 0.2, 0.2, 0.1, 0.1)
pl3 = plot_ent(p)
p = c(0.1, 0.1, 0.6, 0.1, 0.1)
pl4 = plot_ent(p)

grid.arrange(pl1, pl2, pl3, pl4, nrow = 2, ncol = 2)

################################################
#entropy uniform
entropy_function <- function(g) log(g, base = 2)

g <- seq(2L,10L)

entropy <- entropy_function(g)

data <- as.data.frame(cbind('g' = factor(g), 'H(X)' = entropy))

ggplot(data = data, aes(x = g, y = `H(X)`)) + 
  geom_bar(stat = "identity") + 
  scale_x_discrete(limits = as.character(g))

################################################





