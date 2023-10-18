library(mlbench)
library(kernlab)
library(knitr)
library(ggplot2)
library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(gridExtra)
library(patchwork)
library(GGally)
data <- happy

colnames(data)
data_filtered <- data[, c("happy", "health")]
data_filtered <- na.omit(data_filtered)


# marginal distribution classes - not too happy highlighted
prob_not_too_happy <- table(data_filtered$happy)[1]/nrow(data_filtered)

barplot_1 <- ggplot(data_filtered, 
       aes(x = happy, 
           y = ..count.. / sum(..count..), fill=factor(ifelse(happy=="not too happy","Highlighted","Normal")))) + 
  geom_bar(show.legend = FALSE) +
  scale_fill_manual(name = "happy", values=c("lightgreen","grey")) +
  ggtitle("Distribution of classes in the entire data set") +
  labs(x = "Happiness Level", 
       y = "Percent") +
  scale_y_continuous(labels = scales::percent) +
  theme(axis.text=element_text(size=22),title=element_text(size = 19), axis.title=element_text(size=30),
        legend.key.size = unit(1.5, 'cm'), legend.title = element_text(size=12),
        legend.text = element_text(size=30), legend.title.align=0.3) +
  annotate("text", x = 1, y = 0.15, size = 11, label = sprintf(paste0("12.55 %%")))

ggsave("figure/nutshell-classification-distribution-class-data.png", plot = barplot_1, width = 8, height = 8)

# marginal distribution classes - not highlighted
barplot_2 <- ggplot(data_filtered, 
                    aes(x = happy, 
                        y = ..count.. / sum(..count..))) + 
  geom_bar(show.legend = FALSE, color = "lightgreen", fill = "grey") +
  #scale_fill_manual(name = "happy", values=c("lightgreen","grey")) +
  ggtitle("Distribution of classes in the entire data set") +
  labs(x = "Happiness Level", 
       y = "Percent") +
  scale_y_continuous(labels = scales::percent) +
  theme(axis.text=element_text(size=22),title=element_text(size = 19), axis.title=element_text(size=30),
        legend.key.size = unit(1.5, 'cm'), legend.title = element_text(size=12),
        legend.text = element_text(size=30), legend.title.align=0.3)

ggsave("figure/nutshell-classification-dsitribution-class-data-not-highlighted.png", plot = barplot_2, width = 8, height = 8)


# marginal distribution health - fair highlighted
prob_fair <- table(data_filtered$health)[2]/nrow(data_filtered)
barplot_3 <- ggplot(data_filtered, 
                    aes(x = health, 
                        y = ..count.. / sum(..count..), fill=factor(ifelse(health=="fair","Highlighted","Normal")))) + 
  geom_bar(show.legend = FALSE) +
  scale_fill_manual(name = "health", values=c("lightgreen","grey")) +
  ggtitle("Distribution of health in the entire data set") +
  labs(x = "Health Level", 
       y = "Percent") +
  scale_y_continuous(labels = scales::percent) +
  theme(axis.text=element_text(size=22),title=element_text(size = 19), axis.title=element_text(size=30),
        legend.key.size = unit(1.5, 'cm'), legend.title = element_text(size=12),
        legend.text = element_text(size=30), legend.title.align=0.3) +
  annotate("text", x = 2, y = 0.2, size = 11, label = sprintf(paste0("18.60 %%")))

ggsave("figure/nutshell-classification-dsitribution-health-data.png", plot = barplot_3, width = 8, height = 8)


# marginal distribution health - not highlighted
barplot_4 <- ggplot(data_filtered, 
                    aes(x = health, 
                        y = ..count.. / sum(..count..))) + 
  geom_bar(show.legend = FALSE, color = "lightgreen", fill = "grey") +
  #scale_fill_manual(name = "happy", values=c("lightgreen","grey")) +
  ggtitle("Distribution of health in the entire data set") +
  labs(x = "Health Level", 
       y = "Percent") +
  scale_y_continuous(labels = scales::percent) +
  theme(axis.text=element_text(size=22),title=element_text(size = 19), axis.title=element_text(size=30),
        legend.key.size = unit(1.5, 'cm'), legend.title = element_text(size=12),
        legend.text = element_text(size=30), legend.title.align=0.3)

ggsave("figure/nutshell-classification-dsitribution-health-dat-not-highlighted.png", plot = barplot_4, width = 8, height = 8)


# conditional distribution health - fair highlighted
data_filtered_not <- data_filtered[data_filtered[, 1] == "not too happy", ]

prob_fair <- table(data_filtered_not$health)[2]/nrow(data_filtered_not)
barplot_5 <- ggplot(data_filtered_not, 
                    aes(x = health, 
                        y = ..count.. / sum(..count..), fill=factor(ifelse(health=="fair","Highlighted","Normal")))) + 
  geom_bar(show.legend = FALSE) +
  scale_fill_manual(name = "health", values=c("lightgreen","grey")) +
  ggtitle("Distribution of health for class 'not too happy'") +
  labs(x = "Health Level", 
       y = "Percent") +
  scale_y_continuous(labels = scales::percent) +
  theme(axis.text=element_text(size=22),title=element_text(size = 19), axis.title=element_text(size=30),
        legend.key.size = unit(1.5, 'cm'), legend.title = element_text(size=12),
        legend.text = element_text(size=30), legend.title.align=0.3) +
  annotate("text", x = 2, y = 0.33, size = 11, label = sprintf(paste0("31.20 %%")))

ggsave("figure/nutshell-classification-distribution-of-health-not-too-good.png", plot = barplot_5, width = 8, height = 8)


# marginal distribution health - not highlighted
barplot_6 <- ggplot(data_filtered_not, 
                    aes(x = health, 
                        y = ..count.. / sum(..count..))) + 
  geom_bar(show.legend = FALSE, color = "lightgreen", fill = "grey") +
  #scale_fill_manual(name = "happy", values=c("lightgreen","grey")) +
  ggtitle("Distribution of health for class 'not too happy'") +
  labs(x = "Health Level", 
       y = "Percent") +
  scale_y_continuous(labels = scales::percent) +
  theme(axis.text=element_text(size=22),title=element_text(size = 19), axis.title=element_text(size=30),
        legend.key.size = unit(1.5, 'cm'), legend.title = element_text(size=12),
        legend.text = element_text(size=30), legend.title.align=0.3)

ggsave("figure/nutshell-classification-distribution-of-health-not-too-happy-not-highlightes.png", plot = barplot_6, width = 8, height = 8)
