# PREREQ -----------------------------------------------------------------------

library(ggplot2)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

load("learning_curve.RData")

# DATA -------------------------------------------------------------------------

set.seed(123)

opt = res.rpart
opt$mce = opt$mce - mean(opt$mce) + 0.08

eline = 0.08
xlab_lc = "Number of training instances"

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/eval_learn_curves_1.pdf", width = 5, height = 2)

p = ggplot(data = opt, aes(x = percentage, y = mce))
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

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/eval_learn_curves_2.pdf", width = 5, height = 3)

p_ideal = p1 + geom_hline((aes(yintercept = eline))) +
  geom_text(aes(0.1, 
                eline - 0.003, 
                label = "desired error", 
                vjust = 1, 
                hjust = 0)) +
  geom_errorbar(aes(ymin = mce - sd,
                    ymax = mce + sd,
                    colour = measure), 
                width = 0.025) +
  geom_point(aes(colour = measure))
print(p_ideal)

ggsave("../figure/eval_learn_curves_2.pdf", width = 5, height = 3)
dev.off()

# PLOT 3 -----------------------------------------------------------------------

pdf("../figure/eval_learn_curves_3.pdf", width = 5, height = 2)

p = ggplot(data = res.rpart, aes(x = percentage, y = mce))
p + geom_hline((aes(yintercept = eline))) +
  geom_text(aes(0.1, 
                eline - 0.003, 
                label = "desired error", 
                vjust = 1, 
                hjust = 0)) +
  geom_errorbar(aes(ymin = mce - sd,
                    ymax = mce + sd,
                    colour = measure), 
                width = 0.025) +
  geom_line(aes(colour = measure)) +
  geom_point(aes(colour = measure)) +
  ylim(0, 0.2) +
  ylab(expression(widehat(GE))) +
  xlab(xlab_lc) +
  scale_color_discrete(name = NULL, labels = c("1" = expression(D[test]), 
                                               "2" = expression(D[train]))) +
  theme_minimal() 
print(p)

ggsave("../figure/eval_learn_curves_3.pdf", width = 5, height = 2)
dev.off()

# PLOT 4 -----------------------------------------------------------------------

pdf("../figure/eval_learn_curves_4.pdf", width = 5, height = 2)

p1 = ggplot(data = res.ranger, aes(x = percentage, y = mce))
p1 + geom_hline((aes(yintercept = eline))) +
  geom_text(aes(0.1, 
                eline - 0.003, 
                label = "desired error", 
                vjust = 1, 
                hjust = 0)) +
  geom_errorbar(aes(ymin = mce - sd,
                    ymax = mce + sd,
                    colour = measure), 
                width = 0.025) +
  geom_line(aes(colour = measure)) +
  geom_point(aes(colour = measure)) +
  ylim(0, 0.2) +
  ylab(expression(widehat(GE))) +
  xlab(xlab_lc) +
  scale_color_discrete(name = NULL, labels = c("1" = expression(D[test]), 
                                               "2" = expression(D[train]))) +
  theme_minimal()

print(p1)
ggsave("../figure/eval_learn_curves_4.pdf", width = 5, height = 2)
dev.off()