
library(ggplot2)

load("rsrc/holdout-biasvar.RData")
ggd1 = reshape2::melt(res)
colnames(ggd1) = c("split", "rep", "ssiter", "mmce")
ggd1$split = as.factor(ggd1$split)
ggd1$mse = (ggd1$mmce -  realperf)^2
ggd1$type = "holdout"
ggd1$ssiter = NULL
mse1 = plyr::ddply(ggd1, "split", plyr::summarize, mse = mean(mse))
mse1$type = "holdout"

ggd2 = plyr::ddply(ggd1, c("split", "rep"), plyr::summarize, mmce = mean(mmce))
ggd2$mse = (ggd2$mmce -  realperf)^2
ggd2$type = "subsampling"
mse2 = plyr::ddply(ggd2, "split", plyr::summarize, mse = mean(mse))
mse2$type = "subsampling"

ggd = rbind(ggd1, ggd2)
gmse = rbind(mse1, mse2)
ggd$type = as.factor(ggd$type)
gmse$split = as.numeric(as.character(gmse$split))
gmse$type = as.factor(gmse$type)

pl1 = ggplot(ggd[ggd$type == "holdout", ], aes(x = split, y = mmce))
pl1 = pl1 + geom_boxplot()
pl1 = pl1 + geom_hline(yintercept = realperf)
pl1 = pl1 + theme(axis.text.x = element_text(angle = 45))
print(pl1)

ggsave("figure/test-holdout-example.pdf", width = 8, height = 3.5)  
