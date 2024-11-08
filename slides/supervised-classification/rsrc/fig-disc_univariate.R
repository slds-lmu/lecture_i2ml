bh.man = c(184,177,185,179,182,182,178,176,184,173)
bh.woman = c(176,165,170,171,166,172,164,171,175,170)
mean(bh.man)
mean(bh.woman)

x = c(bh.man, bh.woman)
class = as.factor(rep(c("man", "woman"), each = 10))

df = data.frame(x, class)
str(df)

png("../figure/disc_univariate-1.png", width = 3000, height = 1300, res = 300)

layout(matrix(c(1, 2), nrow = 1, ncol = 2), widths = c(1, 2))
par(mar = c(4, 4, 1, 0.5))
hist(bh.man, breaks = seq(150, 200, by = 2), col = rgb(0, 0, 0, 0.5), 
     xlim = c(150, 200), ylim = c(0, 3), xlab = "body height (cm)", ylab = "frequency",
     main = "")
hist(bh.woman, breaks = seq(150, 200, by = 2), col = rgb(1, 0, 0, 0.5), add = TRUE)
legend("topright", legend = c("men", "women"), fill = c(rgb(0, 0, 0, 0.5), rgb(1, 0, 0, 0.5)))

par(mar = c(4, 4, 1, 1))
x = seq(150, 200, length.out = 100)
plot(x, dnorm(x, mean = 170, sd = 4), type = "l", col = "red", lty = 2, 
     xlim = c(150, 200), ylim = c(0, 0.1), ylab = "p(x|y=k)", xlab = "x (body height in cm)")
abline(v = 175, col = "grey", lty = 2)
axis(1, at = seq(155, 195, by = 10))
lines(x, dnorm(x, mean = 180, sd = 4)) 
legend("topright", legend = c("k = woman ~ N(170, 4)", "k = man ~ N(180, 4)"), 
       col = c("red", "black"), lty = c(2, 1))

dev.off()

# plot 2
png("../figure/disc_univariate-2.png", width = 3000, height = 1300, res = 300)
par(mar = c(4,4,1,1))
x = seq(150, 200, length.out = 100)
y.woman = dnorm(x, mean = 170, sd = 4)
y.man = dnorm(x, mean = 180, sd = 4)

plot(x, y.woman, type = "l", col = "red", lty = 2, xlim = c(150, 200), ylim = c(0, 0.1), 
     ylab = "p(x|y=k)", xlab = "x (body height in cm)")
axis(1, at = seq(155, 195, by = 10))
lines(x, y.man) 
legend("topright", legend = c("k = woman ~ N(170, 4)", "k = man ~ N(180, 4)"), 
       col = c("red", "black"), lty = c(2, 1))

lines(c(0, 172, 172), c(rep(dnorm(172, mean = 170, sd = 4), 2), -1), col = "red", lty = 2)
text(155, dnorm(172, mean = 170, sd = 4), pos = 3, col  = "red",
     labels = paste0("p(x|y = woman) = ", woman <- round(dnorm(172, mean = 170, sd = 4), 4)))

lines(c(0, 172, 172), c(rep(dnorm(172, mean = 180, sd = 4), 2), -1), 
      col = "black", lty = 2)
text(155, dnorm(172, mean = 180, sd = 4), 
     labels = paste0("p(x|y = man) = ", man <- round(dnorm(172, mean = 180, sd = 4), 4)), 
     pos = 3, col  = "black")
dev.off()

# plot 3
png("../figure/disc_univariate-3.png", width = 3000, height = 1300, res = 300)
par(mar = c(4,4,1,1), mfrow = c(1,2))

y.woman = dnorm(x, mean = 170, sd = 4)
y.man = dnorm(x, mean = 180, sd = 4)
plot(x, y.woman, type = "l", col = "red", lty = 2, 
     xlim = c(150, 200), ylim = c(0, 0.15),
     main = "Equal Class Size",
     ylab = "p(x|y=k)",  #yaxt = "n",
     xlab = "x (body height in cm)")
abline(v = 175, col = "grey", lty = 2)
axis(1, at = seq(155, 195, by = 10))
lines(x,y.man) 
legend("topright", legend = c("k = woman ~ N(170, 4)", "k = man ~ N(180, 4)"), 
       col = c("red", "black"), lty = c(2, 1))

x = seq(150, 200, length.out = 100)
y.woman = dnorm(x, mean = 170, sd = 4)*2/3#*2
y.man = dnorm(x, mean = 180, sd = 4)*1/3#*2

x = seq(150, 200, length.out = 100)
plot(x, y.woman, type = "l", col = "red", lty = 2, 
     xlim = c(150, 200), ylim = c(0, 0.15),
     main = "Unequal Class Size",
     ylab = expression("p(x|y=k)"~pi[k]),#  yaxt = "n",
     xlab = "x (body height in cm)")

f = function(x) (dnorm(x, mean = 170, sd = 4)*2/3 - dnorm(x, mean = 180, sd = 4)*1/3)
x.unequal = uniroot(f = f, lower = 170, upper = 200)$root

abline(v = x.unequal, col = "grey", lty = 2)
axis(1, at = seq(155, 195, by = 10))
lines(x,y.man) 
legend("topright", legend = c("k = woman ~ N(170, 4)", "k = man ~ N(180, 4)"), 
       col = c("red", "black"), lty = c(2, 1))
dev.off()

# plot 4
png("../figure/disc_univariate-4.png", width = 3000, height = 1300, res = 300)
f = function(x) (dnorm(x, mean = 170, sd = 4) - dnorm(x, mean = 180, sd = 9))
x1 = uniroot(f = f, lower = 170, upper = 200)$root
x2 = uniroot(f = f, lower = 150, upper = 170)$root
par(mar = c(4,4,1,1))
x = seq(150, 200, length.out = 100)
plot(x, dnorm(x, mean = 170, sd = 4), type = "l", col = "red", lty = 2, 
     xlim = c(150, 200), ylim = c(0, 0.1),
     ylab = expression("p(x|y=k)"~pi[k]), xlab = "x (body height in cm)")
axis(1, at = seq(155, 195, by = 10))
lines(x, dnorm(x, mean = 180, sd = 9)) 
legend("topright", legend = c("k = woman ~ N(170, 4)", "k = man ~ N(180, 9)"), 
       col = c("red", "black"), lty = c(2, 1))

abline(v = c(x1, x2), col = "gray", lty = 2)
dev.off()
