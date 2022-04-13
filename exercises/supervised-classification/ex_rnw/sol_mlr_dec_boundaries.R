# PREP -------------------------------------------------------------------------

library(ggplot2)
library(mlbench)
library(mlr3)
library(mlr3learners)
library(mlr3viz)

# ANALYSIS ---------------------------------------------------------------------

# simulate data
set.seed(123L)
data_raw <- mlbench::mlbench.cassini(n = 1000)
df <- as.data.frame(data_raw)
df$x.2 <- df$x.2 + rnorm(nrow(df), sd = 0.5)

# visualize
ggplot2::ggplot(df, aes(x = x.1, y = x.2, col = classes)) +
  geom_point()

# create task
task <- mlr3::TaskClassif$new(
  id = "spirals_task", 
  backend = df,
  target = "classes")

# define learners
learners <- list(
  mlr3::lrn("classif.lda"),
  mlr3::lrn("classif.qda"),
  mlr3::lrn("classif.naive_bayes"))

# train and plot decision boundaries
plots <- lapply(learners, function(i) mlr3viz::plot_learner_prediction(i, task))
for (i in plots) print(i)

# We see how LDA, with its confinement to linear decision boundaries, is not
# able to classify the data very well.
# QDA and NB, on the other hand, get the shape of the boundaries right.
# It also becomes obvious that NB is a quadratic classifier just like QDA - 
# their decision surfaces look pretty much alike.
