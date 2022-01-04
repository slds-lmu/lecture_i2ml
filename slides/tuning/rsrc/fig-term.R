set.seed(1)
library(mlr3)
library(mlr3tuning)
library(mlrintermbo)
library(ggplot2)

ret = BBmisc::load2("tune_mbo.RData")
random_data = ret$rand

rand_perf_cummax = ggplot(data.frame(iteration = 1:nrow(random_data), 
                  cum_acc = cummax(random_data$classif.acc))) + 
  geom_line(aes(iteration, cum_acc)) + ylim(0.75, 0.82) +
  ylab("cum max accuracy") + geom_vline(xintercept = 45, colour="grey", linetype=2) +
  geom_vline(xintercept = 10, colour="grey", linetype=2) + 
  geom_vline(xintercept = 32, colour="grey", linetype=2) +
  annotate("text", x = 10, y = 0.76, label="accuracy > 0.775") +
  annotate("text", x = 32, y = 0.76, label="no improvement since 30 iterations") +
  annotate("text", x = 45, y = 0.8, label="45 iterations reached") 

rand_perf_cummax
ggsave("../figure/term.pdf", width = 8, height = 5)
 dev.off()
