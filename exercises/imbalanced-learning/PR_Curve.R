



pdf("PR_curve_step_12.pdf", width = 6, height = 4)

plot(x=0,y=1,xlim=c(0,1),ylim=c(0,1),xlab="Recall",ylab="Precision")


#Step 1

z0 = c(0,1)
z1 = c(1/6,1)

segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=4)
points(z1[1],z1[2])


#Step 2
segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=3)

z0 = z1
z1 = c(1/3,1)

segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=4)
points(z1[1],z1[2])


#Step 3
segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=3)

z0 = z1
z1 = c(1/2,1)

segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=4)
points(z1[1],z1[2])

#Step 4
segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=3)

z0 = z1
z1 = c(1/2,3/4)

segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=4)
points(z1[1],z1[2])



#Step 5
segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=3)

z0 = z1
z1 = c(2/3,4/5)

segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=4)
points(z1[1],z1[2])

#Step 6
segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=3)

z0 = z1
z1 = c(2/3,2/3)

segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=4)
points(z1[1],z1[2])



#Step 7
segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=3)

z0 = z1
z1 = c(5/6,5/7)

segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=4)
points(z1[1],z1[2])



#Step 8
segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=3)

z0 = z1
z1 = c(5/6,5/8)

segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=4)
points(z1[1],z1[2])


#Step 9
segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=3)

z0 = z1
z1 = c(5/6,5/9)

segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=4)
points(z1[1],z1[2])


#Step 10
segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=3)

z0 = z1
z1 = c(5/6,1/2)

segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=4)
points(z1[1],z1[2])


#Step 11
segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=3)

z0 = z1
z1 = c(1,6/11)

segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=4)
points(z1[1],z1[2])


#Step 12
segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=3)

z0 = z1
z1 = c(1,1/2)

segments(x0=z0[1],y0=z0[2],x1=z1[1],y1=z1[2],col=4)
points(z1[1],z1[2])
dev.off()











