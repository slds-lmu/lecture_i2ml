library(mvtnorm)
library(ggplot2)


setwd("figure_man/")


# Imbalanced Data Set for Title page (without main label)

set.seed(1234)

targetfile=paste("imbalanced_data_plot_title",".pdf",sep="")


pdf(targetfile,width=6,height=6)
cex_const=1



n = 1000

x = rmvnorm(n,mean=c(0,0),sigma = diag(2))

plot(x[,1],x[,2],pch=19,col=4,xlab=expression(x[1]),ylab=expression(x[2]),cex.lab=cex_const)


n = 50

x = rmvnorm(n,mean=c(0,-2),sigma = 0.1*diag(2))

points(x[,1],x[,2],pch=19,col=2,cex.lab=cex_const)
legend(-3, 3.3, legend=c("minority","majority"),
       col=c(2, 4), pch=c(19,19), cex=0.8)


dev.off()

# Imbalanced Data 

set.seed(1234)

setwd("figure_man/")
targetfile=paste("imbalanced_data_plot",".pdf",sep="")


pdf(targetfile,width=6,height=6)
cex_const=1



n = 1000

x = rmvnorm(n,mean=c(0,0),sigma = diag(2))

plot(x[,1],x[,2],pch=19,col=4,xlab=expression(x[1]),ylab=expression(x[2]),cex.lab=cex_const,main="Imbalanced Data Set")


n = 50

x = rmvnorm(n,mean=c(0,-2),sigma = 0.1*diag(2))

points(x[,1],x[,2],pch=19,col=2,cex.lab=cex_const)
legend(-3, 3.3, legend=c("positives","negatives"),
       col=c(2, 4), pch=c(19,19), cex=0.8)


dev.off()

# Balanced Data 

targetfile=paste("balanced_data_plot",".pdf",sep="")


pdf(targetfile,width=6,height=6)

n = 500

x = rmvnorm(n,mean=c(-1,-1),sigma = diag(2))

plot(x[,1],x[,2],pch=19,col=4,xlab=expression(x[1]),ylab=expression(x[2]),cex.lab=cex_const,xlim=c(-4,3.5),ylim=c(-4,3.5),main="Balanced Data Set")


x = rmvnorm(n,mean=c(1,1),sigma = diag(2))

points(x[,1],x[,2],pch=19,col=2)
legend(-4, 3, legend=c("positives","negatives"),
       col=c(2, 4), pch=c(19,19), cex=0.8)



dev.off()

