library(viridis)

scale_c_d <- scale_colour_discrete <- scale_color_discrete <-
  function(...) viridis::scale_color_viridis(..., end = .9, discrete = TRUE, drop = TRUE)
scale_f_d <- scale_fill_discrete <-
  function(...) viridis::scale_fill_viridis(..., end = .9,  discrete = TRUE, drop = TRUE)
scale_c <- scale_colour_continuous <- scale_color_continuous <-
  function(...) viridis::scale_color_viridis(..., end = .9)
scale_f <- scale_fill_continuous <-
  function(...) viridis::scale_fill_viridis(..., end = .9)

pal_2 <- viridisLite::viridis(2, end = .9)
pal_3 <- viridisLite::viridis(3, end = .9)
pal_4 <- viridisLite::viridis(4, end = .9)
pal_5 <- viridisLite::viridis(5, end = .9)

scvd <- scale_color_viridis(end = 0.9, discrete = TRUE)

pal_2 <- viridisLite::viridis(2, end = .9)
pal_3 <- viridisLite::viridis(3, end = .9)
pal_4 <- viridisLite::viridis(4, end = .9)
pal_5 <- viridisLite::viridis(5, end = .9)