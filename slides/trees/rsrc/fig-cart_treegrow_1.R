# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(qpdf)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

source("draw-cart-iris.R")

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/cart_treegrow_1.pdf", width = 8, height = 2.2)

draw_cart_on_iris(depth = 1, with_tree_plot = TRUE)

ggsave("../figure/cart_treegrow_1.pdf", width = 8, height = 2.2)
dev.off()

pdf_file = file.path("../figure/cart_treegrow_12.pdf")
pdf_subset('../figure/cart_treegrow_1.pdf', pages = 2:2, output = pdf_file)

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/cart_treegrow_2.pdf", width = 8, height = 2.2)

draw_cart_on_iris(depth = 2, with_tree_plot = TRUE)

ggsave("../figure/cart_treegrow_2.pdf", width = 8, height = 2.2)
dev.off()

pdf_file = file.path("../figure/cart_treegrow_22.pdf")
pdf_subset('../figure/cart_treegrow_2.pdf', pages = 2:2, output = pdf_file)

# PLOT 3 -----------------------------------------------------------------------

pdf("../figure/cart_treegrow_3.pdf", width = 8, height = 2.2)

draw_cart_on_iris(depth = 3, with_tree_plot = TRUE)

ggsave("../figure/cart_treegrow_3.pdf", width = 8, height = 2.2)
dev.off()

pdf_file = file.path("../figure/cart_treegrow_32.pdf")
pdf_subset('../figure/cart_treegrow_3.pdf', pages = 2:2, output = pdf_file)

# PLOT 4 -----------------------------------------------------------------------

# Plot for ML model slides (different size)

pdf("../../ml-models/figure/cart-partition.pdf", width = 8, height = 3.5)

draw_cart_on_iris(depth = 3, with_tree_plot = TRUE)

ggsave("../../ml-models/figure/cart-partition.pdf", width = 8, height = 3.5)
dev.off()

pdf_file = file.path("../../ml-models/figure/cart-tree.pdf")
pdf_subset("../../ml-models/figure/cart-partition.pdf", pages = 2:2, 
           output = pdf_file)

