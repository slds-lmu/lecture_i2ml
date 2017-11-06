
getData = function(n) {
  z = mlbench.waveform(n)
  as.data.frame(z)
}

getTrainTask = function(n) {
  d = getData(n)
  task = makeClassifTask(data = d, target = "classes")
  return(task)
}

lrn = makeLearner("classif.rpart")
ntrain = 500L
ntest = 1000L

train.task = getTrainTask(ntrain)
mod = train(lrn, train.task)

res = makeDataFrame(nrow = 10, ncol = 2, col.types = "numeric", col.names = c("n.test", "perf"))

repls = 1:50
ntests = seq(100, 1000, by = 200)
exps = expand.grid(repl = repls, ntest = ntests)

z = rowLapply(exps, function(r) {
  testdata = getData(r$ntest)
  pred = predict(mod, newdata = testdata)
  perf = performance(pred)
  perf
})

exps$perf = as.numeric(z)

ggd = exps
pl = ggplot(ggd, aes(perf))
pl = pl + geom_histogram()
pl = pl + facet_grid(~ ntest, scales = "free")
# pl = annotate(geom = "line", x = 0.25)
print(pl)

# simul = function(train, test) {

# }

