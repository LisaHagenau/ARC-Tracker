library(shiny)

#options(warn = 2, shiny.error = recover)


shinyServer(function(input, output, session) {
  
  # make dropdown menu with boatnames depending on which class was chosen
  output$boatnameOutput <- renderUI({
    selectInput("boatnameInput", "Boatname",
                choices = unique(
                  allpositions[allpositions$Class %in% input$classInput, "BoatName"]),
                selected = unique(
                  allpositions[allpositions$Class %in% input$classInput, "BoatName"]),
                multiple = TRUE
    )
  })
  
  # filter the dataset based on input variables
  filtered <- reactive({
   # if (is.null(input$classInput)) {
  #    return(NULL)
   # }    
    allpositions %>%
      filter(time >= input$daterangeInput[1],
             time <= input$daterangeInput[2],
             Class %in% input$classInput,
             BoatName %in% input$boatnameInput
          )
  })

  #observe({
    #print(input$daterangeInput)
    #print(input$classInput)
    #print(input$boatnameInput)
    #print(summary(filtered()))
    #print(str(filtered()))
#})
  
  # create color palette depending on number of selected boats
  marker = reactive({
    list(color = colorRampPalette(brewer.pal(9,"Set1"))(length(unique(filtered()$BoatName))))
  })
  
  pal <- reactive({
     colorFactor("Set1", levels=unique(filtered()$BoatName))
   })

# set up for offline use 
  addResourcePath("ARCmap", "../ARCmap/")
  
  output$Map <- renderLeaflet({
    leaflet(allpositions) %>% 
      addTiles(urlTemplate = "/ARCmap/{z}/{x}/{y}.pbf") %>%
    setView(-37.1777,20.0972,zoom = 5) 
    #%>%
    #fitBounds(~min(Long), ~min(Lat), ~max(Long), ~max(Lat))
  })
  
  # Plot the positions on the map    
  observe({
    marker <- marker()
    pal <- pal()
    m <- leafletProxy("Map", data = filtered()) %>%
      clearShapes() %>%
      addCircles(lng = filtered()$Long, lat = filtered()$Lat,
                 weight = 4, color = pal(filtered()$BoatName),
                 fillOpacity = 1, radius = 4, opacity = 1, data=filtered(),
                 popup = ~paste(BoatName))
    #weight = 4, color = marker(filtered()$BoatName),
    for(boat in unique(filtered()$BoatName)){
      data <- filtered()[filtered()$BoatName==boat,]
      m <- addPolylines(m,lng=~Long,lat=~Lat, 
                        weight=1, data=data, color = pal(data$BoatName),
                        popup = ~paste(BoatName)
      ) #weight=1, data=data, color = pal(data$BoatName),
    }
    m
  })
  
  observe({
    pal <- pal()
    proxy <- leafletProxy("Map", data = filtered()) %>% clearControls()
    proxy %>% addLegend(position = "bottomright",
                        pal = pal, values = ~BoatName,
                        title = NULL
    )
  })
          
  # filter last positions based on class input for current standings
  lastpositions <- reactive({
    if (is.null(input$classInput)) {
      return(NULL)
    }
    allpositions[allpositions$time == input$daterangeInput[2],] %>%
      filter(Class %in% input$classInput)
  })
  
  #observe({print(input$daterangeInput)})
  #observe({attr(allpositions$time, "tzone")})
  
  output$currentstandings <- renderText({
    "Current Ranking"
  })
    
  output$note <- renderText({
    "Please note: Boats that have arrived do not appear in this table. The ranking is calculated 
    from the positions of the boats still at sea."
  })
  # show last positions
  output$Positiontable <- renderDataTable({
    if(is.data.frame(lastpositions()) == FALSE) {
      return(NULL)
      }
    arrange(lastpositions(), Class, ranking)
    #lastpositions()
  })
  
  
  
  # select/deselect all boatnames using action button
  observe({
    if (input$selectallboats > 0) {
      if (input$selectallboats %% 2 == 0){
        updateSelectInput(session=session, 
                                 inputId="boatnameInput",
                                 choices = unique(
                                   allpositions[allpositions$Class %in% input$classInput, "BoatName"]),
                                 selected = unique(
                                   allpositions[allpositions$Class %in% input$classInput, "BoatName"]))
        
      } else {
        updateSelectInput(session=session, 
                                 inputId="boatnameInput",
                                 choices = unique(
                                   allpositions[allpositions$Class %in% input$classInput, "BoatName"]),
                                 selected = c())
      }}
  }) 
  
   
  
  
  
})
