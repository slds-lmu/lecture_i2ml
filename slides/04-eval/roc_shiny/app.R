#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Example Naive Method"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        numericInput("npos",
          "POS", value = 100),
        numericInput("nneg",
          "NEG", value = 100),
         sliderInput("posmean",
                     "POSITIVE mean",
                     min = 1,
                     max = 10,
                     value = 6),
        sliderInput("negmean",
          "NEGATIVE mean",
          min = 1,
          max = 10,
          value = 4),
        sliderInput("threshold",
          "Threshold",
          min = 1, max = 10, value = 1, step = 0.1
          )
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        plotOutput("distPlot"),
        tableOutput("conftable"),
        plotOutput("roc")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    
    output$distPlot <- renderPlot({
      set.seed(1)
      pos = rnorm(input$npos, mean = input$posmean)
      neg = rnorm(input$nneg, mean = input$negmean)
      df = list(pos = pos, neg = neg)
      dfs = stack(df)
      p = ggplot(dfs, aes(x=values)) + geom_density(aes(group=ind, colour=ind, fill=ind), alpha=0.3)
      p = p + xlim(0, 11)
      p = p + geom_vline(xintercept = input$threshold)
      p
   })
   
   output$conftable = renderTable({
      set.seed(1)
      pos = rnorm(input$npos, mean = input$posmean)
      neg = rnorm(input$nneg, mean = input$negmean)
      thresh = input$threshold
      TP = sum(pos > thresh)
      FN = sum(pos < thresh)
      TN = sum(neg < thresh)
      FP = sum(neg > thresh)
      confm = data.frame("Actual Positive" = c(TP, FN), "Actual Negative" = c(FP, TN))  
      colnames(confm) = c("Actual Positive", "Actual Negative")
      
      confm[3,1] = paste0("tpr = ", TP/input$npos)
      confm[3,2] = paste0("fpr = ", FP/input$nneg)
      rownames(confm) = c("Pred. Positive", "Pred. Negative", "")
      
      confm
  }, rownames = TRUE)
   
   output$roc = renderPlot({
     set.seed(1)
     pos = rnorm(input$npos, mean = input$posmean)
     neg = rnorm(input$nneg, mean = input$negmean)
     tpr = sapply(seq(1, 10, by = 0.1), function(x) sum(pos > x)/input$npos)
     fpr = sapply(seq(1, 10, by = 0.1), function(x) 1 - sum(neg < x)/input$nneg)
     rocdf = data.frame(tpr = tpr, fpr = fpr, tresh = seq(1, 10, by = 0.1))
     pr = ggplot(rocdf, aes(x = fpr, y = tpr)) + geom_point() + geom_path(data = rocdf)
     pr = pr + xlim(0,1) + ylim(0,1)
     pr = pr + geom_point(data = rocdf[which(rocdf$tresh == input$threshold), ], size = 10)
     pr
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

