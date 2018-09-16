library(jpeg)

img = readJPEG("colorful_bird.jpg") # Read the image

# img is a 3D array. Each pixel has information of 3 RGB colors.
imgDm = dim(img)
imgDm

# We re-arranged the 3D array into a dataset that has the coordinates of the pixel and the color information (R, G and B)
imgRGB = data.frame(
  x = rep(1:imgDm[2], each = imgDm[1]),
  y = rep(imgDm[1]:1, imgDm[2]),
  R = as.vector(img[,,1]),
  G = as.vector(img[,,2]),
  B = as.vector(img[,,3])
)
head(imgRGB)

# We now plot the pixels (pch = 15) with its RGB color info
plot(imgRGB$x, imgRGB$y, col = rgb(imgRGB[c("R", "G", "B")]), pch = 15)

# We now use kmeans to group the different colours into K = 1, 2, ..., 10 different colours and store the cluster variation
set.seed(1)
K = 10
wss = sapply(1:K, function(k) {
  kmeans(imgRGB[, c("R", "G", "B")], centers = k, nstart = 10, algorithm = "Lloyd")$tot.withinss
})
wss
# Looking for the "elbow" => K = 6
plot(1:K, wss, type = "b")

k = 6
kMeans = kmeans(imgRGB[, c("R", "G", "B")], centers = k)
predRGB = kMeans$centers[kMeans$cluster,]

plot(imgRGB$x, imgRGB$y, col = rgb(predRGB), pch = 15)
