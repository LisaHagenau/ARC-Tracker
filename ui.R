library(shiny)

shinyUI(fluidPage(
  
  # Application title
  titlePanel("ARC Position Tracker"),
  
  # Map at the top spanning the entire width of window
  leafletOutput("Map", width="100%", height=450),
  
  hr(),
  
  fluidRow(
    column(3, offset=1,
           sliderInput("daterangeInput", "Date", min=min(allpositions$time), 
                       max=max(allpositions$time), 
                       value=c(min(allpositions$time), max(allpositions$time)))
           ),
    column(2,offset=1,
           checkboxGroupInput("classInput", "Class", 
                              choices = sort(unique(allpositions$Class)),
                              selected = allpositions[allpositions$BoatName=="Luna",
                                                      "Class"],
                              inline=TRUE)
           ),
    column(4, offset=1,
           #actionButton("selectallboats", label="Select/Deselect all"),
           uiOutput("boatnameOutput"),
           actionButton("selectallboats", label="Select/Deselect all")
           )
  ),
  
  br(), br(),
  h3(textOutput("currentstandings")),
          textOutput("note"), 
  br(), br(),
          dataTableOutput("Positiontable")
))
  
  
