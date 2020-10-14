# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)

# FUNCTIONS --------------------------------------------------------------------

.h = function(x) 0.6 + 0.4 * sin(2 * pi * x)
h = function(x) {
  
  .h(x) + .1 * arima.sim(list(ar = .7, ma = 0), length(x)) + 
    rnorm(length(x), sd = .5)
  
}

baseplot = function(lines = TRUE, from = 1, to, legend = FALSE) {
  
  # par(mar = c(2, 2, 1, 1))
  plot(x, y, pch = 19L, ylim = c(-1, 2))
  
  
  if(lines) {
    
    for (i in from:to) {
      
      lines(x.plot, 
            predict(mods[[i]], newdata = data.frame(x = x.plot)),
            col = line.palette[i], 
            lwd = 2L)
      
    }
    
  }
  
  if(legend) {
    
    legend("topright", 
           paste(sprintf("f(x) for d = %s", c(1, 5, 25)), 
                 c("(linear)", "", "")),
           col = line.palette, 
           lwd = 2L)
    
  }
  
}

# DATA -------------------------------------------------------------------------

set.seed(123)

x = seq(0.4, 2, length = 31L)
y = h(x)

p1 = lm(y ~ poly(x, 1, raw = TRUE))
p3 = lm(y ~ poly(x, 5, raw = TRUE))
p10 = lm(y ~ poly(x, 25, raw = TRUE))
mods = list(p1, p3, p10)

x.plot = seq(min(x), max(x), length = 500L)

line.palette = viridisLite::viridis(4)

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/reg_pol_1.pdf", width = 8, height = 4.5)

baseplot(lines = FALSE)

ggsave("../figure/reg_pol_1.pdf", width = 8, height = 4.5)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/reg_pol_2.pdf", width= 8, height = 4.5)

baseplot(to = 1, legend = TRUE)

ggsave("../figure/reg_pol_2.pdf", width = 8, height = 4.5)
dev.off()

# PLOT 3 -----------------------------------------------------------------------

pdf("../figure/reg_pol_3.pdf", width= 8, height = 4.5)

baseplot(to = 2, legend = TRUE)

ggsave("../figure/reg_pol_3.pdf", width = 8, height = 4.5)
dev.off()

# PLOT 4 -----------------------------------------------------------------------

pdf("../figure/reg_pol_4.pdf", width= 8, height = 4.5)

baseplot(to = 3, legend = TRUE)

ggsave("../figure/reg_pol_4.pdf", width = 8, height = 4.5)
dev.off()

# PLOT 5 -----------------------------------------------------------------------

pdf("../figure/reg_pol_5.pdf", width= 8, height = 6.5)

layout((1:2))

baseplot(from = 2, to = 3)
title(main = "Training Data")

plot(x.plot,
     .h(x.plot) + .3 * rnorm(length(x.plot)),
     pch = 19, 
     col = rgb(0, 0, 0, .5),
     cex = .8,
     xlab = "x",
     ylab = "y",
     ylim = c(-1, 2))

title(main = "Test Data")

for (i in 2:3) {
  
  lines(x.plot, 
        predict(mods[[i]], newdata = data.frame(x = x.plot)),
        col = line.palette[i], 
        lwd = 2L)
  
}

ggsave("../figure/reg_pol_5.pdf", width = 8, height = 6.5)
dev.off()