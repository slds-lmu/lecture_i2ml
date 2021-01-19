# if (!exists("TunerCMAES", where = "package:mlr3tuning")) {
#   remotes::install_github("mlr-org/bbotk")
#   remotes::install_github("mlr-org/mlr3tuning@bbotk_cmaes")
#   remotes::install_github("mlr-org/mlr3oml")
# }

library(mlr3)
library(mlr3misc)
library(mlr3learners)
library(mlr3tuning)
library(adagio)
library(ecr)
library(paradox)
library(future)
library(batchtools)
library(ggplot2)
library(stringi)
library(gridExtra)
library(data.table)
library(checkmate)
library(R6)
library(mlr3oml)
library(kernlab)

# mlr3tuning has to be present in ~/gits/mlr3tuning
mlr3tuningdir = "~/gits/mlr3tuning"
if (!fs::dir_exists(mlr3tuningdir)) {
  system(paste0("git clone --depth 1 git@github.com:mlr-org/mlr3tuning.git ", mlr3tuningdir))
}

set.seed(1)

#define 1! leaners
learner = lrn("classif.svm", predict_type = "prob", cost = 1, gamma = 1, type = "C-classification", kernel = "radial")
measure = msr("classif.acc")

n_evalss = c(25,100)

#define n tuners
tuner_terms = lapply(n_evalss, function(n_evals) {
  tuners = tnrs(c("grid_search", "random_search"))
  tuners[[1]]$param_set$values$resolution = ceiling(sqrt(n_evals))
  
  source(file = fs::path_join(c(mlr3tuningdir, "attic", "TunerCMAES.R")))
  tuners$TunerCMAES = TunerCMAES$new()

  source(file = fs::path_join(c(mlr3tuningdir, "attic", "TunerECRSimpleEA.R")))
  tuners$TunerECRSimpleEA = TunerECRSimpleEA$new()
  
  lapply(tuners, function(x) list(tuner = x, term = term("evals", n_evals = n_evals)))
})
tuner_terms = unlist(tuner_terms, recursive = FALSE)

#define m tasks
# tasks = tsks(c("spam", "sonar")) #, "german_credit"))
# tasks = c(tasks, 
#   lapply(c(optdigits = 28,  ionosphere = 59), function(id) {
#     tsk("oml", data_id = id)
# }))
tasks = tsks(c("spam"))

ps = ParamSet$new(params = list(
    ParamDbl$new("cost", lower = -15, upper = 15),
    ParamDbl$new("gamma", lower = -15, upper = 15)
))

ps$trafo = function(x, param_set) {
  lapply(x, function(x) 2^x)
}

rsmp_tuning =  rsmp("cv", folds = 5)
#rsmp_tuning = rsmp("cv", folds = 2)

rsmp_outer = rsmp("cv", folds = 10)
#rsmp_outer = rsmp("cv", folds = 2)

learners = Map(function(ps, tuner_terms) {
  learner$encapsulate = c(train = "evaluate", predict = "evaluate")
  learner$fallback = lrn("classif.featureless")
  learner = AutoTuner$new(learner = learner, resampling = rsmp_tuning, measures = measure, terminator = tuner_terms$term, search_space = ps, tuner = tuner_terms$tuner)  
  learner$id = paste0(learner$id, ".", tuner_terms[[1]]$term$param_set$values$n_evals)
  return(learner)
}, ps = list(ps), tuner_terms)

#add baseline
LearnerClassifSVMdef = R6Class("LearnerClassifSVMdef",
  inherit = LearnerClassifSVM,
  private = list(
    .train = function(task){
    self$param_set$values$kernel = "radial"
    self$param_set$values$gamma = kernlab::sigest(x = as.matrix(task$data(cols = task$feature_names)))[[2]] # why is this stochastic? 
    # also in kernlab they say that sigma is inverse kernel width but formula is 
    # exp(sigma * (2 * crossprod(x, y) - crossprod(x) - crossprod(y))). 
    # this crossprod stuff calculates the distance but negative
    # in e1071 the say gamma is normal kernel width and formula is
    # exp(-gamma*|u-v|^2), )
    # so sigma = gamma
    # also checked manually that the result with this gamma works well
    super$.train(task)
  })
)
learner_default = LearnerClassifSVMdef$new()
learner_default$id = paste0(learner_default$id, ".default")

#build design
design = benchmark_grid(tasks = tasks, learners = c(learners, learner, learner_default), resamplings = rsmp_outer)


#init inner resampling for all AutoTuners #FIXME Does not work because we would have to do it for the internal split
# design[, task_hash := map_chr(task, function(x) x$hash)]
# init_autotuner = function(task, at_learner) {
#   resampling = at_learner[[1]]$instance_args$resampling #already cloned
#   resampling$instantiate(task[[1]]) #all tasks are the same
#   for (lrn in at_learner) {
#     lrn$instance_args$resampling = resampling$clone()
#   }
#   return(list(at_learner))
# }
# design[map_lgl(learner, inherits, "AutoTuner"), learner := init_autotuner(.SD$task, .SD$learner), by = task_hash]
# design$task_hash = NULL

#init parallelization
if (!fs::file_exists("benchmark_res.rds")) {
  reg_dir = if (fs::file_exists("~/nobackup/")) "~/nobackup/w04_hpo_benchmark" else "w04_hpo_basics/code/benchmark_bt"
  unlink(reg_dir, recursive = TRUE)
  reg = makeRegistry(
    file.dir = reg_dir, 
    seed = 1, 
    packages = c("mlr3", "mlr3tuning", "mlr3misc", "stringi", "future", "adagio", "ecr", "kernlab", "e1071", "R6"), #R6 needed so source (below) works correctly
    source = c(fs::path_join(c(mlr3tuningdir, "attic", "TunerCMAES.R")), #can contain functions that are not in the created object
               fs::path_join(c(mlr3tuningdir, "attic", "TunerECRSimpleEA.R"))) #see above
  )
  
  batchMap(function(design, ...) {
    #makes inner resampling folds the same if the outer resampling is the same?
    set.seed(as.integer(substr(stri_replace_all_regex(design$resampling[[1]]$hash, "[a-z]", ""),0,9)))
    options(mc.cores = design$resampling[[1]]$param_set$values$folds %??% 10)
    future::plan(multiprocess)
    res = benchmark(design = design, ...)
    for (i in seq_row(res$data)) {
      if(!is.null(res$data$learner[[i]]$tuning_instance)) {
        res$data$learner[[i]]$tuning_instance$archive$data[,resample_result := NULL]
      }
    }
    return(res)
  }, store_models = TRUE, design = split(design, seq_row(design)))
  
  #testJob(1)
  submitJobs(resources = list(ncpus = rsmp_outer$param_set$values$folds %??% 10, memory = 16000))
  waitForJobs()
  res = reduceResultsList(findDone())
  res_tune = res[[1]]
  res_baseline = NULL
  for (i in 2:length(res)) {
    if (inherits(res[[i]]$learners$learner[[1]], "AutoTuner")) {
      res_tune$combine(res[[i]])
    } else if (is.null(res_baseline)) {
      res_baseline = res[[i]]
    } else {
      res_baseline$combine(res[[i]])
    }
  }
  
  
  saveRDS(list(baseline = res_baseline, tune = res_tune), "benchmark_res.rds")
}

res = readRDS("benchmark_res.rds")

xx = res$baseline$aggregate(measures = measure)
res_baseline = map_dtr(xx$resample_result, function(x) x$score(measure))


#build dt for plotting
res_compl = res$tune$data[, list(opt_path = {
  x = learner[[1]]
  list(cbind(x$archive$data, tuner = class(x$tuner)[1], task_id = x$model$tuning_instance$objective$task$id, learner_id = x$learner$id, nr = seq_row(x$archive$data), budget = x$model$tuning_instance$terminator$param_set$values$n_evals))
  }), by = .(uhash, iteration)]
res_compl = setDT(tidyr::unnest(res_compl, "opt_path")) #tidyr::unnest can deal with data.frames to be unnested
res_compl = unnest(res_compl, "opt_x", prefix = "opt.x.")

#randomize grid search order
res_compl[tuner == "TunerGridSearch", nr := sample(x = nr), by = .(task_id, learner_id, uhash, iteration, budget)]
setkey(res_compl, task_id, learner_id, uhash, iteration, budget, nr)

res_compl[, classif.acc.cummax := cummax(classif.acc), by = .(task_id, learner_id, tuner, uhash, iteration, budget)]
res_compl[, tuner := stri_replace_first_fixed(tuner, "Tuner", "")]
res_compl = res_compl[nr <= budget,]

res_outer = res$tune$score(measures = measure)

#reduce size
rm(res)
#gc()


theme_set(theme_bw())

EVAL_ITERS = 100
DATASET = "spam"
tuners_select = c("GridSearch", "RandomSearch", "CMAES", "(1+1)-EA" = "ECRSimpleEA", "Untuned", "Heuristic")
names(tuners_select) = ifelse(nzchar(names(tuners_select)), names(tuners_select), tuners_select)
tuner_colors = set_names(RColorBrewer::brewer.pal(length(tuners_select), "Set1"), names(tuners_select))

# reduce data
res_compl[, tuner := factor(tuner, levels = tuners_select, labels = names(tuners_select))]
res_compl = res_compl[budget == EVAL_ITERS & task_id %in% DATASET,]

#tune curve for iter = 1
g = ggplot(res_compl[iteration == 1,], aes(y = classif.acc.cummax, x = nr, color = tuner))
g = g + geom_line()
g = g + geom_point(aes(y = classif.acc), alpha = 0.1)
g = g + facet_wrap("task_id", scales = "free")
#g = g + coord_cartesian(ylim = c(0.7, 1))
g = g + scale_color_manual(values = tuner_colors)
g = g + labs(y = "ACC", x = "eval", title = "Tuning cost and gamma for SVM (kernel = radial)", fill = "Tuner")
if (interactive()) {
  print(g)
}
ggsave("../images/benchmark_curve_iter_1.png", g, height = 5, width = 7)

#tune curve for all iters
g = ggplot(res_compl, aes(y = classif.acc.cummax, x = nr, color = tuner, group = paste0(tuner, iteration)))
g = g + geom_line(alpha = 0.5)
g = g + facet_wrap("task_id", scales = "free")
g = g + scale_color_manual(values = tuner_colors)
g = g + labs(y = "ACC", x = "eval", title = "Tuning cost and gamma for SVM (kernel = radial)", fill = "Tuner")
if (interactive()) {
  print(g)
}
ggsave("../images/benchmark_curve_iter_all.png", g, height = 5, width = 7)

#tune curve for all iters averaged
g = ggplot(res_compl, aes(y = classif.acc.cummax, x = nr, color = tuner))
g = g + stat_summary(geom = "line", fun = median)
g = g + facet_wrap("task_id", scales = "free")
g = g + scale_color_manual(values = tuner_colors)
g = g + labs(y = "ACC", x = "eval", title = "Tuning cost and gamma for SVM (kernel = radial)", fill = "Tuner")
if (interactive()) {
  print(g)
}
ggsave("../images/benchmark_curve_median.png", g, height = 5, width = 7)

#tune curve for all iters averaged + individual
g = ggplot(res_compl, aes(y = classif.acc.cummax, x = nr, color = tuner))
g = g + geom_line(alpha = 0.2, mapping = aes(group = paste0(tuner, iteration)))
g = g + stat_summary(geom = "line", fun = median)
g = g + facet_wrap("task_id", scales = "free")
g = g + scale_color_manual(values = tuner_colors)
g = g + labs(y = "ACC", x = "eval", title = "Tuning cost and gamma for SVM (kernel = radial)", fill = "Tuner")
if (interactive()) {
  print(g)
}
ggsave("../images/benchmark_curve_iter_all_median.png", g, height = 5, width = 7)

# outer performance
res_outer = res_outer[map_lgl(learner, function(x) x$model$tuning_instance$terminator$param_set$values$n_evals == EVAL_ITERS) & task_id %in% DATASET, ]
res_outer[, tuner := map_chr(learner, function(x) class(x$tuner)[[1]])]
res_outer[, tuner := stri_replace_first_fixed(tuner, "Tuner", "")]
res_outer[, tuner:=factor(tuner, levels = tuners_select, labels = names(tuners_select))]
res_baseline[, tuner := ifelse(stri_detect_fixed(learner_id, "default"), "Heuristic", "Untuned")]
res_baseline[, tuner:=factor(tuner, levels = tuners_select, labels = names(tuners_select))]
res_combined = rbind(res_baseline[task_id %in% DATASET,], res_outer, fill = TRUE)

settings = list(
  tuners = list(name = "tuners", tuners = unique(res_outer$tuner)),
  untuned = list(name = "default", tuners = c(unique(res_outer$tuner), "Untuned")),
  all = list(name = "all", tuners = unique(res_combined$tuner))
)
for (s in settings) {
  g = ggplot(res_combined[tuner %in% s$tuners,], aes(x = tuner, y = classif.acc, fill = tuner))
  g = g + geom_boxplot()
  g = g + scale_fill_manual(values = tuner_colors)
  g = g + facet_grid(task_id~.)
  g = g + labs(y = "ACC", x = NULL, fill = "Tuner", title = "SVM performance on outer test set")
  g = g + coord_flip(ylim = s$ylim)
  if (interactive()) {
    print(g)
  }
  ggsave(sprintf("../images/benchmark_boxplot_%s.png", s$name), g, height = 5, width = 7)
}

#tune x space
gs = lapply(unique(res_compl$task_id), function(this_task_id) {
  #this_task_id = "spam"
  g = ggplot(res_compl[task_id == this_task_id & iteration == 1], aes(x = opt.x.cost, y = opt.x.gamma, size = classif.acc, color = classif.acc))
  g = g + geom_point()
  g = g + facet_grid(task_id~tuner)
  g = g + scale_radius() + scale_colour_viridis_c() + scale_y_log10() + scale_x_log10()
  g = g + labs(color = "ACC", size = "ACC", x = "cost", y = "gamma")
  g + theme_bw()
})
if (length(DATASET) > 1) {
  g = marrangeGrob(gs, ncol = 2, top = "Tuning cost and gamma for SVM (kernel = radial)")  
} else {
  g = gs[[1]]
}

if (interactive()) {
  print(g)
}
ggsave("../images/benchmark_scatter.png", g, height = 5, width = 7)
