
library(knitr)
library(mlbench)
library(mlr)
library(OpenML)

library(ggplot2)
library(viridis)
library(gridExtra)
library(ggrepel)
library(repr)

library(data.table)
library(BBmisc)


library(party)
library(kableExtra)
library(kknn)
library(e1071)

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))


plot_lp = function(...){
  plotLearnerPrediction(...) + scale_fill_viridis_d()
}
pal_2 <- viridisLite::viridis(2, end = .9)

set.seed(123)

# rsrc data from rsrc/learning_curve.R
load("learning_curve.RData")

pdf("../figure/eval_learn_curves_1.pdf", width = 5, height = 2)
opt = res.rpart
opt$mmce = opt$mmce - mean(opt$mmce) + 0.08

eline = 0.08
xlab_lc = "Number of training instances"

p = ggplot(data = opt, aes(x = percentage, y = mmce))
p1 = p + geom_line(aes(colour = measure)) +
  theme_minimal() +
  ylim(0, 0.15) +
  ylab(expression(widehat(GE))) +
  xlab(xlab_lc) +
  scale_color_discrete(name = NULL, labels = c("1" = expression(D[test]), 
                                               "2" = expression(D[train]))) 
print(p1)
ggsave("../figure/eval_learn_curves_1.pdf", width = 5, height = 2)
dev.off()


pdf("../figure/eval_learn_curves_2.pdf", width = 5, height = 3)
p_ideal = p1 + geom_hline((aes(yintercept = eline))) +
  geom_text(aes(0.1, eline - 0.003, label = "desired error", vjust = 1, hjust = 0)) +
  geom_errorbar(aes(ymin = mmce - sd, ymax = mmce + sd, colour = measure), width = 0.025) +
  geom_point(aes(colour = measure))

print(p_ideal)
ggsave("../figure/eval_learn_curves_2.pdf", width = 5, height = 3)
dev.off()



