# Timeline explorer plot using R shiny app
The timeline explorer is a shiny app that allows quick visualisation of the time relationship of multiple events in large datasets.

**Introduction to Timeline explorer plot**
1. A timeline explorer plot is an interactive data visualization tool used to represent events changes over time. It typically involves a horizontal axis (timeline) that displays time points, and events are placed along this axis to show their occurrence or duration
2. Using a timeline explorer plot, we can compare different events relative to a specific reference event, allowing for a deeper understanding of their relationships and patterns over time
3. Time line explorer chart can be achieved using R shiny app
4. A timeline explorer plot provides a dynamic way to explore data over time, with the added advantage of interaction, allowing users to examine patterns, trends, or key events in greater detail
5. Users can zoom in/out, scroll through time, or hover over specific data points to get more detailed information

**Overview of R shiny app**
1. Shiny is an R package that enables building interactive web applications that can execute R code on the backend.
2. With Shiny, we can host standalone applications on a webpage, embed interactive charts in R Markdown documents, or build dashboards
3. The Shiny web framework fundamentally enables collecting input values from a web page, making those inputs easily available to the application in R, and having the results of the R code written as output values to the web page. In its simplest form, a Shiny application requires a server function to do the calculations and a user interface. Shiny applications have two components, a user-interface definition and a server script

**Create ADS table and timeline explorer using R shiny**
1. Final ADS table should contain only three variables
     Patient_id
     Event classification - Different types of events
     Date of the event occurrence
2. One patient should have only one date of event occurrence for one event, If there are multiple dates for one event take first date of event occurrence

**Code is available in APP.R file**

1. This code loads an events dataset and identifies the first occurrence of each event for every patient. It filters out patients who had a “Diagnosis” event after any other event, as identified by comparing dates. The filtered patient IDs are then removed from both events and chemodetails datasets, retaining only relevant records.
2. The R shiny code provides an interactive timeline visualization for exploring event-based data across selected categories. Users can choose an event to view timelines displayed as heatmaps, which show the frequency and distribution of events over time relative to a reference date. Two plots offer insights into different aspects of the data, with visual markers for median timing and annotations indicating the number of occurrences. This tool is designed to help users easily track trends and patterns in the timeline data.

**Navigating the time line explorer**

1. After running the R Shiny app code, the window appears as shown in the snippet below

       DOC/Plot 1.png

2. Select the event from the drop down box to get the timeline explorer plot for the specific event

        DOC/Plot 2.png

3. We can zoom the required portion of the plot for better visualization.
   Red portion in the plot represents the maximum number of patients had the event at that timepoint
   
        DOC/Plot 3.png

   
