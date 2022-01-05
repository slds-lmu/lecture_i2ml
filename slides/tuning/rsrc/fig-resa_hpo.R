library(mlr3)
library(mlr3learners)
library(mlr3tuning)
library(mlbench)
library(paradox)
library(ggplot2)
library(viridis)
library(patchwork)

set.seed(13)

sd = 0.25

spiral <- as.data.frame(mlbench.spirals(n = 100, sd = sd))
plot(x = spiral$x.1,
     y = spiral$x.2,
     col = spiral$classes)

test_spiral <- as.data.frame(mlbench.spirals(n = 100000, sd = sd))

task <- TaskClassif$new(id = "spirals",
                        backend = spiral,
                        target = "classes")

#set.seed(1337) 3
#set.seed(1) 5
set.seed(2)
learner <- lrn("classif.rpart", predict_type = "prob")

res = NULL
res_dp = data.frame()

set.seed(12345)

for (folds in 2:7) {
  for (it in 1:5) {
    resampling <- rsmp("cv", folds = folds)
    measures <- msr("classif.ce")
    # make parameter set
    tune_ps <- ParamSet$new(list(
      ParamDbl$new("cp", lower = 0.001, upper = 0.1),
      ParamInt$new("minsplit", lower = 1, upper = 100)
    ))
    terminator <- trm("evals", n_evals = 25)

    tuner <- tnr("grid_search", resolution=5)
    at <- AutoTuner$new(
      learner = learner,
      resampling = resampling,
      measure = measures,
      search_space = tune_ps,
      terminator = terminator,
      tuner = tuner
    )
    
    at$train(task)
    
    pred = at$predict_newdata(test_spiral)
    new_row = data.frame(folds = folds, it = it, ge = pred$score(msr("classif.ce")))
    if (is.null(res)){
      res = new_row
    }else{
      res = rbind(res, new_row)
    }

    res_dp = rbind(res_dp, at$archive$data[, 1:3])
 
  }

}

res$folds = as.character(res$folds)

pred_cv2  = res_dp[ 1:25, ]
pred_true = pred_cv2

for (i in 1:nrow(pred_cv2)){
  learner <- lrn("classif.rpart", predict_type = "prob", cp=as.numeric(pred_cv2[i, "cp"]),
                 minsplit=as.numeric(pred_cv2[i,"minsplit"]))
  learner$train(task)
  pred = learner$predict_newdata(test_spiral)
  pred_true[i, 3] = as.numeric(pred$score())
}

p1 = ggplot(pred_cv2, aes(x=cp, y=minsplit)) +
  geom_point(aes(colour=classif.ce), size = 10) +
  scale_colour_viridis(end=0.9) +
  labs(title="CV-2", colour="MCE")

p2 = ggplot(pred_true, aes(x=cp, y=minsplit)) +
  geom_point(aes(colour=classif.ce), size = 10) +
  scale_colour_viridis(end=0.9) +
  labs(title="'true' performance", colour="MCE") 

p3 = ggplot(res, aes(x=folds, y=ge)) + geom_boxplot() + 
  ylab("GE") + xlab("number of folds")

p1 + p2 + p3
ggsave("../figure/resa_hpo.pdf")



