source("scripts/tree-viz.R")

#categorical
catfeat <- data.frame(Cat = as.factor(c("A", "B", "C", "D")), freq = c(6, 8, 12, 4))
catfeat$freq  <- catfeat$freq / sum(catfeat$freq)
catplot1 <- ggplot(catfeat, aes(Cat, freq)) + 
  geom_bar(stat = "identity", fill = 2:5) +
  xlab("Category of Feature") + ylab("Rel. Frequency") + theme_bw()
catplot2 <- ggplot(catfeat, aes(reorder(Cat, freq), freq)) + 
  geom_bar(stat = "identity", fill = 2:5) +
  xlab("Category of Feature") + ylab("Rel. Frequency") + theme_bw()
catplot3 <- ggplot(catfeat, aes(reorder(Cat, freq), freq))  + 
  geom_bar(stat = "identity", fill = 2:5) +
  xlab("Category of Feature") + ylab("Rel. Frequency") +
  annotate("rect", xmin = 2.5, xmax = 2.5, ymin = -Inf, ymax = Inf, 
           linetype = "dashed", col = "black") + theme_bw()

ggsave("slides/trees/figure/categoryplot-binary1.pdf", catplot1, 
       units = "cm",
       width = 6, height = 8)
ggsave("slides/trees/figure/categoryplot-binary2.pdf", catplot2, 
       units = "cm",
       width = 6, height = 8)
ggsave("slides/trees/figure/categoryplot-binarysmall.pdf", catplot2, 
       units = "cm",
       width = 5, height = 4)
ggsave("slides/trees/figure/categoryplot-binary3.pdf", catplot3, 
       units = "cm",
       width = 6, height = 8)


# numeric
catfeat <- data.frame(Cat = as.factor(c("A", "B", "C", "D")), freq = c(6.0, 8.0, 12.0, 4.0))
catplot1 <- ggplot(catfeat, aes(Cat, freq)) + 
  geom_bar(stat = "identity", fill = 2:5) +
  xlab("Category of Feature") + ylab("Mean of outcome") + theme_bw()
catplot2 <- ggplot(catfeat, aes(reorder(Cat, freq), freq)) + 
  geom_bar(stat = "identity", fill = 2:5) +
  xlab("Category of Feature") + ylab("Mean of outcome") + theme_bw()
catplot3 <- ggplot(catfeat, aes(reorder(Cat, freq), freq)) + 
  geom_bar(stat = "identity", fill = 2:5) +
  xlab("Category of Feature") + ylab("Mean of outcome") +
  annotate("rect", xmin = 2.5, xmax = 2.5, ymin = -Inf, ymax = Inf, 
           linetype = "dashed", col = "black") + theme_bw()

ggsave("slides/trees/figure/categoryplot-cont1.pdf", catplot1, 
       units = "cm",
       width = 6, height = 8)
ggsave("slides/trees/figure/categoryplot-cont2.pdf", catplot2, 
       units = "cm",
       width = 6, height = 8)
ggsave("slides/trees/figure/categoryplot-cont3.pdf", catplot3, 
       units = "cm",
       width = 6, height = 8)
