library(microbenchmark)
library(quantreg)
library(ggplot2)
set.seed(123123)
#d <- OpenML::getOMLDataSet(data.id = 44042)
d <- OpenML::getOMLDataSet(data.id = 42369)
df <- as.data.frame(d)
str(df)
formula_df <- formula(Mean_temperature ~ Max_temperature + Min_temperature +
                        Visibility + Wind_speed + Max_wind_speed)

# contains 10 % of datapoints
df_10 <- df[sample(nrow(df), round(nrow(df)*0.1,0)),]
# contains 50 % of datapoints
df_50 <- df[sample(nrow(df), round(nrow(df)*0.5,0)),]
# contains 100 % of datapoints
df_100 <- df

mbm<- microbenchmark("L1_10" = {rq(formula_df, tau=0.5, method="br", data = df_10)},
                         "L2_10" = {lm(formula_df, data = df_10)},
                          "L1_50" = {rq(formula_df, tau=0.5, method="br", data = df_50)},
                         "L2_50" = {lm(formula_df, data = df_50)},
                         "L1_100" = {rq(formula_df, tau=0.5, method="br", data = df_100)},
                         "L2_100" = {lm(formula_df, data = df_100)
                           },
                         times = 50)

# fit two final models for parameter values
fin_mod_l1 <- rq(formula_df, tau=0.5, method="br", data = df_100)
fin_mod_l2 <- lm(formula_df, data = df_100)
# stargazer::stargazer(fin_mod_l1, fin_mod_l2)

# Create Dataset for custom boxplot
df_mbm <- as.data.frame(cbind(mbm$expr, mbm$time))
colnames(df_mbm) <- c("loss_dataset", "time")
df_mbm$loss <- ifelse(df_mbm$loss_dataset %in% c(1,3,5), "L1", "L2" )
df_mbm$loss_dataset <- as.factor(df_mbm$loss_dataset)

plt_loss <- ggplot(df_mbm, aes(x=loss_dataset, y=log(time), fill=loss)) +
  theme_bw() +
  stat_boxplot(geom = "errorbar", width = 0.5) +
  geom_boxplot(linewidth = 0.2, col = "darkgray") + 
  labs(x ="Proportion of dataset", y = "Log. time in ms") +
  scale_x_discrete(labels=c("10%","10%", "50%", "50%", "100%", "100%")) +
  theme(legend.position="bottom") +
  scale_fill_manual("Loss", values = c("blue", "darkorange"))
# plt_loss
ggsave("../figure/reg_l1_benchmark.pdf", plt_loss, width = 4, height = 5)
# boxplot(mbm, unit = "t", log = TRUE, xlab = "Loss-Dataset-Combination", ylab = "Time in ms", horizontal = FALSE)