library(scales)
library(gridExtra)
library(ggplot2)
library(viridis)

tuning_importance_dataset <- readRDS("tuning_importance.rds")

tree_res_p <- ggplot(data = tuning_importance_dataset$tree_res_df, mapping = aes(x=maxdepth, y=auc)) +
  geom_line(color="red") +
  labs(y="Test AUC") +
  theme_minimal() +
  ggtitle("Decision Tree")

knn_res_p <- ggplot(data=tuning_importance_dataset$knn_res_df, mapping = aes(x=k, y=auc)) +
  geom_line(color="red") +
  labs(y="Test AUC") +
  theme_minimal() +
  ggtitle("k-Nearest Neighbors")

svm_res_p <- ggplot(data=tuning_importance_dataset$svm_res_df, mapping = aes(x=gamma, y=C, fill=auc)) +
  geom_tile() +
  scale_fill_viridis(end=0.9) +
  scale_y_continuous(trans=log2_trans(),
                     breaks=trans_breaks("log2", function(x) 2^x),
                     labels=trans_format("log2", math_format(2^.x))) +
  scale_x_continuous(trans=log2_trans(),
                     breaks=trans_breaks("log2", function(x) 2^x),
                     labels=trans_format("log2", math_format(2^.x))) +
  theme_minimal() +
  labs(fill="Test AUC") +
  ggtitle("SVM")

p <- grid.arrange(tree_res_p, knn_res_p, svm_res_p, nrow = 1, ncol = 3)
p

ggsave(plot = p, filename = "../figure/tuning_importance.png", width = 15, height = 5)