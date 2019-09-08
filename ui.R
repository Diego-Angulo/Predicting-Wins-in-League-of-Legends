#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(readxl)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    theme=shinytheme("darkly"),
   
  # Application title
  titlePanel("Predicting Wins in League of Legends"),
  h4("By Diego Angulo Quintana"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
        h2("Regressors:"),
        radioButtons("radioMap","1. Map Side", choices = list("Blue" =  "Blue", "Red" = "Red"),
                     inline = TRUE, selected = "Blue"),
        radioButtons("radioEle","2. Elemental Dragons Difference",
                     choices = list("[-6,-4]" =  "[-6,-4]", "[-3,-3]" =  "[-3,3]","[4,6]" =  "[4,6]"),
                     inline = TRUE, selected = "[-3,3]"),
        radioButtons("radioEld","3. Elder Dragons Difference",
                     choices = list("-2" = "-2", "-1" = "-1", "0" = "0","1" = "1","2" = "2"),
                     inline = TRUE, selected = "0"), 
        radioButtons("radioBar","4. Baron Nashors Difference",
                     choices = list("[-4,-2]" =  "[-4,-2]", "-1" =  "-1","0" =  "0","1" =  "1","[2,4]"="[2,4]"),
                     inline = TRUE, selected = "0"),
        sliderInput("sliderGSPD", "5.- Gold Spent Difference", -0.4, 0.4, 0),
        sliderInput("sliderWard", "6.- Ward Ratio", 2, 6, 2, step = 0.5)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
        tags$img(src="logo.png", heigh = 30, width= 700),
        h2("Background"),
        tags$li("This logistic regression model predicts the probability of winning a League of Legends match
          in late game, based on data from different professional regional League of Legends leagues like
          CBLoL, LCK, LCS, LEC, LMS and MSI in 2019."),
        tags$li("This model has a 70.93 % predictive power. And setting the threshold at 0.5, the model reports a
          92% accuracy."),
        
        tags$li("For more information about how I fit this model, check out my RPubs:"), 
        helpText( a("HERE", href="http://rpubs.com/diegolas/LogisticLoL")),
        h2("Estimated Probability"),
        textOutput("Prediction")
    )
  )
))
