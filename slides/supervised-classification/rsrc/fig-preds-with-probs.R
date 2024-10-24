# here we want to plot how some datapoints are predicted (x -> pi(x))
# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

plot_width <- 20
plot_height <- 10
plot_dpi <- 300
line_size <- 5
base_size <- 40
point_size <- 10


# DATA -------------------------------------------------------------------------

set.seed(1234)

n = 20
x = runif(n, min = 0, max = 7)
y = x + rnorm(n) > 3.5
df = data.frame(x = x, y = y)

model = glm(y ~ x, family = binomial(link = "logit"), data = df)

df$score = predict(model)
df$prob = predict(model, type = "response")
df$y = as.factor(as.numeric(df$y))
x = seq(0, 7, by = 0.01)

dfn = data.frame(x = x)
dfn$prob = predict(model, newdata = dfn, type = "response")
dfn$score = predict(model, newdata = dfn)

# PLOT -------------------------------------------------------------------------

p = ggplot() + 
  geom_line(data = dfn, aes(x = x, y = prob), size = line_size) +
  geom_point(data = df, aes(x = x, y = prob, colour = y), size = point_size) +
  xlab("x") + ylab(expression(pi(x))) +
  scale_color_manual(values = c("#0072B2", "#E69F00")) +
  theme_minimal(base_size = base_size)

p

ggsave("../figure/preds_with_probs.png", plot = p, width = plot_width, height = plot_height, dpi = plot_dpi)
