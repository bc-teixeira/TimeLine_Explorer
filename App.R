library(tidyverse)
library(shiny)
library(plotly)
library(htmlwidgets)



events <- read.csv("Events.csv")
#events data needs to have three columns:
#patid: patient identification number
#events: name of the event classified according to the need
#date: date of the event


patfirst <- events %>% 
  group_by(patid, event) %>% 
  summarise(firstdt = min(date, na.rm = TRUE), .groups = "drop")

eventdiag <- diag <- patfirst %>% 
  filter(event== "Diagnosis") %>% 
  left_join(patfirst %>% 
              filter(event!= "Diagnosis") %>% 
              ungroup() %>% 
              group_by(patid) %>% 
              summarise(mindate = min(firstdt)), by = "patid") %>%
  filter(mindate < firstdt) %>% 
  pull(patid)
  

events <- events %>% 
  filter(!patid %in% eventdiag)


chemodetails <- chemodetails %>% 
  filter(!patid %in% eventdiag)
    

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Timeline Navigator"),
  
  #By Event
  tabPanel("By Event", 
           fluidRow({
             selectInput("event", "Select Event",sort(unique(events$event)))
           }),
           fluidRow(
             plotlyOutput("distPlot1", width = "100%", height = "100%"),
             plotlyOutput("distPlot2", width = "100%", height = "100%"),
             widths = c(2,8))
  ))




# Define server logic required to draw a histogram
server <- function(input, output) {
  
  output$distPlot1 <- renderPlotly({
    
    base <- events %>% 
      left_join(patfirst %>% filter(event == input$event) %>% select(patid, firstdt), by = "patid") %>% 
      filter(!is.na(firstdt)) %>% 
      mutate(meses = floor(as.integer(date - firstdt)/30.44))
    
    event_order <- base %>% 
      group_by(event) %>% 
      summarise(npat = n_distinct(patid), .groups = "drop") %>% 
      arrange(desc(npat)) %>% 
      pull(event)
    
    base$event <- factor(base$event, levels = event_order)
    
    npat <- base %>% 
      group_by(event) %>% 
      summarise(npat = n(), .groups = "drop") %>% 
      mutate(npat = format(npat, big.mark = ","))
    
    medevent <- base %>% 
      group_by(event) %>% 
      summarise(median = median(meses))
    
    p <- base %>% 
      group_by(event, meses) %>% 
      summarise(n = n(), .groups = "drop") %>% 
      group_by(event) %>% 
      mutate(perc = n/max(n)) %>% 
      filter(between(meses, -72, 72)) %>% 
      ggplot(aes(x = meses, y = event, fill = perc)) +
      geom_tile() +
      geom_point(data = medevent, mapping = aes(x = median, y = event), inherit.aes = FALSE, size = 0.7)+
      geom_text(data = medevent, mapping = aes(x = median, y = event, label = median), inherit.aes = FALSE, size = 3, nudge_x = 1)+
      geom_vline(xintercept = 0, alpha = 0.5)+
      theme_classic() +
      labs(x = "Months", y = "Event") +
      theme(legend.position="none") +
      scale_y_discrete(limits=rev)+
      scale_fill_gradient2(low="#63BE7B", mid = "#FFEB84", high="#F8696B", space ="Lab", midpoint = 0.5) +
      geom_text(data = npat, aes(x = 79, y = event, label = npat), inherit.aes = FALSE, hjust = 0 )
    
    ggplotly(p)
    
  })
  
  
  
  output$distPlot2 <- renderPlotly({
    
    base <- chemodetails  %>% 
      left_join(patfirst %>% filter(event == input$event) %>% select(patid, firstdt), by = "patid") %>% 
      filter(!is.na(firstdt)) %>% 
      mutate(meses = floor(as.integer(date - firstdt)/30.44))
    
    event_order <- base %>% 
      group_by(event) %>% 
      summarise(npat = n_distinct(patid), .groups = "drop") %>% 
      arrange(desc(npat)) %>% 
      pull(event)
    
    base$event <- factor(base$event, levels = event_order)
    
    event_top20 <- base %>% 
      group_by(event) %>% 
      summarise(npat = n_distinct(patid), .groups = "drop") %>% 
      arrange(desc(npat)) %>% 
      head(20) %>% 
      pull(event)
    
    npat <- base %>% 
      group_by(event) %>% 
      summarise(npat = n(), .groups = "drop") %>% 
      mutate(npat = format(npat, big.mark = ",")) %>% 
      filter(event %in% event_top20)
    
    
    
    medevent <- base %>% 
      group_by(event) %>% 
      summarise(median = median(meses))%>% 
      filter(event %in% event_top20)
      
    p <- base %>% 
      group_by(event, meses) %>% 
      summarise(n = n(), .groups = "drop") %>% 
      group_by(event) %>% 
      mutate(perc = n/max(n)) %>% 
      filter(between(meses, -72, 72)) %>% 
      filter(event %in% event_top20) %>% 
      ggplot(aes(x = meses, y = event, fill = perc)) +
      geom_tile() +
      geom_point(data = medevent, mapping = aes(x = median, y = event), inherit.aes = FALSE, size = 0.7)+
      geom_text(data = medevent, mapping = aes(x = median, y = event, label = median), inherit.aes = FALSE, size = 3, nudge_x = 1)+
      geom_vline(xintercept = 0, alpha = 0.5)+
      theme_classic() +
      labs(x = "Months", y = "Treatment") +
      theme(legend.position="none") +
      scale_y_discrete(limits=rev)+
      scale_fill_gradient2(low="#63BE7B", mid = "#FFEB84", high="#F8696B", space ="Lab", midpoint = 0.5) +
      geom_text(data = npat, aes(x = 79, y = event, label = npat), inherit.aes = FALSE, hjust = 0 )
    
    ggplotly(p)
    
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
