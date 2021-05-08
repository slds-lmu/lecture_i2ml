################################################################################
############# Experiment showing the realtion ship to MWU ######################
################################################################################
library(ggplot2)
library(viridis)
################################################################################
#Table from the slide
truth <- c(1,1,1,0,1,0,0) 
score <- c(0.9,0.76,0.7,0.5,0.45,0.3,0.1)
data <- data.frame(truth, score)

#Get indices of positive and negatives 
positives <- which(truth==1)
negatives <- which(truth==0)

# set seed
set.seed(120)

# count the number of times ranked right
right_ranked <- 0
number_of_draws <- 4000
draws <- data.frame(no_draws=c(), prob=c())

for (i in 1:number_of_draws){
  # draw obne of the positives and negatives
  positive <- sample(positives, size=1)
  negative <- sample(negatives, size=1)
  
  # add to right ranked, if positive ranked higher
  right_ranked <- right_ranked + (positive<negative)
  
  # add table
  draws <- rbind(draws, c(i, right_ranked/i))
}

################################################################################
colnames(draws) <- c("no_draws", "prob")
ggplot(draws, aes(no_draws,prob)) +
  geom_point(size = 1,  fill = "#6BAED6", color = "#6BAED6") +
  theme_gray() +
  scale_color_viridis() +
  xlab("Number of draws") +
  ylab("Share of draws where the positive obs. is ranked higher")
################################################################################
ggsave("../figure/fig-eval_mwu_ranking.png", width = 5, height = 5)