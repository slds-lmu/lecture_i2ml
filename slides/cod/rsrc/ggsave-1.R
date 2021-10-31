plotSVM = function(tsk, par.vals) {
  
  lrn = makeLearner("classif.ksvm", par.vals = par.vals)
  set.seed(123L)
  mod = train(lrn, tsk)
  sv.index = mod$learner.model@SVindex
  df = getTaskData(tsk)
  df = df[ifelse(1:getTaskSize(tsk) %in% sv.index, TRUE, FALSE), ]
  
  set.seed(123L)
  par.set = c(list("classif.ksvm", tsk), par.vals)
  q = do.call("plotLearnerPrediction", par.set) + scale_f_d()
  #q = q + geom_point(data = df, color = "black",
  #  size = 6, pch = 21L)
  q
}
set.seed(123L)
makeSimulatedTask = function(size) {
  cluster.size = floor(size / 3)
  x1 = c(rnorm(cluster.size, mean = - 1.5), rnorm(cluster.size/2),
         rnorm(cluster.size, mean = 1.5))
  x2 = c(rnorm(cluster.size, mean = - 1), rnorm(cluster.size/2),
         rnorm(cluster.size, mean = 1))
  y = factor(c(rep("a", times = cluster.size), sample(c("a", "b"),
                                                      size = cluster.size/2, replace = TRUE), rep("b", times = cluster.size)))
  sim.df = data.frame(x1 = x1, x2 = x2, y = y)
  makeClassifTask("simulated example", data = sim.df, target = "y")
}

############################################################################

spam = getTaskData(spam.task)

# cherry pick some good examples
idx = which(spam$type == "spam" & spam$charExclamation <= 0.5  & 
              spam$charExclamation != 0.25 & spam$capitalAve <= 5 & 
              spam$charExclamation > 0)
set.seed(237)
idx = sample(idx)[1:10]
idx = c(idx, which(spam$type == "nonspam" & spam$charExclamation <= 0.5 & spam$capitalAve <= 5 & spam$charExclamation > 0)[5:15])

df = spam[idx, ]

p = ggplot(data = df, aes(x = charExclamation, y = 0, colour = type))
p = p + theme_bw()
p = p + geom_vline(xintercept = c(0, 0.25, 0.5), colour = "grey")
p = p + geom_jitter(height = 0, size = 1)
p = p + ylim(c(0, 1)) + xlim(c(0, 0.5))
p = p + xlab("Frequency of exclamation marks")
p = p + theme(axis.title.y = element_blank(), axis.text.y = element_blank(), axis.ticks.y = element_blank())
p

############################################################################

p = ggplot(data = df, aes(x = charExclamation, y = capitalAve, colour = type))
p = p + theme_bw()
p = p + geom_jitter()
p = p + ylim(c(0, 5)) + xlim(c(0, 0.5))
p = p + xlab("Frequency of exclamation marks") + ylab("Longest sequence of capital letters")
p = p + geom_vline(xintercept = c(0, 0.25, 0.5), color = "grey")
p = p + geom_hline(yintercept = c(0, 2.5, 5), color = "grey")
p


############################################################################

library(scatterplot3d)

colors = c('#bbdf27', '#440154')
colors = colors[as.numeric(df$type)]
scatterplot3d(df[, c("charExclamation", "capitalAve", "your")], 
              xlim = c(0, 0.5), ylim = c(0, 5), zlim = c(0, 2), 
              pch = 16, color=colors, xlab = "Frequency of exclamation marks", 
              ylab = "Longest sequence of capital letters", zlab = "Frequency of word 'your'")


############################################################################

grid = expand.grid(p = c(1, 3, 5, 7, 10), x = seq(0, 1, by = .001))
grid$edgelen = with(grid, (x)^(1/p))

p = ggplot(grid, aes(x = x, y = edgelen, colour = ordered(p), group = ordered(p))) 
p = p + geom_line(show.legend = FALSE) 
p = p + geom_vline(xintercept = .1)
p = p + theme_bw()
p = p + labs(x  = expression("Fraction of Volume"), y = "Edge length of cube")
p = p + annotate("text", x = rep(.25, 5), color = pal_5, y = c(.3, .67, .79, .85, .91), label = paste0("p=",c(1, 3, 5, 7, 10)))
p = p + geom_text(aes(x = .13, y = 0, label = "10 %"), colour = "black", text = element_text(size = 1))
p




############################################################################

fractionedge <- expand.grid(p = c(1, 2, 5, 20), eps = seq(0,1,by=.01))
fractionedge$vol <- with(fractionedge, 1-(1-eps)^p)

p = ggplot(fractionedge, aes(x = eps, y = vol, colour = ordered(p), group = ordered(p))) 
p = p + geom_line(show.legend = FALSE) 
p = p + theme_bw()
p = p + scale_x_continuous(breaks = seq(0, 1,l = 6)) 
p = p + labs(x  = expression("Edge length"~epsilon), y = "Covered volume") 
p = p + annotate("text", x = c(.5, .35, .21, .11), color = pal_4, y = c(.42, .5, .6, .75), label = paste0("p=",c(1, 2, 5, 20)))
p = p + geom_vline(xintercept = 0.2, lty = 2)
# p = p + geom_text(aes(x = .1, y = 0, label = "10 %"))
p

############################################################################

corner_volume <- data.frame(p = seq(2,20))
corner_volume$vol <- with(corner_volume, pi^(p/2)/(2^p*gamma(p/2+1)))

ggplot(corner_volume, aes(x=p, y=vol)) +
  geom_point() +
  geom_line() + 
  xlab("Dimension p") +
  ylab(expression('Volume fraction' ~ 'S'[p](r)/'C'[p](r)))

############################################################################

x <- seq(from = 0, to = 8, length.out = 1000)

S <- function(d){
  return (2 * (pi^(d/2))/gamma(d/2))
}

p <- function(r, d=2, sigma=1){
  return(S(d) * r^(d - 1) / ((2*pi*sigma^2)^(d/2)) * exp(-r^2/(2*sigma^2)))
}

plot_p_r_hist <- function(d = 1, n = 1e4){
  X = rmvnorm(n, rep(0, d))
  ds = apply(X, 1, function(x) sqrt(sum(x*x)))
  
  ggplot(data.frame(x = x), aes(x)) +
    ggtitle(paste0("p = ", d)) +
    stat_bin(data = data.frame(ds = ds), 
             aes(x = ds, y = stat(count) / sum(count) / width), 
             bins = 30, boundary=0) +    
    stat_function(fun = function(r) p(r, d=d), colour="red", size = 1, alpha = 0.8) +
    ylab(NULL) + xlab("r") + ylim(0, 0.85)
  
  
}

set.seed(123)
plots <-lapply(c(1,2,20), function(d) plot_p_r_hist(d = d))
do.call(grid.arrange, c(plots, ncol=3, left="density"))


############################################################################

r_from = 0.9
r_to = 1.1

x <- seq(from = 0, to = 4, length.out = 1000)
p_plot  <- ggplot(data.frame(x = x), aes(x)) +
  stat_function(fun = p) + 
  stat_function(fun = p, 
                xlim = c(r_from, r_to),
                geom = "area", colour="red" , fill="transparent") + 
  ylab("p(r)") + xlab("r")

X <- expand.grid(seq(-2, 2, length.out = 100), seq(-2, 2, length.out = 100))
normal_2d <- dnorm(X[,1])*dnorm(X[,2])

xc = r_to * cos(seq(0,pi,length.out=50))
yc = r_to * sin(seq(0,pi,length.out=50))
xc = c(xc, r_from * cos(seq(pi,0,length.out=50)))
yc = c(yc, r_from * sin(seq(pi,0,length.out=50)))
xc = c(xc, r_to * cos(seq(0,-pi,length.out=50)))
yc = c(yc, r_to * sin(seq(0,-pi,length.out=50)))
xc = c(xc, r_from * cos(seq(-pi,0,length.out=50)))
yc = c(yc, r_from * sin(seq(-pi,0,length.out=50)))

d_plot <- ggplot() + 
  geom_raster(data = data.frame(x1 = X[,1], x2 = X[,2], z = normal_2d), aes(x1, x2, fill=z)) +
  geom_contour(data = data.frame(x1 = X[,1], x2 = X[,2], z = normal_2d), aes(x1, x2, z = z), colour = "white") + 
  geom_polygon(data = data.frame(x=xc, y=yc), fill="red", alpha = 0.7,
               aes(x,y)) +
  labs(fill = "density")

grid.arrange(p_plot, d_plot, ncol=2, 
             bottom = textGrob("Example: 2D normal distribution"))


############################################################################

library(scatterplot3d)

n <- 10000
phi = 1.5 * 2* pi* runif(n)

x = phi*sin(phi)
y = phi*cos(phi)
z = runif(n)
scatterplot3d(data.frame(x, y, z), angle = 300, color = phi,
              sub = "2D manifold in 3D feature space", axis = FALSE)



############################################################################


############################################################################
