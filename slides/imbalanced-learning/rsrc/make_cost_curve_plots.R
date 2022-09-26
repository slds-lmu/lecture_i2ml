
cost_fp = 1
cost_fn = 2

tpr = 0.4
fnr = 1- tpr
fpr = 0.3

cost_curve <- function(p,fpr=fpr,fnr=fnr){
((1-p)*fpr*cost_fp + p*fnr*cost_fn)/((1-p)*cost_fp + p*cost_fn)
}

curve(cost_curve(x,fpr=fpr,fnr=fnr),0,1,ylim=c(0.2,0.6),xlab=expression(pi),ylab="costs")

tpr = 0.7
fnr = 1- tpr
fpr = 0.5

curve(cost_curve(x,fpr=fpr,fnr=fnr),0,1,add=T,col=2)

tpr = 0.6
fnr = 1- tpr
fpr = 0.2

curve(cost_curve(x,fpr=fpr,fnr=fnr),0,1,add=T,col=3)



################################################################

################################################################

################################################################

#### 
# trivial classifiers for different costs

par(mfrow=c(4,1))

################################################################

################################################################
# same costs
cost_fp = 1
cost_fn = 1

# always wrong

tpr = 0
fnr = 1- tpr
fpr = 1

curve(cost_curve(x,fpr=fpr,fnr=fnr),0,1,ylim=c(0,1),lty=2,xlab=expression(pi),ylab="costs",main=paste("C(-1,1)=",cost_fn," C(1,-1)=",cost_fp))

# always positive

tpr = 1
fnr = 1- tpr
fpr = 1

curve(cost_curve(x,fpr=fpr,fnr=fnr),0,1,add=T,col=2,lty=2)


# always negative

tpr = 0
fnr = 1- tpr
fpr = 0

curve(cost_curve(x,fpr=fpr,fnr=fnr),0,1,add=T,col=3,lty=2)

# always right

tpr = 1
fnr = 1- tpr
fpr = 0

curve(cost_curve(x,fpr=fpr,fnr=fnr),0,1,add=T,col="blue",lty=2)


abline(v=cost_fp/(cost_fn+cost_fp))


################################################################
# twice for fn
cost_fp = 1
cost_fn = 2

# always wrong

tpr = 0
fnr = 1- tpr
fpr = 1

curve(cost_curve(x,fpr=fpr,fnr=fnr),0,1,ylim=c(0,1),lty=2,xlab=expression(pi),ylab="costs",main=paste("C(-1,1)=",cost_fn," C(1,-1)=",cost_fp))

# always positive

tpr = 1
fnr = 1- tpr
fpr = 1

curve(cost_curve(x,fpr=fpr,fnr=fnr),0,1,add=T,col=2,lty=2)


# always negative

tpr = 0
fnr = 1- tpr
fpr = 0

curve(cost_curve(x,fpr=fpr,fnr=fnr),0,1,add=T,col=3,lty=2)

# always right

tpr = 1
fnr = 1- tpr
fpr = 0

curve(cost_curve(x,fpr=fpr,fnr=fnr),0,1,add=T,col="blue",lty=2)

abline(v=cost_fp/(cost_fn+cost_fp))



################################################################
# twice for fp
cost_fp = 2
cost_fn = 1


# always wrong

tpr = 0
fnr = 1- tpr
fpr = 1

curve(cost_curve(x,fpr=fpr,fnr=fnr),0,1,ylim=c(0,1),lty=2,xlab=expression(pi),ylab="costs",main=paste("C(-1,1)=",cost_fn," C(1,-1)=",cost_fp))

# always positive

tpr = 1
fnr = 1- tpr
fpr = 1

curve(cost_curve(x,fpr=fpr,fnr=fnr),0,1,add=T,col=2,lty=2)


# always negative

tpr = 0
fnr = 1- tpr
fpr = 0

curve(cost_curve(x,fpr=fpr,fnr=fnr),0,1,add=T,col=3,lty=2)

# always right

tpr = 1
fnr = 1- tpr
fpr = 0

curve(cost_curve(x,fpr=fpr,fnr=fnr),0,1,add=T,col="blue",lty=2)

abline(v=cost_fp/(cost_fn+cost_fp))



################################################################
# much more for fn
cost_fp = 2.5
cost_fn = 6.5


# always wrong

tpr = 0
fnr = 1- tpr
fpr = 1

curve(cost_curve(x,fpr=fpr,fnr=fnr),0,1,ylim=c(0,1),lty=2,xlab=expression(pi),ylab="costs",main=paste("C(-1,1)=",cost_fn," C(1,-1)=",cost_fp))

# always positive

tpr = 1
fnr = 1- tpr
fpr = 1

curve(cost_curve(x,fpr=fpr,fnr=fnr),0,1,add=T,col=2,lty=2)


# always negative

tpr = 0
fnr = 1- tpr
fpr = 0

curve(cost_curve(x,fpr=fpr,fnr=fnr),0,1,add=T,col=3,lty=2)

# always right

tpr = 1
fnr = 1- tpr
fpr = 0

curve(cost_curve(x,fpr=fpr,fnr=fnr),0,1,add=T,col="blue",lty=2)

abline(v=cost_fp/(cost_fn+cost_fp))



