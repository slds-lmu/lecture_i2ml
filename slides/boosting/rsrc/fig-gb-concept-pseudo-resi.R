################################################################################
############## Gradient Boosting Pseudo Residuals ##############################
################################################################################
# Load data --------------------------------------------------------------------
source("boosting-example-datapoints.R")


# former: figure_man/pseudo-resi01.png

source("pseudo_boosting.R")
coefs = pseudo_boosting(y, 3)
p1 = plot_pseudo_boosting_step(coefs, c(1,2))

ggsave("../figure/fig-gb-concept-pseudo-resi-1.png", p1)


#-------------------------------------------------------------------------------
# former: figure_man/pseudo-resi02.png

coefs = pseudo_boosting(y, 3)
p2 = plot_pseudo_boosting_step(coefs, c(2,3))
ggsave("../figure/fig-gb-concept-pseudo-resi-2.png", p2)
