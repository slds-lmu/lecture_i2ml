################################################################################
############## Gradient Boosting Idea ##############################
################################################################################
# Load data --------------------------------------------------------------------
source("boosting-example-datapoints.R")
source("boosting_idea.R")
################################################################################
# former: figure_man/gradient-boosting01.png 
# former: figure_man/gradient-boosting02.png
# former: figure_man/gradient-boosting03.png
coefs = boosting(x, y, nboost = 4, learning_rate = 0.4, basis_fun = bTrafo)

p3 = plot_splines_boosting_step(coefs, its=c(0,1))
p4 = plot_splines_boosting_step(coefs, its=c(1,2))
p5 = plot_splines_boosting_step(coefs, its=c(2,3))

ggsave("../figure/fig-gb-concept-idea.png", p3, height = 3.5, width = 5)
ggsave("../figure/fig-gb-concept-idea-1.png", p3, height = 3.5, width = 7)

ggsave("../figure/fig-gb-concept-idea-2.png", p4, height = 3.5, width = 7)
ggsave("../figure/fig-gb-concept-idea-3.png", p5, height = 3.5, width = 7)
