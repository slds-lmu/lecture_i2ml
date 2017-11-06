###**********************************************************
### CART
###**********************************************************
plot(iris[,1:4], col = as.numeric(iris[,5]))

library(rpart)
m1 = rpart(Species ~ ., data = iris)
m1
summary(m1)

plot(m1)
text(m1)
table(iris$Species, predict(m1, type = "class"))

# nicer options for plots
library(partykit)
m1b = as.party(m1)
plot(m1b)

library(rpart.plot)
rpart.plot(m1)
rpart.plot(m1, extra = 4)

# further rpart options (quite a lot)
?rpart.control

# prune the tree
prune(m1, cp = 0.45)


###**********************************************************
### C4.5
###**********************************************************
library(RWeka)
m2 = J48(Species ~ ., data = iris)
m2
summary(m2)
plot(m2)

# options for J48, WEKA style = unreadable one-letter names....

WOW("J48")

# J48 uses a different pruning procedure, we set the confidence level here

J48(Species ~ ., data = iris, control = Weka_control(C = 0.05))

