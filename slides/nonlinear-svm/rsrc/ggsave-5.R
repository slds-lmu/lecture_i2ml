set.seed(123L)
x <- cbind(
  c(2,3,4,5,6,0,1,2,3,1,2,3),
  c(0,0,0,0,0,0,1,2,3,-1,-2,-3))
y <- c(-1,-1,-1,-1,-1,1,1,1,1,1,1,1)
df <- data.frame (x = x, y = as.factor(y))
tsk = makeClassifTask(data = df, target = 'y')

plotSVM = function(tsk, par.vals) {

  lrn = makeLearner("classif.svm", par.vals = par.vals)
  set.seed(123L)
  mod = train(lrn, tsk)
  sv.index = mod$learner.model$index
  df = getTaskData(tsk)
  df = df[ifelse(1:getTaskSize(tsk) %in% sv.index, TRUE, FALSE), ]

  set.seed(123L)
  par.set = c(list("classif.svm", tsk), par.vals)
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

## Define two task: one almost linear and one spirals
set.seed(123L)
n = 120
tsk_lin = makeSimulatedTask(n)

tsk_spiral <- convertMLBenchObjToTask("mlbench.spirals",n=300, cycles = 1, sd = 0.12)

############################################################################

gamma <- 1
x.coord = seq(-4,4,length=250)
data_points <- data.frame(x.1= c(1.5,1), x.2= c(0.75,1))
distance <- sqrt((data_points[1,1]-data_points[2,1])^2+(data_points[1,2]-data_points[2,2])^2)
distance

data <- data.frame(
  distance = x.coord,
  k = exp( - gamma * x.coord^2)
)

distance_plot <- ggplot(data = data_points, aes(x.1,x.2)) +
  geom_point() +
  geom_line(color='red') + 
  annotate("text", x = 1, y = 0.6, label = expression(italic(r) == "||"* x - tilde(x)*"||"^{2}), parse = TRUE, color = 'red', size = 5) +
  geom_text(label= c("x", expression(tilde(x))),hjust=1.5, vjust=1.5, size = 5)+
  scale_x_continuous(expand = c(0, 0), limits = c(0,2)) + 
  scale_y_continuous(expand = c(0, 0), limits = c(0, 1.25)) +
  xlab(expression(bold(x[1]))) +
  ylab(expression (bold(x[2])))+
  theme(
    # LABLES APPEARANCE
    plot.title = element_text(size=14, face= "bold", colour= "black" ),
    axis.title.x = element_text(size=14, face="bold", colour = "black"),    
    axis.title.y = element_text(size=14, face="bold", colour = "black"),    
    axis.text.x = element_text(size=14, face="bold", colour = "black"), 
    axis.text.y = element_text(size=14, face="bold", colour = "black"), # bold
    strip.text.x = element_text(size = 10, face="bold", colour = "black" ),
    strip.text.y = element_text(size = 10, face="bold", colour = "black"),
    axis.line.x = element_line(color="black", size = 0.3),
    axis.line.y = element_line(color="black", size = 0.3)
  )


rbf_plot <- ggplot(data = data, aes(x=distance, y=k))+ 
  geom_line()+ 
  geom_vline(xintercept=distance, color = 'red')+
  xlab ("r") +
  ylab(expression(bold(exp( - gamma  ~~ "||" ~~ r ~~ "||"^2))))+
  theme(
    # LABLES APPEARANCE
    plot.title = element_text(size=14, face= "bold", colour= "black" ),
    axis.title.x = element_text(size=14, face="bold", colour = "black"),    
    axis.title.y = element_text(size=14, face="bold", colour = "black"),    
    axis.text.x = element_text(size=14, face="bold", colour = "black"), 
    axis.text.y = element_text(size=14, face="bold", colour = "black"), # bold
    strip.text.x = element_text(size = 10, face="bold", colour = "black" ),
    strip.text.y = element_text(size = 10, face="bold", colour = "black"),
    axis.line.x = element_line(color="black", size = 0.3),
    axis.line.y = element_line(color="black", size = 0.3)
  )



set.seed(123L)
rbf <- plotSVM(tsk, list(kernel = "radial", gamma = 1)) + 
  ggtitle("")+
  xlab(expression(x[1]))+
  ylab(expression (x[2]))



grid.arrange(distance_plot, rbf_plot,rbf,  ncol = 3, widths = c(2,2,3))

############################################################################

plotSVM(tsk_lin, list(kernel = "radial", cost = 1, gamma = 100))



############################################################################


plotSVM(tsk_spiral, list(kernel = "radial", cost = 1, gamma = 10))

############################################################################




############################################################################




############################################################################




############################################################################