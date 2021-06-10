## COD Regression example

d = getTaskData(bh.task)                                                                                                   
n = nrow(d)

# creating 500 noise variables
p = 500
x = data.frame(replicate(p, rnorm(n)))                                                                                   
d = cbind(d, x)                                                                                              
task = makeRegrTask(data = d, target = "medv")                                                         

# creating subtasks for increasing sequence of subspaces of the feature space (p = 5, 7, 9, ...)
noise.feat.seq = c(0, 100, 200, 300, 400, 500)                                                    
tasks = lapply(noise.feat.seq, function(k) {                                                                 
  tt = subsetTask(task, features = 1:(12 + k))                                                               
  tt$task.desc$id = sprintf("task%02i", k)                                                                   
  return(tt)                                                                                                 
})       

rdesc = makeResampleDesc("RepCV", folds = 10L, reps = 10L)

lrns = makeLearners(c("regr.lm", "regr.rpart"))

bres = benchmark(lrns, tasks, resamplings = rdesc, show.info = TRUE)

res = as.data.table(bres)[, mean(mse), by = c("task.id", "learner.id")]
names(res)[3] = "mse.test.mean"
res = res[order(learner.id), ]
res$d = rep(seq(0, 500, by = 100), 2)

saveRDS(object = res, "code/cod_lm_rpart.rds")

set.seed(1234)
res <- matrix(nrow=100, ncol = 5)
for(k in 0:4){
  for(i in 1:10){
    idx <- sample(1:10, n, replace = TRUE)
    for(j in 1:10){
      X <- model.matrix(medv ~ ., d[idx != j,1:(14 + k*100)])
      res[(i-1)*10 + j, k+1] <- kappa(t(X) %*% X)
    }
  }
}
cond_numbers <- reshape::melt(res)
cond_numbers$X2 <- as.factor((cond_numbers$X2-1) * 100)

saveRDS(object = cond_numbers, "code/cod_lm_cond.rds")