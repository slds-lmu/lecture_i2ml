library(ElemStatLearn)
library(gbm)
source("gbm_spam_defs.R")

data = spam
data$spam = as.numeric(data$spam) - 1
vars = read.table("gbm_spam_vars.txt", sep=":", comment.char="", stringsAsFactors=FALSE)[,1]
colnames(data)[1:57] = vars

load("gbm_spam_results.RData")

# make long data.frame from the old results
n.comb = length(shrinks) * length(inters) * length(pred.n.trees)
error.df = data.frame(shrinkage = numeric(n.comb), max.tree.depth = integer(n.comb),
  M = integer(n.comb), err = numeric(n.comb))
len.M = length(pred.n.trees)
i = 1L
for (k in shrinks) {
  print(paste("Shrinkage", k))
  for (j in inters) {
    print(paste("Depth", j))
    print(paste("Rows", 1+(i-1)*len.M, "to", i*len.M))
    error.df[(1+(i-1)*len.M):(i*len.M), 1:3] = cbind(rep(k, len.M), rep(j, len.M), pred.n.trees)
    i = i + 1L
  }
}
error.df[,4] = unlist(errs)
error.df$max.tree.depth = as.factor(error.df$max.tree.depth)

# p1 = ggplot(data = error.df[error.df$shrinkage == 0.001,], aes(x = M, y = err, col = max.tree.depth)) +
#   geom_line() + coord_cartesian(ylim = c(0, 0.25)) + theme(legend.position="none")
# p2 = ggplot(data = error.df[error.df$shrinkage == 0.01,], aes(x = M, y = err, col = max.tree.depth)) +
#   geom_line() + coord_cartesian(ylim = c(0, 0.25)) + theme(legend.position="none")
# p3 = ggplot(data = error.df[error.df$shrinkage == 0.1,], aes(x = M, y = err, col = max.tree.depth)) +
#   geom_line() + coord_cartesian(ylim = c(0, 0.25))
# grid.arrange(p1, p2, p3, nrow = 1, widths = c(0.3, 0.3, 0.4))

save(error.df, file = "gbm_spam_results_long.RData")

# show model with minimal error:
error.df[which.min(error.df$err), ]

####################################################################################################
mypdf = function(..., cex = 1) {
  pdf(...)
  par(lwd = 4, cex = cex, cex.axis = cex,
    cex.main = cex, cex.lab = cex)
}

mypdf(file="gbm_spam_effects.pdf", cex = 2)
doPlot2(grid, errs)
dev.off()

#model = getModel(data, n.trees = 1380, inter = 4, shrinkage = 0.1)
#saveRDS(model, file = "model_best_spam.rds")
library(dplyr)
varimp <- summary.gbm(model, cBars=12, las=2) %>% arrange(desc(rel.inf)) %>% 
  mutate(rel.inf = rel.inf / sum(rel.inf), var = ordered(var, rev(unique(var)), rev(unique(var))))
pdf(file="gbm_spam_imp_ggplot.pdf", height  = 5.8, width   = 8)
ggplot(varimp[1:12,]) + 
  geom_col(aes(y = rel.inf, x = var, fill = rel.inf), position = "dodge") +
  coord_flip() + theme(legend.position = "none") + scale_y_continuous("Relative influence") + 
  scale_x_discrete("")
dev.off()


mypdf(file="gbm_spam_gbmperf.pdf", cex = 1.5)
gbm.perf(model, method = "OOB")
dev.off()

mypdf(file="gbm_spam_partdep.pdf", cex = 1.8)
par(mfrow = c(1, 2))
plot.gbm(model, 52)
plot.gbm(model, 25)
par(mfrow = c(1, 1))
dev.off()
