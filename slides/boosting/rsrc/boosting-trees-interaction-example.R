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

y = x1 - x2 + 5*cos(x2*5)*x1 + eps
dat = data.frame(x1, x2, y)
X = dat[, setdiff(colnames(dat), "y")]

# Fit gbm with interaction depth = 1 and create PDP plots
task = makeRegrTask(data = dat, target = "y")
learner = makeLearner("regr.gbm", par.vals = list(interaction.depth = 1))
mod = train(learner, task)
model = Predictor$new(mod, data = dat)
effect = FeatureEffect$new(model, method = "pdp+ice", grid.size = 20, feature = "x1")
p1 = effect$plot()
effect = FeatureEffect$new(model, method = "pdp+ice", grid.size = 20, feature = "x2")
p2 = effect$plot()
effect = FeatureEffect$new(model, method = "pdp", grid.size = 20, feature = c("x1","x2"))
p2d = effect$plot()

p = gridExtra::grid.arrange(p1,p2, p2d, layout_matrix = rbind(c(1,3),c(2,3)))
ggsave(file = "figure_man/boosting_interaction_example_gam.png", plot = p, width = 8, height = 5)

# 3D surface plot for ID = 1
newx <- seq(-1, 1, len=20)
newy <- seq(-1, 1, len=20)
newxy <- expand.grid(x1 = newx, x2 = newy)
z <- matrix(predict(mod, newdata = newxy)$data$response, 20, 20)
p3d = plot_ly(x = newx, y = newy, z = z) %>% add_surface() 
p3d %>% layout(scene = list(xaxis = list(title = "x1"), yaxis = list(title = "x2"), zaxis = list(title = "y")))
# (save png from plotly)



# Fit gbm with interaction depth = 2 and create PDP plots
learner = makeLearner("regr.gbm", par.vals = list(interaction.depth = 2))
mod = train(learner, task)
model = Predictor$new(mod, data = dat)
effect = FeatureEffect$new(model, method = "pdp+ice", grid.size = 20, feature = "x1")
p1 = effect$plot()
effect = FeatureEffect$new(model, method = "pdp+ice", grid.size = 20, feature = "x2")
p2 = effect$plot()
effect = FeatureEffect$new(model, method = "pdp", grid.size = 20, feature = c("x1","x2"))
p2d = effect$plot()

p = gridExtra::grid.arrange(p1,p2, p2d, layout_matrix = rbind(c(1,3),c(2,3)))
ggsave(file = "figure_man/boosting_interaction_example_ID2.png", plot = p, width = 8, height = 5)

# 3D surface for ID = 2
newx <- seq(-1, 1, len=20)
newy <- seq(-1, 1, len=20)
newxy <- expand.grid(x1 = newx, x2 = newy)
z <- matrix(predict(mod, newdata = newxy)$data$response, 20, 20)
p = plot_ly(x = newx, y = newy, z = z) %>% add_surface()
p %>% layout(scene = list(xaxis = list(title = "x1"), yaxis = list(title = "x2"), zaxis = list(title = "y")))
# (save png from plotly)


# create surface plot for target function
y_test = matrix((newxy[,1] - newxy[,2] + 5*cos(newxy[,2]*5)*newxy[,1]),20,20)
p = plot_ly(x = newx, y = newy, z = y_test) %>% add_surface()  %>% layout(scene = list(xaxis = list(title = "x1"), yaxis = list(title = "x2"), zaxis = list(title = "y")))
p
# (save png from plotly)
