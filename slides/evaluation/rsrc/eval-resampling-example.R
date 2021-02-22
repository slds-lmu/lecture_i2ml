  # rsrc data from rsrc/holdout-biasvar.R
  load("rsrc/holdout-biasvar.RData")

  library(plyr)
  library(gridExtra)
  library(reshape2)
  library(viridis)
  
  ggd1 = melt(res)
  colnames(ggd1) = c("split", "rep", "ssiter", "mmce")
  ggd1$split = as.factor(ggd1$split)
  ggd1$mse = (ggd1$mmce -  realperf)^2
  ggd1$type = "holdout"
  ggd1$ssiter = NULL
  mse1 = ddply(ggd1, "split", summarize, mse = mean(mse))
  mse1$type = "holdout"
  
  ggd2 = ddply(ggd1, c("split", "rep"), summarize, mmce = mean(mmce))
  ggd2$mse = (ggd2$mmce -  realperf)^2
  ggd2$type = "subsampling"
  mse2 = ddply(ggd2, "split", summarize, mse = mean(mse))
  mse2$type = "subsampling"
  
  ggd = rbind(ggd1, ggd2)
  gmse = rbind(mse1, mse2)
  
  ggd$type = as.factor(ggd$type)
  pl1 = ggplot(ggd, aes(x = split, y = mmce, col = type))
  pl1 = pl1 + geom_boxplot()
  pl1 = pl1 + geom_hline(yintercept = realperf)
  pl1 = pl1 + theme(axis.text.x = element_text(angle = 45)) 
  pl1 = pl1 + scale_color_viridis(discrete=TRUE, end = 0.5)
  print(pl1)
  
  ggsave("figure/eval-resampling-example-1.pdf", width = 8, height = 3.5)
  
  gmse$split = as.numeric(as.character(gmse$split))
  gmse$type = as.factor(gmse$type)

####################################################################
####################################################################
####################################################################
  
  
  pl2 = ggplot(gmse, aes(x = split, y = mse, col = type))
  pl2 = pl2 + geom_line()
  pl2 = pl2 + scale_y_log10()
  pl2 = pl2 + scale_x_continuous(breaks = gmse$split)
  pl2 = pl2 + theme(axis.text.x = element_text(angle = 45))
  pl2 = pl2 + ylab("MSE of the mmce") 
  pl2 = pl2 + scale_color_viridis(discrete=TRUE, end = 0.5)
  print(pl2)
  ggsave("figure/eval-resampling-example-2.pdf", width = 5, height = 3.5)
  
    