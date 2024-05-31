library(mlr)
library(parallelMap)
library(BBmisc)

learners = list(makeLearner("classif.ranger", num.threads = 1L), 
                makeLearner("classif.randomForest"))
#mtry, sample.fraction and ntree is defaults to the same values for both methods!

time = TRUE  # whether we want to compare time or compare accuracy
library(assertthat)
assertthat::assert_that(packageVersion("OpenML") == "1.3")
library(OpenML)
setOMLConfig(apikey = "c1994bdb7ecb3c6f3c8f3b35f4b47f1f", arff.reader="farff")
all.tasks = listOMLTasks()

tasks = subset(all.tasks,
               task.type == "Supervised Classification" &
                 number.of.classes == 2 &
                 estimation.procedure == "10-fold Crossvalidation" &
                 number.of.missing.values == 0 &
                 number.of.instances > 5000 &
                 number.of.instances < 10000 &
                 number.of.numeric.features < number.of.instances &
                 evaluation.measures == "predictive_accuracy")


set.seed(1)
tasks = tasks[sample(nrow(tasks),6L), ]
bmrs = list()
parallelStartMulticore(cpus = 4L, level = "mlr.resample")
# I have 4 cores on my computer, so should change accordingly

for (i in 1:length(tasks$task.id)) {
  task.id = tasks$task.id[i]
  otask = getOMLTask(task.id)
  #if(time) {
  #  otask$input$evaluation.measures = c("usercpu_time_millis")
  #}

  
  res = tryCatch({
    if(time)
    res = lapply(learners, runTaskMlr, task = otask, measures = timetrain)
    else
    res = lapply(learners, runTaskMlr, task = otask)
    extractSubList(res, "bmr", simplify = FALSE)
    
  }, error = function(e) print(e))
  if (!inherits(res, "error")) {
    bmrs[[i]] = mergeBenchmarkResults(res)
  } else {
    bmrs[[i]] = res
  }
  
}
parallelStop()

#Task 4 is an error
bmrs[[4]] = NULL
# bmrs = lapply(bmrs, function(x) {ifelse(inherits(x, "error"), NULL, x)})

bmr = mergeBenchmarkResults(bmrs)
file = ifelse(time, "traintime.pdf", "accuracy.pdf")

pdf(file = file)

if (time) {
  plotBMRBoxplots(bmr, measure = timetrain)
  plotBMRSummary(bmr, measure = timetrain) 
} else {
  plotBMRBoxplots(bmr)
  plotBMRSummary(bmr) }
dev.off()
