# PREREQ -----------------------------------------------------------------------

library(knitr)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

source("draw-cart-iris.R")

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/cart_intro_1.pdf", width = 8, height = 2.2)

model = draw_cart_on_iris(depth = 2)

ggsave("../figure/cart_intro_1.pdf", width = 8, height = 2.2)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/cart_intro_2.pdf", width = 8, height = 4)

model = draw_cart_on_iris(depth = 2)

ggsave("../figure/cart_intro_2.pdf", width = 8, height = 4)
dev.off()

# PLOT 3 -----------------------------------------------------------------------

pdf("../figure/cart_splitcriteria_1.pdf", width = 8, height = 4)

model = draw_cart_on_iris(depth = 2)

ggsave("../figure/cart_splitcriteria_1.pdf", width = 8, height = 4)
dev.off()
