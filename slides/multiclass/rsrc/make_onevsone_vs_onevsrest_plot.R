# ------------------------------------------------------------------------------
# FIG: IRIS SCATTER
# ------------------------------------------------------------------------------


library(ggplot2)
library(cowplot)
library(dplyr)
library(mlr)

# DATA -------------------------------------------------------------------------

n <- 2000
g <- seq(4, 40, by = 3)

# create artificial datasets
dflist <- lapply(g, function(g) data.frame(y = sample(1:g, n, replace = TRUE)))
dflist <- lapply(dflist, function(x) cbind(x, x = x$y + rnorm(n = n, mean = x$y, sd = 0.5)))

tasks <- lapply(dflist, function(x) makeClassifTask(id = paste(max(x$y)), data = x, target = "y"))

rpart.1vs1 <- makeMulticlassWrapper(makeLearner("classif.ksvm", id = "rpart.1vs1", par.vals = list(kernel = "rbfdot")), mcw.method = "onevsone")
rpart.1vsrest <- makeMulticlassWrapper(makeLearner("classif.ksvm", id = "rpart.1vsrest", par.vals = list(kernel = "rbfdot")), mcw.method = "onevsrest")

lrns <- list(rpart.1vs1, rpart.1vsrest)

bmr <- benchmark(lrns, tasks, measures = list(timetrain, mmce))

results <- getBMRPerformances(bmr)

df <- lapply(1:length(results),
             function(x) rbind(cbind(results[[x]][[1]], g = as.numeric(names(results)[[x]]), method = "1vs1"), cbind(results[[x]][[2]], g = as.numeric(names(results)[[x]]), method = "1vsrest")))
df <- do.call("rbind", df)

# df = read.csv(file = "results.csv")

bla <- df %>% group_by(method, g) %>% summarise(timetrain = sum(timetrain))
bla$nclassifs <- NA

bla[bla$method == "1vs1", ]$nclassifs <- (bla[bla$method == "1vs1", ]$g) * (bla[bla$method == "1vs1", ]$g) / 2
bla[bla$method == "1vsrest", ]$nclassifs <- (bla[bla$method == "1vs1", ]$g)

# PLOTS ------------------------------------------------------------------------


p <- ggplot(bla, aes(x = g, y = timetrain, colour = method)) + geom_line()
p <- p + geom_line(data = bla, aes(x = g, y = nclassifs / 5, colour = method), lty = 2)
p <- p + scale_y_continuous("timetrain",
                            sec.axis = sec_axis(~ . * 5, name = "# classifiers trained")
  )

ggsave("../figure/onevsone_vs_onevsrest.png", p, width = 5, height = 3)
