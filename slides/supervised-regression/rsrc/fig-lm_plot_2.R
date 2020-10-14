# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)

# DATA -------------------------------------------------------------------------

set.seed(3)

x = 1:5
y = 0.2 * x + rnorm(length(x), sd = 2)
d = data.frame(x = x, y = y)
m = lm(y ~ x)

# PLOT -------------------------------------------------------------------------

pdf("../figure/reg_lm_plot_2.pdf", width = 7.5, height = 3)

pl = ggplot(aes(x = x, y = y), data = d)

pl = pl + geom_abline(intercept = m$coefficients[1], slope = m$coefficients[2])

pl = pl + geom_rect(aes(ymin = y[3], 
                        ymax = y[3] + (m$fit[3] - y[3]), 
                        xmin = 3, 
                        xmax = 3 + abs(y[3] - m$fit[3])), 
                    color = "black", 
                    linetype = "dotted", 
                    fill = "transparent")

pl = pl + geom_rect(aes(ymin = y[4], 
                        ymax = y[4] + (m$fit[4] - y[4]), 
                        xmin = 4, 
                        xmax = 4 + abs(y[4] - m$fit[4])), 
                    color = "black", 
                    linetype = "dotted", 
                    fill = "transparent")

pl = pl + geom_segment(aes(x = 3, y = y[3], xend = 3, yend = m$fit[3]), 
                       color = "white")

pl = pl + geom_segment(aes(x = 4, y = y[4], xend = 4, yend = m$fit[4]), 
                       color = "white")

pl = pl + geom_segment(aes(x = 3, y = y[3], xend = 3, yend = m$fit[3]), 
                       linetype = "dotted", color = "red")

pl = pl + geom_segment(aes(x = 4, y = y[4], xend = 4, yend = m$fit[4]), 
                       linetype = "dotted", color = "red")

pl = pl + geom_point()
pl = pl + coord_fixed()

print(pl)

ggsave("../figure/reg_lm_plot_2.pdf", width = 7.5, height = 3)
dev.off()
