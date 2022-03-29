library(FNN)
library(purrr)
set.seed(12345)

dist_p <- function(dim, n_per_dim = 1e4, k = 1) {
  x <- matrix(runif(dim * n_per_dim), ncol = dim)
  dist <- as.vector(dist(x))
  dist_nn <- FNN::knn.dist(x, k = k)
  data.frame(dim = dim,
       min = min(dist),
       mean = mean(dist),
       max = max(dist),
       mean_nn = mean(dist_nn),
       max_nn = max(dist_nn))
}

dists <- data.table::rbindlist(lapply(c(1,2,3,5,10,20,50,100,500), dist_p))

saveRDS(dists, "distances_dataset.rds")