#image link for the regression example: 
#"https://docs.google.com/presentation/d/1Pns5UJyc-Aqyk9d-CLekA46BC7UJ_e0uSdErat47opM/edit#slide=id.p"

#code_snippet for the graph:

require(ggplot2)

x = seq(0,1,0.005)
y = (sin(4*x-4))*((2*x-2)^2)*(sin(20*x-4))
y[is.na(y)] <- 0
y = y + rnorm(length(x)) * 0.1
df <- data.frame(x=x, y=y)

fun.1 <- function(x) (sin(4*x-4))*((2*x-2)^2)*(sin(20*x-4))

#data points
ggplot()+geom_point(data=df, aes(x=x, y=y),color="blue")+
  stat_function(aes(x=x, y=y), color="black", geom = "path", fun = fun.1)





