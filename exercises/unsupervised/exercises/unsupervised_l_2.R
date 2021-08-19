library(cluster)
data(ruspini)

# a)

plot(ruspini, pch = 19)
rusp.norm = scale(ruspini)
rusp.norm.euclid = dist(rusp.norm, method = "euclidean")

# b)

cl.sin = hclust(rusp.norm.euclid, method = "single")
cl.ave = hclust(rusp.norm.euclid, method = "average")
plot(cl.sin, hang = -1, main = "Dendrogram single linkage")
plot(cl.ave, hang = -1, main = "Dendrogram average linkage")


# c)

mycluster = function(data, cluster, K, ...) {
  col = cutree(cluster, k = K)
  plot(data, col = col, pch = 19, 
       main = paste(K, "clusters -", deparse(substitute(cluster))), ...)
}

par(mfrow = c(2,2))

mycluster(ruspini, cl.sin, K = 3)
mycluster(ruspini, cl.ave, K = 3)

mycluster(ruspini, cl.sin, K = 4)
mycluster(ruspini, cl.ave, K = 4)

par(mfrow = c(1,1))

# d)

set.seed(1)

K = 8
wss = sapply(2:K, function(k) {
  kmeans(ruspini, centers = k, nstart = 10, algorithm = "Lloyd")$tot.withinss
})

wss

# b)
plot(2:K, wss, type = "b", xlab = "K (# of clusters)", ylab = "within-cluster variation")

# Elbow looks good for K = 4 clusters
km = kmeans(ruspini, centers = 4, nstart = 10, algorithm = "Lloyd")
plot(ruspini, col = km$cluster, pch = 19)
