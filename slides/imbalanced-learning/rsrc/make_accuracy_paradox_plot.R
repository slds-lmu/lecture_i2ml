library(mvtnorm)
library(ggplot2)


setwd("figure_man/")


# Imbalanced Data Prediction (Constant Model vs. Decision Tree)

set.seed(1234)

setwd("figure_man/")
targetfile=paste("accuracy_paradox",".pdf",sep="")


pdf(targetfile,width=6,height=6)
cex_const=1


set.seed(1234)

n = 1000

x = rmvnorm(n,mean=c(0,0),sigma = diag(2))

X=x

plot(x[,1],x[,2],pch=19,col=4,xlab=expression(x[1]),ylab=expression(x[2]),cex.lab=cex_const,main="Imbalanced Data Set")


n = 25

x = rmvnorm(n,mean=c(0,-2),sigma = 0.1*diag(2))

xleft   = min(x[,1])
xright  = max(x[,1])
ybottom = min(x[,2])
ytop    = max(x[,2])

X=rbind(X,x)

points(x[,1],x[,2],pch=19,col=2,cex.lab=cex_const)
legend(-3, 3.3, legend=c("positives","negatives"),
       col=c(2, 4), pch=c(19,19), cex=0.8)

dec_tree <- function(x,x1_range,x2_range){
  2*( x1_range[1] <= x[1]) *( x[1]<= x1_range[2])*( x2_range[1] <= x[2])*( x[2] <= x2_range[2]) -1
}


rect(xleft=xleft,xright = xright,ybottom = ybottom,ytop = ytop)

dev.off()

# Accuracy calculations

y = apply(X = X, 1, dec_tree, x1_range=c(xleft,xright),x2_range=c(ybottom ,ytop))

1000/1025

(sum(y[1:1000]==-1)+sum(y[1001:1025]==1))/(1025)

sum(y[1001:1025]==1)


tp = sum(y[1001:1025]==1)
tn = sum(y[1:1000]==-1)
fp = sum(y[1:1000]==1)
fn = sum(y[1001:1025]==-1)

# accuracy
(tp + tn)/(tp+tn+fp+fn)
# recall
ppv = tp/(tp+fp)
ppv
# precision/ true positive rate
tpr = tp/(tp+fn)
tpr

# true negative rate
tnr = tn/(tn+fp)
tnr

#install.packages("psych") 
library("psych")


# F1 measure
harmonic.mean(x=c(ppv,tpr))

# G score
geometric.mean(x=c(ppv,tpr))

# G mean
geometric.mean(x=c(tpr,tnr))

# BAC
mean(c(tpr,tnr))

# MCC
(tp*tn - fp*fn)/(sqrt((tp+fn)*(tp+fp)*(tn+fn)*(tn+fp)))


