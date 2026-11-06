library(viridis)
library(ggplot2)
library(gridExtra)
library(purrr)
library(glue)

theme_set(theme_bw())

eq_spacing <- function(n, r = 1, center = c(0, 0)){
  polypoints <- seq(0, 2*pi, length.out=n+1)
  polypoints <- polypoints[-length(polypoints)]
  circx <- r * sin(polypoints) + center[1]
  circy <- r * cos(polypoints) + center[2]
  data.frame(x=circx, y=circy)
}

mce_func <- function(fpr, tpr) {
  fnr <- 1 - tpr
  function(pi_p) (fnr - fpr)*pi_p + fpr
}

lower_envelope_func <- function(xs, ys) {
  function(pi_p) {
    values <- NULL
    for (i in 1:length(xs)) {
      values <- c(values, mce_func(xs[i], ys[i])(pi_p))
    }
    min(values)
  }

}

n_points <- 11

colors <- rainbow(n_points)

circle_points <- eq_spacing((n_points - 1) * 4, center = c(1, 0))
roc_df <- tail(circle_points, n=n_points-2)

lower_envelope_xs_ys <- lower_envelope_func(c(roc_df$x, 0, 1), c(roc_df$y, 0, 1))

roc_curve <- ggplot() +
  xlim(0, 1) +
  ylim(0, 1) +
  labs(x="False Positive Rate", y="True Positive Rate")

cost_curve <- ggplot() +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 1)) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 0.5)) +
  labs(x=expression(paste(pi["+"], " - Probability of Positive")), y="Error Rate") +
  geom_function(fun=mce_func(0, 0), color=colors[1]) +
  geom_function(fun=mce_func(1, 1), color=colors[length(colors)])

cost_lines <- list()

roc_curve <- roc_curve +
  annotate("point", x=0,y=0,fill=colors[1], shape=22, color='black', size=3) +
  annotate("point", x=1,y=1,fill=colors[length(colors)], shape=22, color='black', size=3)

p <- grid.arrange(roc_curve, cost_curve, ncol=2, nrow=1)
ggsave(glue("../figure/lower_envelope_1.png"), width = 7, height = 3.5, plot = p)

for (i in 1:nrow(roc_df)) {
  point <- roc_df[i, ]
  roc_curve <- roc_curve +
    annotate("point", x=point$x,y=point$y, fill=colors[i + 1], shape=22, color='black', size=3) +
    geom_line()
  mce_pi <- local({ local_point <- point;
    mce_func(local_point$x, local_point$y)})
  # cost_lines[[length(cost_lines) + 1]] <- geom_function(fun=mce_pi, color='black')
  cost_curve <- cost_curve +
    geom_function(fun=mce_pi, color=colors[i + 1])

  p <- grid.arrange(roc_curve, cost_curve, ncol=2, nrow=1)
  ggsave(glue("../figure/lower_envelope_{i + 1}.png"), width = 7, height = 3.5, plot = p)
}

roc_curve <- roc_curve +
  geom_line(data=data.frame(x=c(roc_df$x, 0, 1), y=c(roc_df$y, 0, 1)), aes(x=x,y=y))

# cost_curve
cost_curve <- cost_curve +
  geom_line(data=data.frame(x=seq(0,1,length=10000),
                            y=sapply(seq(0,1,length=10000), lower_envelope_xs_ys)),
            aes(x=x,y=y), color='black', size=1
  )

p <- grid.arrange(roc_curve, cost_curve, ncol=2, nrow=1)
ggsave(glue("../figure/lower_envelope_{nrow(roc_df)+2}.png"), width = 7, height = 3.5, plot = p)
