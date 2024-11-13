# Load required libraries
library(tidyverse)  # For data manipulation and visualization
library(shiny)      # For creating the Shiny web application
library(plotly)     # For interactive plots
library(htmlwidgets) # For HTML widgets in Shiny apps

# Load or read the  "Events.RData" file
# The file contains data on patient events and their corresponding dates

events <- read.csv("Events.csv")
#events data needs to have three columns:
#patid: patient identification number
#events: name of the event classified according to the need
#date: date of the event

# Create a data frame 'patfirst' to capture the first date each patient experienced each event
patfirst <- events %>% 
  group_by(patid, event) %>% 
  summarise(firstdt = min(date, na.rm = TRUE), .groups = "drop") # Get the earliest date for each event per patient

# Identify patients diagnosed after other events and exclude them from the analysis
eventdiag <- diag <- patfirst %>%
  filter(event == "Diagnosis") %>% # Filter for diagnosis events only
  left_join(
    patfirst %>% 
      filter(event != "Diagnosis") %>% # Exclude diagnosis events to get non-diagnosis events
      ungroup() %>% 
      group_by(patid) %>% 
      summarise(mindate = min(firstdt)), by = "patid" # Find earliest non-diagnosis event date per patient
  ) %>%
  filter(mindate < firstdt) %>% # Retain patients where non-diagnosis event occurred before diagnosis
  pull(patid)

# Exclude the identified patients from 'events' and 'chemodetails' datasets
events <- events %>% 
  filter(!patid %in% eventdiag)

chemodetails <- chemodetails %>% 
  filter(!patid %in% eventdiag)

# Define the UI for the Shiny app
ui <- fluidPage(
  
  # Title for the Shiny app
  titlePanel("MDV Gastric Cancer Timeline Navigator"),
  
  # Tab panel for event selection and visualization
  tabPanel("By Event", 
           fluidRow({
             selectInput("event", "Select Event", sort(unique(events$event))) # Dropdown for selecting an event
           }),
           fluidRow(
             # Plot output for events data
             plotlyOutput("distPlot1", width = "100%", height = "100%"),
             # Plot output for chemodetails data
             plotlyOutput("distPlot2", width = "100%", height = "100%"),
             widths = c(2, 8) # Set layout proportions
           )
  )
)

# Define server logic for the Shiny app
server <- function(input, output) {
  
  # Render the plot for events data
  output$distPlot1 <- renderPlotly({
    
    # Prepare data by calculating months since the first selected event
    base <- events %>% 
      left_join(patfirst %>% filter(event == input$event) %>% select(patid, firstdt), by = "patid") %>% 
      filter(!is.na(firstdt)) %>% 
      mutate(meses = floor(as.integer(date - firstdt) / 30.44)) # Calculate months between dates
    
    # Order events by patient count for better visualization
    event_order <- base %>% 
      group_by(event) %>% 
      summarise(npat = n_distinct(patid), .groups = "drop") %>% 
      arrange(desc(npat)) %>% 
      pull(event)
    base$event <- factor(base$event, levels = event_order)
    
    # Calculate patient count and median month for each event
    npat <- base %>% 
      group_by(event) %>% 
      summarise(npat = n(), .groups = "drop") %>% 
      mutate(npat = format(npat, big.mark = ","))
    medevent <- base %>% 
      group_by(event) %>% 
      summarise(median = median(meses))
    
    # Create ggplot for the events data
    p <- base %>% 
      group_by(event, meses) %>% 
      summarise(n = n(), .groups = "drop") %>% 
      group_by(event) %>% 
      mutate(perc = n / max(n)) %>% # Percentage for fill scale
      filter(between(meses, -72, 72)) %>% # Show only -72 to 72 months range
      ggplot(aes(x = meses, y = event, fill = perc)) +
      geom_tile() +
      geom_point(data = medevent, mapping = aes(x = median, y = event), inherit.aes = FALSE, size = 0.7) +
      geom_text(data = medevent, mapping = aes(x = median, y = event, label = median), inherit.aes = FALSE, size = 3, nudge_x = 1) +
      geom_vline(xintercept = 0, alpha = 0.5) +
      theme_classic() +
      labs(x = "Months", y = "Event") +
      theme(legend.position = "none") +
      scale_y_discrete(limits = rev) +
      scale_fill_gradient2(low = "#63BE7B", mid = "#FFEB84", high = "#F8696B", space = "Lab", midpoint = 0.5) +
      geom_text(data = npat, aes(x = 79, y = event, label = npat), inherit.aes = FALSE, hjust = 0)
    
    # Convert ggplot to plotly for interactivity
    ggplotly(p)
  })
  
  # Render the plot for chemodetails data, similar to events data plot
  output$distPlot2 <- renderPlotly({
    
    # Prepare data by calculating months since the first selected event
    base <- chemodetails %>% 
      left_join(patfirst %>% filter(event == input$event) %>% select(patid, firstdt), by = "patid") %>% 
      filter(!is.na(firstdt)) %>% 
      mutate(meses = floor(as.integer(date - firstdt) / 30.44)) # Calculate months between dates
    
    # Order the top 20 events by patient count
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
    
    # Calculate patient count and median month for top 20 events
    npat <- base %>% 
      group_by(event) %>% 
      summarise(npat = n(), .groups = "drop") %>% 
      mutate(npat = format(npat, big.mark = ",")) %>% 
      filter(event %in% event_top20)
    medevent <- base %>% 
      group_by(event) %>% 
      summarise(median = median(meses)) %>% 
      filter(event %in% event_top20)
    
    # Create ggplot for the chemodetails data
    p <- base %>% 
      group_by(event, meses) %>% 
      summarise(n = n(), .groups = "drop") %>% 
      group_by(event) %>% 
      mutate(perc = n / max(n)) %>% # Percentage for fill scale
      filter(between(meses, -72, 72)) %>% # Show only -72 to 72 months range
      filter(event %in% event_top20) %>% 
      ggplot(aes(x = meses, y = event, fill = perc)) +
      geom_tile() +
      geom_point(data = medevent, mapping = aes(x = median, y = event), inherit.aes = FALSE, size = 0.7) +
      geom_text(data = medevent, mapping = aes(x = median, y = event, label = median), inherit.aes = FALSE, size = 3, nudge_x = 1) +
      geom_vline(xintercept = 0, alpha = 0.5) +
      theme_classic() +
      labs(x = "Months", y = "Treatment") +
      theme(legend.position = "none") +
      scale_y_discrete(limits = rev) +
      scale_fill_gradient2(low = "#63BE7B", mid = "#FFEB84", high = "#F8696B", space = "Lab", midpoint = 0.5) +
      geom_text(data = npat, aes(x = 79, y = event, label = npat), inherit.aes = FALSE, hjust = 0)
    
    # Convert ggplot to plotly for interactivity
    ggplotly(p)
  })
}

# Run the Shiny application
shinyApp(ui = ui, server = server)
