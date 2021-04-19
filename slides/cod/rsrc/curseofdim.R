library(mlr)
library(ggplot2)

set.seed(1234)
lrns = makeLearners(c("classif.kknn", "classif.rpart"))                                                      

d = iris                                                                                                     
n = nrow(d)

# creating p = 500 noise variables 
p = 500
x = replicate(p, rnorm(n))                                                                                   
colnames(x) = paste0("V", 1:p)                                                                               
d = cbind(d, x)                                                                                              
task = makeClassifTask(data = d, target = "Species")                                                         

# creating subtasks for increasing sequence of subspaces of the feature space (p = 5, 7, 9, ...)
noise.feat.seq = floor(seq(0L, 50L, by = 2L))                                                                
tasks = lapply(noise.feat.seq, function(k) {                                                                 
  tt = subsetTask(task, features = c(1:(5 + k)))                                                               
  tt$task.desc$id = sprintf("task%02i", k)                                                                   
  return(tt)                                                                                                 
})       

# comparing the knn and CART via the mmce
rdesc = makeResampleDesc("RepCV", folds = 10L, reps = 10L)                                                   
b = benchmark(lrns, tasks, rdesc, show.info = TRUE)                                                          
res = getBMRAggrPerformances(b, as.df = TRUE)                                                                
res$k = as.integer(substr(res$task.id, 5, 6))                                                                

pdf("../figure_man/curseofdim.pdf", height  = 5.8, width = 8)
qplot(k, mmce.test.mean, col = learner.id, data = res, geom  = "line",
  xlab = "# of noise variables", ylab = "mean misclassification error") + 
  viridis::scale_color_viridis(discrete = TRUE)
dev.off()
