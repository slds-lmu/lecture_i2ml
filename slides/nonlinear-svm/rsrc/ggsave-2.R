
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

############################################################################

set.seed(123L)
#matrix
x <- cbind(
  c(2,3,4,5,6,0,1,2,3,1,2,3),
  c(0,0,0,0,0,0,1,2,3,-1,-2,-3))

#class
y <- c(-1,-1,-1,-1,-1,1,1,1,1,1,1,1)

#create data frame
df <- data.frame (x = x, y = as.factor(y))

#make task
tsk = makeClassifTask(data = df, target = 'y')

linear_svm <- plotSVM(tsk, list(kernel = "linear", 
                                nu = 0.2, 
                                tolerance = 0.001, 
                                cost = 1, 
                                type = "C-classification", 
                                scale = FALSE)) + 
  ggtitle("")+
  xlab(expression(x[1]))+
  ylab(expression (x[2]))
linear_svm


############################################################################


set.seed(123L)

two <- plotSVM(tsk, list(kernel = "polynomial", degree = 2, coef0 = 1, gamma = 1)) + 
  ggtitle("d = 2")+
  xlab(expression(x[1]))+
  ylab(expression (x[2]))
three <- plotSVM(tsk, list(kernel = "polynomial", degree = 3, coef0 = 1, gamma = 1)) + 
  ggtitle("d = 3")+
  xlab(expression(x[1]))+
  ylab(expression (x[2]))

grid.arrange(two, three, ncol= 2)



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

     
library(xtable)
    load("data/mnist_svm_mixed.RData")

table_df = as.data.frame(mnist_test_mmce_mixed$mmce[c(1,2,4,5)])
rownames(table_df) = c("linear", "poly (d = 2)", "RBF (gamma = 0.001)", "RBF (gamma = 1)")
colnames(table_df) = "Error"

print(xtable(signif(table_df, 3), digits = 3, display = rep("fg", 2), align = "r|l"),
  row.names = FALSE, sanitize.colnames.function = function(x) x, include.rownames = TRUE,
  hline.after = 0, latex.environments = "small")
    


############################################################################




############################################################################




############################################################################