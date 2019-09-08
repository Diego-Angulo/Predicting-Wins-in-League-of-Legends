#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(readxl)

ModelTrain <- read_excel("ModelTrain.xlsx",
                         col_types = c(rep("guess", 5),rep("numeric", 2)),
                         sheet = 1, col_names = TRUE)

ModelTrain$result <- as.factor(ModelTrain$result)
ModelTrain$side <- as.factor(ModelTrain$side)
ModelTrain$elementalsd <- as.factor(ModelTrain$elementalsd)
ModelTrain$elderd <- as.factor(ModelTrain$elderd)
ModelTrain$barond <- as.factor(ModelTrain$barond)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    

    
    logistic1 <- glm(result ~ side + elementalsd + elderd + barond + gspd + wardratio,
                    data = ModelTrain, family ="binomial")
    
    Model_Prediction <- reactive({
        SideInput <- input$radioMap
        ElementalInput <- input$radioEle
        ElderInput <- input$radioEld
        BaronInput <- input$radioBar
        GSPDInput <- as.numeric(input$sliderGSPD)
        WardInput <- as.numeric(input$sliderWard)
        
        predict(logistic1, newdata = data.frame(side = SideInput, elementalsd = ElementalInput,
                                                elderd = ElderInput, barond = BaronInput,
                                               gspd = GSPDInput, wardratio = WardInput),
                                               type = "response")
    })
    
    output$Prediction <- renderText({
        Model_Prediction()
    
  })
  
})
