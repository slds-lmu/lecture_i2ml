# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)

# PLOT -------------------------------------------------------------------------

pdf("../figure/reg_lm_plot.pdf", width = 4.8, height = 3.1)

ggplot(data = data.frame(x = c(-0.5, 4)), aes(x = x)) +
  
  stat_function(fun = function (x) { 1 + 0.5 * x }) +
  
  geom_vline(xintercept = 0, 
             color = "gray", 
             linetype = "dashed") +
  
  geom_segment(mapping = aes(x = 2, y = 2, xend = 3, yend = 2), 
               linetype = "dashed") +
  
  geom_segment(mapping = aes(x = 3, y = 2, xend = 3, yend = 2.5), 
               linetype = "dashed", 
               color = "red") +
  
  geom_segment(mapping = aes(x = 0, y = 0, xend = 0, yend = 1), 
               linetype = "dashed", 
               color = "blue") +
  
  geom_text(mapping = aes(x = 2.5, y = 2, label = "1 Unit"), vjust = 2) +
  
  geom_text(mapping = aes(x = 3, y = 2.25, 
                          label = "{theta[1] == slope} == 0.5"), 
            hjust = -0.05, 
            parse = TRUE, 
            color = "red") +
  
  geom_text(mapping = aes(x = 0, y = 1, 
                          label = "{theta[0] == intercept} == 1"), 
            hjust = -0.1, 
            parse = TRUE, 
            color = "blue") +
  
  ylim(c(0, 3.5)) + 
  xlim(c(-0.5, 4.3))

ggsave("../figure/reg_lm_plot.pdf", width = 4.8, height = 3.1)
dev.off()