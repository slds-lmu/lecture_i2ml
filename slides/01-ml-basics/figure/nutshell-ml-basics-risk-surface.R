library(plotly)
library(ggplot2)

#

Slope = c(-5,-4,-3,-2,-1,0,1,2,3,4,5)
Intercept = c(-5,-4,-3,-2,-1,0,1,2,3,4,5)
Risk = rbind(
  c(100,80,90,85,80,90,80,90,90,80,100),
  c(100,82,70,70,70,70,70,70,70,80,100),
  c(100,80,60,60,60,60,60,60,60,80,100),
  c(100,75,56,40,40,40,40,35,60,80,100),
  c(100,76,61,37,20,20,20,38,60,80,100),
  c(100,83,60,27,20,0.5,20,40,60,80,100),
  c(100,76,61,37,20,20,20,38,60,80,100),
  c(100,75,56,40,40,40,40,35,60,80,100),
  c(100,80,60,60,60,60,60,60,60,80,100),
  c(100,82,70,70,70,70,70,70,70,80,100),
  c(100,80,90,85,80,90,80,90,90,80,100))

marker_data = as.data.frame(cbind(annotation = c("Model with lowest empirical risk", "", "", "", ""), 
                                  x = c(0,2,3,-1.5,-2.2), y= c(0,3,-4,-2,2), z=c(10,70,90,55,50), 
                                  helper_col = c(1, 0, 0, 0, 0 )))

a <- list(x = 0,
          y = 0,
          z = 10,
          showarrow = TRUE,
          text = "Model with lowest empirical risk",
          xref = "x",
          yref = "y", 
          zref = "z",
          showarrow = FALSE,
          showarrow = TRUE,
          ax = 0,
          ay = -50,
          arrowhead = 1,
          xanchor = "left",
          yanchor = "bottom",
          font = list(
            color = "black",
            size = 12
          ),
          arrowcolor = "black",
          arrowsize = 3,
          arrowwidth = 1
)

fig <- plot_ly(
  type = 'surface',
  x = ~Slope,
  y = ~Intercept,
  z = ~Risk)
fig <- fig %>% layout(
  scene = list(
    xaxis = list(nticks = 20),
    zaxis = list(nticks = 6),
    camera = list(eye = list(x = 0, y = -1, z = 0.5)),
    aspectratio = list(x = .9, y = .8, z = 0.2),
    xaxis = list(title = 'Slope'),
    yaxis = list(title = 'Intercept'),
    zaxis = list(title = '')
  ),
  annotations = a
)

fig <- fig %>% add_markers(data = marker_data, x = ~x, y= ~y, z= ~z) 
fig <- fig %>% colorbar(title = "Empirical Risk", x = 1, y = 0.7)



