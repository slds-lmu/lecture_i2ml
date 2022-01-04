library(patchwork)
library(ggplot2)

ret = BBmisc::load2("tune_mbo.RData")
grid_data = ret$grid
random_data = ret$rand
mbo_data = ret$mbo

bg_plot = ggplot(grid_data[, 1:3], aes(x=cp, y=minsplit))  +
  geom_raster(aes(fill=classif.acc), interpolate = TRUE) 

rand_perf_feature_space = bg_plot + geom_point(data=random_data, aes(x=cp, y=minsplit),
                                               colour = "white", alpha = 0.5) +
  labs(fill = "accuracy", title = "Random search") 

mbo_perf_feature_space = bg_plot + geom_point(data=mbo_data, aes(x=cp, y=minsplit, alpha=classif.acc),
                                              colour="white", alpha=0.5) + 
  theme(legend.position="none") +
  labs(title="Bayesian Optimization")

mbo_perf_cummax = ggplot(data.frame(iteration = 1:nrow(mbo_data), 
                  cum_acc = cummax(mbo_data$classif.acc))) + 
  geom_line(aes(iteration, cum_acc)) + ylim(0.75, 0.82) +
  ylab("best accuracy")

rand_perf_cummax = ggplot(data.frame(iteration = 1:nrow(random_data), 
                  cum_acc = cummax(random_data$classif.acc))) + 
  geom_line(aes(iteration, cum_acc)) + ylim(0.75, 0.82) +
  ylab("best accuracy")

mbo_perf_feature_space +  rand_perf_feature_space + mbo_perf_cummax + rand_perf_cummax 

ggsave("../figure/mbo_random_tune.pdf", width = 8, height = 5)
dev.off()


sapply(X = 1:5, FUN = function(id) cummax(ret$mbos[[id]]$classif.acc))
rep(re)

