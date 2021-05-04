library(mlr)
library(ggplot2)
library(parallelMap)
parallelStartMulticore(30)

task = pid.task

ps = makeParamSet(
  makeNumericParam("cost", lower = -5, upper = 20, trafo = function(x) 2^x),
  makeNumericParam("gamma", lower = -20, upper = 5, trafo = function(x) 2^x)
)
ctrl = makeTuneControlGrid(resolution = 40)

tr = tuneParams("classif.svm", task, resampling = hout, par.set = ps, control = ctrl)

pd = generateHyperParsEffectData(tr)

pl = plotHyperParsEffect(pd, x = "cost", y = "gamma", z = "mmce.test.mean", 
  plot.type = "contour", show.interpolated = TRUE)
print(pl + scale_f() + #scale_c() +
    geom_contour(color = "white") + 
    ylab(expression("inverse kernel width ["~log[2]~"]")) + 
    xlab(expression("C ["~log[2]~"]")))

ggsave("figure_man/kernels/hyperpar-tuning.pdf", width = 8, height = 5)


ps = makeParamSet(
  makeNumericParam("cost", lower = -5, upper = 20, trafo = function(x) 2^x),
  makeIntegerParam("degree", lower = 1L, upper = 10L)
)
ctrl = makeTuneControlGrid(resolution = 40) 

lrn = makeLearner("classif.svm", par.vals = list(kernel = "polynomial"))

parallelMap::parallelStartSocket(5L)
tr = tuneParams(lrn, task, resampling = hout, par.set = ps, control = ctrl)
parallelMap::parallelStop()

pd = generateHyperParsEffectData(tr)

pl = plotHyperParsEffect(pd, x = "cost", y = "degree", z = "mmce.test.mean", 
  plot.type = "contour", show.interpolated = TRUE)
print(pl + #scale_f() + #scale_c() +
    geom_contour(color = "white") + 
    ylab(expression("degree")) + 
    xlab(expression("C ["~log[2]~"]")))

ggsave("figure_man/kernels/hyperpar-tuning2.pdf", width = 8, height = 5)
