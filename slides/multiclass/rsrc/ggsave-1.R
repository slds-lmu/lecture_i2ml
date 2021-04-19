data(iris)
# only select petal variable
iris_sub = iris[c("Petal.Length", "Petal.Width", "Species")]

scatter =   ggplot(data=iris_sub, aes(x = Petal.Length, y = Petal.Width)) + geom_point(aes(colour = Species)) + xlab("Petal Width") +  ylab("Petal Length") + theme(legend.position="bottom", legend.direction="horizontal") + xlim(0,7.5) + ylim(0,3)
scatter

############################################################################

library(mlr)
set.seed(123)
species = iris$Species
species = data.frame(Species = sample(species)[10:15])

c = cbind(original = species, createDummyFeatures(species))
c %>% knitr::kable(format = 'latex') %>%
  kableExtra::kable_styling(latex_options = 'HOLD_position')



############################################################################
