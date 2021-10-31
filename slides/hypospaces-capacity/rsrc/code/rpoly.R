library(ggplot2)

xplot = runif(300, -2, 1.5)
yplot = xplot^5 + 2* xplot^2 + 1 + rnorm(100, 0, 1.25)
ytrue = xplot^5 + 2* xplot^2 + 1

tot_data = data.frame(x = xplot, y = yplot)
tot_data_plot = data.frame(x = xplot, y = ytrue)
# plot(xplot,ytrue)

#seed 176 used
set.seed(176)
size <- floor(0.05 * length(xplot))
indices <- sample(seq_len(length(xplot)), size = size)

train <- tot_data[indices,]
test <- tot_data[-indices,]

# xtrain <- xplot[indices]
# ytrain <- xtrain^5 + 2* xtrain^2 + 1 + rnorm(length(xtrain), 0, 1.25)
# train <- data.frame(x = xtrain, y = ytrain)

# xtest <- xplot[-indices]
# ytest <- xtest^5 + 2* xtest^2 + 1 + rnorm(length(xtest), 0, 1.25)

model = lm(y ~ x, data = train)
model = lm(y ~ x + I(x^2) + I(x^3) + I(x^4) + I(x^5), data=train)
# model = lm(y ~ x + I(x^2) + I(x^3) + I(x^4) + I(x^5) + I(x^6) + I(x^7) + I(x^8) , data=train)
# model = lm(y ~ x + I(x^2) + I(x^3) + I(x^4) + I(x^5) + I(x^6), data=train)
model = lm(y ~ x + I(x^2) + I(x^3) + I(x^4) + I(x^5) + I(x^6) + I(x^7) + I(x^8) + I(x^9) + I(x^10) + I(x^11) + I(x^12) + I(x^13), data=train)

# model = lm(y ~ x + I(x^2) + I(x^3) + I(x^4) + I(x^5) + I(x^6) + I(x^7) + I(x^8) + I(x^9) + I(x^10) 
#            + I(x^11) + I(x^12) + I(x^13) + I(x^14) + I(x^15) + I(x^16) + I(x^17) + I(x^18), data=train)

preds = predict(model, tot_data)
predstest = predict(model, test)
plotmodel = data.frame(x = xplot, preds = preds)
plotmodel = plotmodel[order(plotmodel$x),]

plottrue = tot_data_plot[order(tot_data_plot$x),]

plot(train$x, train$y, cex = 2, lwd = 2, xlab = 'x', ylab = 'y', cex.lab = 2.5, main = "Polynomial (Degree = 13)", cex.main = 1.5)
lines(plotmodel$x,plotmodel$preds, lwd = 2, col = "green")
lines(plottrue$x, plottrue$y, lwd = 2, col = 'red')
legend(x = "bottomright", legend=c("Model", "True function"),
       col=c("green", "red"), lty=c(1,1), lwd = 4, cex=1.5)

summary(model)

rmse.train <- sqrt(mean(model$residuals^2))
rmse.test <- sqrt(mean((test$y - predstest)^2))

