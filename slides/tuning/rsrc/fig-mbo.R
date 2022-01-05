library(patchwork)
library(ggplot2)

ret = BBmisc::load2("tune_mbo.RData")
grid_data = ret$grid
random_data = ret$rand
mbo_data = ret$mbo

create_cum_perf_plot = function(data_list){
  best_acc = sapply(1:length(data_list), function(idx) cummax(data_list[[idx]]$classif.acc))
  best_acc_mean = rowMeans(best_acc)
  best_acc_std  = apply(best_acc, 1, sd)
  
  best_acc_mean - best_acc_std
  
  plot_df = data.frame(
    best_acc = best_acc_mean,
    best_acc_lower = best_acc_mean - best_acc_std,
    best_acc_upper = best_acc_mean + best_acc_std,
    it = 1:length(best_acc_mean))
  
  plot_df
  
  ggplot(plot_df, aes(x=it, y=best_acc)) + 
    geom_line() + 
    geom_ribbon(aes(x=it, ymin = best_acc_lower, ymax = best_acc_upper), fill = "blue", alpha=0.5) +
    ylim(c(0.75, 0.82)) +
    ylab("best accuracy") + 
    xlab("iteration")
}

mbo_perf_cummax = create_cum_perf_plot(ret$mbos)
rand_perf_cummax = create_cum_perf_plot(ret$rands)

bg_plot = ggplot(grid_data[, 1:3], aes(x=cp, y=minsplit))  +
  geom_raster(aes(fill=classif.acc), interpolate = TRUE) 

rand_perf_feature_space = bg_plot + geom_point(data=random_data, aes(x=cp, y=minsplit),
                                               colour = "white", alpha = 0.5) +
  labs(fill = "accuracy", title = "Random search") 

mbo_perf_feature_space = bg_plot + geom_point(data=mbo_data, aes(x=cp, y=minsplit, alpha=classif.acc),
                                              colour="white", alpha=0.5) + 
  theme(legend.position="none") +
  labs(title="Bayesian Optimization")

mbo_perf_feature_space +  rand_perf_feature_space + mbo_perf_cummax + rand_perf_cummax 

ggsave("../figure/mbo_random_tune.pdf", width = 8, height = 5)
dev.off()
