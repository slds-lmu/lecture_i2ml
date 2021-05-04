
library(mlr)
library(BBmisc)



source("rsrc/plot_loss_functions.R")
plot_losses(c("01", "hinge"))

######################################################


library(gridExtra)
source("rsrc/plot_loss_functions.R")
plot_losses(c("01", "hinge", "sqhinge", "huber", "log"))