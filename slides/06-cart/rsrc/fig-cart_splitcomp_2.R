# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(tidyverse)
library(gridExtra)

# DATA -------------------------------------------------------------------------

set.seed(600000)

data_1 = data.frame(category = sample(c("A", "B", "C", "D"), 
                                      size = 150,
                                      replace = TRUE, 
                                      prob = c(0.2, 0.1, 0.4, 0.3)),
                    y = sample(c(0, 1),
                               size = 150,
                               replace = TRUE,
                               prob = c(0.3, 0.7)))

data_2 = rbind(data.frame(category = "A", y = runif(30, 5, 7.5)),
               data.frame(category = "B", y = runif(15, 6, 12)),
               data.frame(category = "C", y = runif(60, 5, 20)),
               data.frame(category = "D", y = runif(45, 1, 6)))

plot.data_1 = data_1 %>% 
  filter(y == 1) %>%
  dplyr::select(category) %>% 
  table() %>% 
  prop.table() %>% 
  data.frame() %>% 
  rename(Category = 1, Frequency = 2)

plot.data_2 = data_2 %>% 
  group_by(category) %>% 
  mutate(Mean = mean(y)) %>% 
  dplyr::select(Category = category, Mean) %>% 
  unique() %>% 
  data.frame()

# FUNCTIONS --------------------------------------------------------------------

my_barplot = function(data, plot.data, ylab, vlevel) {
  
  p1 = ggplot(data = plot.data,
              aes(x = Category, y = plot.data[, 2], fill = Category)) +
    geom_bar(stat = "identity") + 
    scale_fill_viridis_d(end = .9) +
    theme(legend.position = "none") +
    ggtitle("1)") + 
    xlab("Category of feature") +
    ylab(ylab)
  
  p2.pre = ggplot(data = plot.data, 
                  aes(x = reorder(Category, plot.data[, 2]), 
                      y = plot.data[, 2], 
                      fill = Category)) +
    geom_bar(stat = "identity") + 
    scale_fill_viridis_d(end = .9) +
    theme(legend.position = "none") +
    xlab("Category of feature") +
    ylab(ylab)
  
  p2 = p2.pre + 
    ggtitle("2)")
  
  mod = rpart::rpart(y ~ ., data = data)
  lvls = levels(reorder(plot.data$Category, plot.data[, 2]))
  vline.level = vlevel
  
  p3 = p2.pre +  
    geom_vline(xintercept = which(lvls == vline.level) - 0.5, 
               col = 'red', 
               lwd = 1, 
               linetype = "dashed") +
    ggtitle("3)")
  
  grid.arrange(p1, p2, p3, ncol = 3)
  
}

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/cart_splitcomp_3.pdf", width = 8, height = 3.4)

my_barplot(data_1, plot.data_1, "Frequency of class 1", "C")

ggsave("../figure/cart_splitcomp_3.pdf", width = 8, height = 3.4)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/cart_splitcomp_4.pdf", width = 8, height = 3.5)

my_barplot(data_2, plot.data_2, "Mean of outcome", "B")

ggsave("../figure/cart_splitcomp_4.pdf", width = 8, height = 3.5)
dev.off()



