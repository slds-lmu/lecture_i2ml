library(mvtnorm)
library(ggplot2)


setwd("figure_man/")


# Imbalanced Data Prediction 3 classes (Constant Model vs. Decision Tree)

set.seed(1234)

setwd("figure_man/")
targetfile=paste("three_classes",".pdf",sep="")


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
rect(xleft=xleft,xright = xright,ybottom = ybottom,ytop = ytop)


n = 25

x = rmvnorm(n,mean=c(-1.5,2),sigma = 0.1*diag(2))


xleft_2   = min(x[,1])
xright_2  = max(x[,1])
ybottom_2 = min(x[,2])
ytop_2    = max(x[,2])


points(x[,1],x[,2],pch=19,col=3,cex.lab=cex_const)
rect(xleft=xleft_2,xright = xright_2,ybottom = ybottom_2,ytop = ytop_2)


legend(2, 3.3, legend=c("Class 1","Class 2","Class 3"),
       col=c(2, 3,  4), pch=c(19,19,19), cex=0.8)


X=rbind(X,x)

dev.off()


dec_tree <- function(x,x1_range,x2_range,x1_range_2,x2_range_2){
  if(( x1_range[1] <= x[1]) *( x[1]<= x1_range[2])*( x2_range[1] <= x[2])*( x[2] <= x2_range[2]) ==1){
    return (2)
  }
  if(( x1_range_2[1] <= x[1]) *( x[1]<= x1_range_2[2])*( x2_range_2[1] <= x[2])*( x[2] <= x2_range_2[2]) ==1){
    return (3)
  }
  return (1)
}



# Accuracy calculations

y = apply(X = X, 1, dec_tree, x1_range=c(xleft,xright),x2_range=c(ybottom ,ytop), x1_range_2=c(xleft_2,xright_2),x2_range_2=c(ybottom_2 ,ytop_2) )

y_true = c(rep(1,1000),rep(2,25),rep(3,25))


# accuracy decision tree
sum(y==y_true)/length(y)
# accuracy naive majority predictor
1000/1050


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



