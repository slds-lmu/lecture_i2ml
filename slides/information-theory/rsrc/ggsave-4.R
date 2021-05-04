
library(knitr)
library(mlr)
library(mlbench)
library(ggplot2)
library(magrittr) 
library(tidyr)
library(dplyr)
library(gridExtra)



x <- c(0,1,2)
P <- rep(1/3, 3)
Q <- dbinom(x, size = 2, prob = 0.3)

#make table
distributions <- as.data.frame(rbind(P, Q))
names(distributions) <- x
distributions <- cbind(distribution = c('Distribution p(x):\nUnif(0,2) ', 'Distribution q(x): \nBin(2, 0.3)'),distributions )

#adjust table for plot
distributions_plot <- distributions %>% gather(key = "x", value = "y", 2:4)

#bar plot for both distributions
plot <- ggplot(data = distributions_plot, aes (x = x, y = y, group = distribution)) + 
  geom_bar(position = "dodge", stat = "identity") +
  facet_wrap(~distribution) +
  ylab("") 

# adjust table like in wikipedia
names(distributions) <- c("x", x)
distributions$x <- c('Distribution p(x)', 'Distribution q(x)')
tbl <- tableGrob(distributions, rows = NULL, theme = ttheme_default())

#show table with plot
grid.arrange(plot, tbl, nrow = 2, heights = c(2, 0.5))

############################################################################