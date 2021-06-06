library(gbm)
library(mlr)
library(iml)
library(plotly)
theme_set(theme_bw())

# simulation setting
n = 500
set.seed(123)
x1 = round(runif(n, -1, 1), 3)
x2 = round(runif(n, -1, 1), 3)
eps = rnorm(n, 0, 1)

#y = x1 - x2 + x2*2*x1 + eps
y = x1 - x2 + 5*cos(x2*5)*x1 + eps
dat = data.frame(x1, x2, y)
X = dat[, setdiff(colnames(dat), "y")]

# Fit gbm with interaction depth = 1 and create PDP plots
task = makeRegrTask(data = dat, target = "y")
learner = makeLearner("regr.gbm", par.vals = list(interaction.depth = 1))
set.seed(123)
mod = train(learner, task)
model = Predictor$new(mod, data = dat)
effect1 = FeatureEffect$new(model, method = "pdp", grid.size = 20, feature = "x1")
p1 = effect1$plot() + ylab(expression(paste(hat(f)[1]))) + ylim(-0.75, 1) +
  geom_segment(aes(x = 0.999, y = -0.7, xend = 0.999, yend = effect1$results$.value[which(effect1$results$x1==0.999)]), col = "blue", linetype = "dashed") +
  geom_segment(aes(x = -1, y = effect1$results$.value[which(effect1$results$x1==0.999)], xend = 0.999, yend = effect1$results$.value[which(effect1$results$x1==0.999)]), col = "blue", linetype = "dashed")+
  annotate('text', x = 0.86, y = effect1$results$.value[which(effect1$results$x1==0.999)]+0.1, 
           label = "hat(f)[1]~(0.999)==0.84",parse = TRUE,size=3.5, col="blue") +
  geom_segment(aes(x = -0.999, y = -0.7, xend = -0.999, yend = effect1$results$.value[which(effect1$results$x1==-0.999)]), col = "blue", linetype = "dashed") +
  geom_segment(aes(x = -1, y = effect1$results$.value[which(effect1$results$x1==-0.999)], xend = -0.999, yend = effect1$results$.value[which(effect1$results$x1==-0.999)]), col = "blue", linetype = "dashed")+
  annotate('text', x = -0.8, y = effect1$results$.value[which(effect1$results$x1==-0.999)]+0.17, 
           label = "hat(f)[1]~(-0.999)==0.3",parse = TRUE,size=3.5, col="blue") 


effect2 = FeatureEffect$new(model, method = "pdp", grid.size = 20, feature = "x2")
p2 = effect2$plot()+ ylab(expression(paste(hat(f)[2]))) + ylim(-0.9, 1.2) +
  geom_segment(aes(x = 0.99, y = -0.9, xend = 0.99, yend = effect2$results$.value[which(effect2$results$x2==0.99)]), col = "blue", linetype = "dashed") +
  geom_segment(aes(x = -1, y = effect2$results$.value[which(effect2$results$x2==0.99)], xend = 0.99, yend = effect2$results$.value[which(effect2$results$x2==0.99)]), col = "blue", linetype = "dashed")+
  annotate('text', x = 0.86, y = effect2$results$.value[which(effect2$results$x2==0.99)]+0.3, 
           label = "hat(f)[2]~(0.99)==-0.76",parse = TRUE,size=3.5, col="blue") +
  geom_segment(aes(x = -0.998, y = -0.9, xend = -0.998, yend = effect2$results$.value[which(effect2$results$x2==-0.998)]), col = "blue", linetype = "dashed") +
  geom_segment(aes(x = -1, y = effect2$results$.value[which(effect2$results$x2==-0.998)], xend = -0.998, yend = effect2$results$.value[which(effect2$results$x2==-0.998)]), col = "blue", linetype = "dashed")+
  annotate('text', x = -0.73, y = effect2$results$.value[which(effect2$results$x2==-0.998)]+0.15, 
           label = "hat(f)[2]~(-0.998)==0.96",parse = TRUE,size=3.5, col="blue") 
#effect = FeatureEffect$new(model, method = "pdp", grid.size = 20, feature = c("x1","x2"))
#p2d = effect$plot()

p = gridExtra::grid.arrange(p1,p2)#, layout_matrix = rbind(c(1,3),c(2,3)))
ggsave(file = "figure_man/boosting_interaction_example_gam.png", plot = p, width = 6, height = 5)

# 3D surface plot for ID = 1
newx <- effect1$results$x1
newy <- effect2$results$x2
newxy <- expand.grid(x1 = newx, x2 = newy)
z <- matrix(predict(mod, newdata = newxy)$data$response, 20, 20, byrow = TRUE)
p3d = plot_ly(x = newx, y = newy, z = z) %>% add_surface() 
p3d %>% layout(scene = list(xaxis = list(title = "x1"), yaxis = list(title = "x2"), zaxis = list(title = "y")))
# (save png from plotly)

# create model only containing x1
# x = 1
# pred_m = c()
# 
# x.grid = seq(-1, 1, len=20)
# trees = mod$learner.model$trees
# for(grid.point in x.grid){
#   for(i in 1:mod$learner.model$n.trees){
#     tree = trees[[i]]
#     if(tree[[1]][1] == x){
#       if(grid.point <= tree[[2]][1]) pred = tree[[8]][2]#*tree[[7]][2]/tree[[7]][1]
#       else pred = tree[[8]][3]#*tree[[7]][3]/tree[[7]][1]
#       
#       if(i == 1) pred_m_xi = mod$learner.model$initF
#       pred_m_xi = pred_m_xi + 0.1 * pred
#     }
#    
#     
#   }
#   pred_m = c(pred_m, pred_m_xi)
#  
# }

#model$predict(newdata = newxy)[1:2,]

# Fit gbm with interaction depth = 2 and create PDP plots
learner = makeLearner("regr.gbm", par.vals = list(interaction.depth = 2))
set.seed(123)
mod = train(learner, task)
model = Predictor$new(mod, data = dat)
effect1 = FeatureEffect$new(model, method = "pdp", grid.size = 20, feature = "x1")
p1 = effect1$plot() + ylab(expression(paste(hat(f)[1]))) + ylim(-1, 1.2) +
  geom_segment(aes(x = 0.999, y = -0.7, xend = 0.999, yend = effect1$results$.value[which(effect1$results$x1==0.999)]), col = "blue", linetype = "dashed") +
  geom_segment(aes(x = -1, y = effect1$results$.value[which(effect1$results$x1==0.999)], xend = 0.999, yend = effect1$results$.value[which(effect1$results$x1==0.999)]), col = "blue", linetype = "dashed")+
  annotate('text', x = 0.86, y = effect1$results$.value[which(effect1$results$x1==0.999)]+0.23, 
           label = "hat(f)[1]~(0.999)==0.59",parse = TRUE,size=3.5, col="blue") +
  geom_segment(aes(x = -0.999, y = -1, xend = -0.999, yend = effect1$results$.value[which(effect1$results$x1==-0.999)]), col = "blue", linetype = "dashed") +
  geom_segment(aes(x = -1, y = effect1$results$.value[which(effect1$results$x1==-0.999)], xend = -0.999, yend = effect1$results$.value[which(effect1$results$x1==-0.999)]), col = "blue", linetype = "dashed")+
  annotate('text', x = -0.9, y = effect1$results$.value[which(effect1$results$x1==-0.999)]+0.2, 
           label = "hat(f)[1]~(-0.999)==0.2",parse = TRUE,size=3.5, col="blue") 
effect2 = FeatureEffect$new(model, method = "pdp", grid.size = 20, feature = "x2")
p2 = effect2$plot() + ylab(expression(paste(hat(f)[2]))) + ylim(-1, 1.2) +
  geom_segment(aes(x = 0.99, y = -1, xend = 0.99, yend = effect2$results$.value[which(effect2$results$x2==0.99)]), col = "blue", linetype = "dashed") +
  geom_segment(aes(x = -1, y = effect2$results$.value[which(effect2$results$x2==0.99)], xend = 0.99, yend = effect2$results$.value[which(effect2$results$x2==0.99)]), col = "blue", linetype = "dashed")+
  annotate('text', x = 0.86, y = effect2$results$.value[which(effect2$results$x2==0.99)]+0.3, 
           label = "hat(f)[2]~(0.99)==-0.63",parse = TRUE,size=3.5, col="blue") +
  geom_segment(aes(x = -0.998, y = -0.9, xend = -0.998, yend = effect2$results$.value[which(effect2$results$x2==-0.998)]), col = "blue", linetype = "dashed") +
  geom_segment(aes(x = -1, y = effect2$results$.value[which(effect2$results$x2==-0.998)], xend = -0.998, yend = effect2$results$.value[which(effect2$results$x2==-0.998)]), col = "blue", linetype = "dashed")+
  annotate('text', x = -0.73, y = effect2$results$.value[which(effect2$results$x2==-0.998)]+0.1, 
           label = "hat(f)[2]~(-0.998)==0.99",parse = TRUE,size=3.5, col="blue") 
#effect = FeatureEffect$new(model, method = "pdp", grid.size = 20, feature = c("x1","x2"))
#p2d = effect$plot()

pint = gridExtra::grid.arrange(p1,p2)#, p2d, layout_matrix = rbind(c(1,3),c(2,3)))
ggsave(file = "figure_man/boosting_interaction_example_ID2.png", plot = pint, width = 6, height = 5)

# 3D surface for ID = 2
newx <- effect1$results$x1
newy <- effect2$results$x2
newxy <- expand.grid(x1 = newx, x2 = newy)
z <- matrix(predict(mod, newdata = newxy)$data$response, 20, 20, byrow = TRUE)
p = plot_ly(x = newx, y = newy, z = z) %>% add_surface()
p %>% layout(scene = list(xaxis = list(title = "x1"), yaxis = list(title = "x2"), zaxis = list(title = "y")))
# (save png from plotly)


# create surface plot for target function
y_test = matrix((newxy[,1] - newxy[,2] + 5*cos(newxy[,2]*5)*newxy[,1]),20,20, byrow = TRUE)
p = plot_ly(x = newx, y = newy, z = y_test) %>% add_surface()  %>% layout(scene = list(xaxis = list(title = "x1"), yaxis = list(title = "x2"), zaxis = list(title = "y")))
p
# (save png from plotly)




