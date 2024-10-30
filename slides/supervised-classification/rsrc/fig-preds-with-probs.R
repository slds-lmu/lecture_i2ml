# here we want to plot how some datapoints are predicted (x -> pi(x)),
# first by a naive linear models (to motivate the logistic regression)
# then by a logistic regression model

library(ggplot2)
library(knitr)

# common settings
set.seed(1234)
plot_width <- 20
plot_height <- 10
plot_dpi <- 300
line_size <- 5
base_size <- 40
point_size <- 13

# DATA -------------------------------------------------------------------------
# Generate data for logistic and linear models
n <- 20
x <- runif(n, min = 0, max = 7)
y <- x + rnorm(n) > 3.5
df <- data.frame(x = x, y = as.factor(as.numeric(y)))

x_seq <- seq(0, 7, by = 0.01)
dfn <- data.frame(x = x_seq)

# MODELS -----------------------------------------------------------------------
# Fit a linear model to showcase the issue
model_linear <- lm(as.numeric(y) - 1 ~ x, data = df)
df$prob_linear <- predict(model_linear)
dfn$prob_linear <- predict(model_linear, newdata = dfn)

# a logistic model that fixes this issue
model_logistic <- glm(y ~ x, family = binomial(link = "logit"), data = df)
df$prob_logistic <- predict(model_logistic, type = "response")
df$score_logistic <- predict(model_logistic)
dfn$prob_logistic <- predict(model_logistic, newdata = dfn, type = "response")
dfn$score_logistic <- predict(model_logistic, newdata = dfn)

# PLOTS -------------------------------------------------------------------------
# fitted linear model plot
p_linear <- ggplot(df, aes(x = x)) +
  geom_line(data = dfn, aes(y = prob_linear), color = "black", size = line_size) +
  geom_point(aes(y = prob_linear, color = y), size = point_size) +
  scale_color_manual(values = c("0" = "#E69F00", "1" = "#0072B2"), name = "y") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red", size = line_size - 2) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red", size = line_size - 2) +
  xlab("x") + ylab(expression(pi(x))) +
  theme_minimal(base_size = base_size) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 40),
    plot.margin = margin(20, 20, 20, 20)
  ) +
  annotate("text", x = 4, y = 1.1, label = "Probability > 1", color = "red", size = 16, fontface = "bold") +
  annotate("text", x = 3.5, y = -0.1, label = "Probability < 0", color = "red", size = 16, fontface = "bold")
p_linear

# logistic regression plot
p_logistic <- ggplot() + 
  geom_line(data = dfn, aes(x = x, y = prob_logistic), size = line_size, color = "black") +
  geom_point(data = df, aes(x = x, y = prob_logistic, colour = y), size = point_size) +
  xlab("x") + ylab(expression(pi(x))) +
  scale_color_manual(values = c("#0072B2", "#E69F00")) +
  theme_minimal(base_size = base_size)
p_logistic

# save the plots
ggsave("../figure/preds_with_probs-linear.png", plot = p_linear, width = plot_width, height = plot_height, dpi = plot_dpi)
ggsave("../figure/preds_with_probs-logistic.png", plot = p_logistic, width = plot_width, height = plot_height, dpi = plot_dpi)
