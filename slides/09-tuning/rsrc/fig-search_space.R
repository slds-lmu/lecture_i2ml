set.seed(1)
library(mlr3)
library(mlr3tuning)
library(mlrintermbo)
library(ggplot2)

data("titanic", package = "mlr3data")
task = tsk("pima")
task = as_task_classif(titanic, target = "survived", positive = "yes")
all_train = as.data.frame(task$data())

train <- all_train[, -c(
which(colnames(all_train) == "cabin"),
which(colnames(all_train) == "name"),
which(colnames(all_train) == "ticket")
)]
str(train)

task <- TaskClassif$new(
  id = "titanic_train", backend = na.omit(train),
  target = "survived"
)
# check

cp_max = 0.05
cp_min = 1e-04
ms_max = 100
ms_min = 1
cp_mid = mean(c(cp_max, cp_min))
ms_mid = mean(c(ms_max, ms_min))
num_steps = 3

cp_step = (cp_max - cp_min)/num_steps
ms_step = (ms_max - ms_min)/num_steps


results = list()
for( step in 1:num_steps){

learner = lrn("classif.rpart", cp = to_tune(lower = cp_max - step*cp_step, 
                                            upper = cp_max, logscale = FALSE),
              minsplit = to_tune(round(max(1,ms_max - step*ms_step)), ms_max))


set.seed(step)
instance = tune(
  method = "random_search",
  task = task,
  learner = learner,
  resampling = rsmp("cv", folds = 10),
  measure = msr("classif.acc"),
  term_evals = 20
)

results[[step]] = instance$result
}


library(patchwork)

ret = BBmisc::load2("tune_mbo.RData")
grid_data = ret$grid

search_spaces = NULL
max_data = NULL

for (step in 1:num_steps){
  search_space = data.frame(x_min = cp_max - step*cp_step, x_max = cp_max,
                            y_min = ms_max - step*ms_step, y_max = ms_max)
  if(is.null(search_spaces)){
   search_spaces = search_space
  }else{
    search_spaces = rbind(search_spaces, search_space)
  }
  
  rect_sel = grid_data$cp > cp_max - step * cp_step &
  grid_data$minsplit > ms_max - step * ms_step
  val_data = grid_data[rect_sel,]
  max_id = which.max(val_data$classif.acc)
  max_row = val_data[max_id,]
  max_row$step = step
  
  if(is.null(max_data)){
    max_data = max_row
  }else{
    max_data = rbind(max_data, max_row)
  }
}

results_data = do.call(rbind, results)
results_data = results_data[, c("cp", "minsplit", "classif.acc")]
results_data$type = "hat theta*"
results_data$step = 1:num_steps
max_data = max_data[, c("cp", "minsplit", "classif.acc", "step")] 
max_data$type = "theta*"

cmp_data = rbind(max_data, results_data)

bg_plot = ggplot(grid_data[, 1:3], aes(x=cp, y=minsplit)) +
  geom_raster(aes(fill=classif.acc), interpolate = TRUE) + 
  geom_point(data = cmp_data, aes(x = cp, y=minsplit, shape=type), colour="red",
             size=3) +
  scale_shape("type", labels=list(expression(hat(lambda)~"*"), expression(lambda~"*"))) +
  labs(fill = "accuracy")

for(step in 1:num_steps){
bg_plot = bg_plot + annotate("rect", xmin = search_spaces$x_min[step],
                             xmax = search_spaces$x_max[step],
                             ymin = search_spaces$y_min[step],
                             ymax = search_spaces$y_max[step], fill=NA, colour = "white") 
}
bg_plot

unit_area = ms_step * cp_step
cmp_data$area = rep(sapply(1:num_steps, function(x) unit_area * x^2), 2)
cmp_plot = ggplot(cmp_data, aes(x=area, y=classif.acc, linetype=type)) + geom_line() +
  geom_point() + 
  scale_linetype("type", labels=list(expression(hat(lambda)~"*"), expression(lambda~"*"))) +
  ylab("accuracy")

bg_plot + cmp_plot
ggsave("../figure/search_space.pdf", width = 10, height = 4)
dev.off()
