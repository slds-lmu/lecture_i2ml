# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

pal_2 = viridisLite::viridis(2, end = .9)

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/eval_mclass_1.pdf", width = 7, height = 2.5)

phat = seq(0, 1, by = 0.02)
d = rbind(
  data.frame(phat = phat, BS = (1 - phat)^2, true.label = "1"),
  data.frame(phat = phat, BS = (0 - phat)^2, true.label = "0")
)

pl = ggplot(data = d, aes(x = phat, y = BS, col = true.label))
pl = pl + geom_line() + xlab(expression(hat(pi)(x)))
pl = pl + scale_color_manual(values = rev(pal_2))
pl = pl + geom_vline(xintercept=0.5)
pl = pl + annotate(geom = "text", 
                   label = "right", 
                   x = 0.1, 
                   y = 0.1, 
                   col = pal_2[2])
pl = pl + annotate(geom = "text", 
                   label = "wrong", 
                   x = 0.1, 
                   y = 1.0, 
                   col = pal_2[1])
pl = pl + annotate(geom = "text", 
                   label = "wrong", 
                   x = 0.9, 
                   y = 1.0, 
                   col = pal_2[2])
pl = pl + annotate(geom = "text", 
                   label = "right", 
                   x = 0.9, 
                   y = 0.1, 
                   col = pal_2[1])
print(pl)

ggsave("../figure/eval_mclass_1.pdf", width = 7, height = 2.5)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/eval_mclass_2.pdf", width = 7, height = 2.5)

phat = seq(0.01, 0.99, by = 0.01)
d = rbind(
  data.frame(phat = phat, LL = -log(phat), true.label = "1"),
  data.frame(phat = phat, LL = -log(1 - phat), true.label = "0")
)

pl = ggplot(data = d, aes(x = phat, y = LL, col = true.label))
pl = pl + geom_line() + xlab(expression(hat(pi)(x)))
pl = pl + scale_color_manual(values = rev(pal_2))
pl = pl + geom_vline(xintercept=0.5)
pl = pl + annotate(geom = "text", 
                   label = "right", 
                   x = 0.1, 
                   y = 0.1, 
                   col = pal_2[2])
pl = pl + annotate(geom = "text", 
                   label = "wrong", 
                   x = 0.1, 
                   y = 2.0, 
                   col = pal_2[1])
pl = pl + annotate(geom = "text", 
                   label = "wrong", 
                   x = 0.9, 
                   y = 2.0,
                   col = pal_2[2])
pl = pl + annotate(geom = "text", 
                   label = "right", 
                   x = 0.9, 
                   y = 0.1, 
                   col = pal_2[1])
print(pl)

ggsave("../figure/eval_mclass_2.pdf", width = 7, height = 2.5)
dev.off()
