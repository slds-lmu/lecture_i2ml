# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(gridExtra)
library(grid)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# HELPERS ----------------------------------------------------------------------

make_line_1 = function(x) 2 * x
make_line_2 = function(x) x + 1
make_line_3 = function(x) 3 - 0.5 * x

base <- ggplot(data.frame(x = c(-5, 5)), aes(x))
base + stat_function(fun = funny)

# PLOT -------------------------------------------------------------------------

pdf("../figure/ml-basics-hs-lin-functions.pdf", width = 8, height = 2.5)

p1 = ggplot(data.frame(x = c(0, 5)), aes(x))
p1 = p1 + stat_function(fun = make_line_1)

p2 = ggplot(data.frame(x = c(0, 5)), aes(x))
p2 = p2 + stat_function(fun = make_line_2)

p3 = ggplot(data.frame(x = c(0, 5)), aes(x))
p3 = p3 + stat_function(fun = make_line_3)

grid.arrange(p1, p2, p3, ncol = 3)

ggsave("../figure/ml-basics-hs-lin-functions.pdf", width = 8, height = 2.5)

dev.off()