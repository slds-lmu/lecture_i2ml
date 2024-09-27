# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

set.seed(600000)

rho = seq(0, 1, by = 0.001)
B = c(5, 50)
sigma = 20

grid = expand.grid(rho = rho, B = B)

grid$var = grid$rho * sigma + (1 - grid$rho) / grid$B * sigma
grid = grid[order(grid$B), ]
grid$B = as.factor(grid$B)

horizontal = data.frame(
  B = as.factor(B),
  intercept = sigma / B,
  intercept.label = sigma / B + c(0, 0.7)
  )

# PLOT -------------------------------------------------------------------------

pdf("../figure/cart_forest_bag_1.pdf", width = 8, height = 2.5)

p1 = ggplot(data = grid, aes(x = rho, y = var)) +
  geom_line(aes(group = B, colour = B)) +
  geom_hline(aes(yintercept = 20), colour = "black", lty = 2) +
  geom_hline(data = horizontal, 
             aes(yintercept = intercept, colour = B), 
             lty = 2) +
  scale_color_viridis_d(end = .9) +
  xlab(expression(paste("Correlation of Trees ", rho))) +
  ylab("Variance") +
  labs(colour = "Number of Trees") +
  annotate("text", x = 1.1, y = sigma, label = "sigma^2", parse = TRUE) +
  geom_text(data = horizontal, 
            aes(x = rep(1.08, 2), 
                y = intercept.label, 
                color = B,          
                label = paste0("sigma^2 / ", B)), 
            parse = TRUE, 
            show.legend = FALSE, 
            hjust = 0) +
  coord_cartesian(xlim = c(0, 1), clip = "off") +
  ylim(c(0, 20)) + 
  theme_minimal()

p1

ggsave("../figure/cart_forest_bag_1.pdf", width = 8, height = 2.5)

dev.off()