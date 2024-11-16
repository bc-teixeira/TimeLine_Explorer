# Timeline Explorer: Interactive Visualization Tool

## Overview

The Timeline Explorer is a Shiny application built in R that provides an intuitive and interactive way to visualize time-based relationships between multiple events in large datasets. It enables users to explore patterns, trends, and key insights by dynamically interacting with the data.

## Introduction to the Timeline Explorer Plot

The Timeline Explorer Plot is a powerful interactive visualization tool that offers the following features:

   1.	**Event Representation Over Time**
 
        A horizontal timeline displays time points, and events are positioned along this axis to illustrate their occurrence or duration.

   2.	**Comparative Analysis**
        Events can be compared relative to a specific reference event, uncovering relationships and patterns over time.
	
   3.	**Interactive Exploration**
      •	Zoom in/out and scroll through time.
	 •	Hover over specific data points for detailed information.
	 •	Examine event trends with dynamic controls.

   5.	**Dynamic Insights**
This visualization enables deeper understanding through interactive exploration of event-based data, such as identifying clusters, trends, or outliers.

   6.	**R Shiny Integration**
The application leverages R Shiny to provide an easy-to-use interface for building interactive timeline visualizations.

## Features of the R Shiny App

The Timeline Explorer Shiny App uses R’s interactive web framework to deliver:

   1.	**User-Friendly Interaction**

        •	Collect input values through an intuitive web interface.
     
        •	Dynamically display results based on user interaction.
 
   2.	**Versatile Deployment Options**
 
        •	Host standalone applications on a webpage.
 
        •	Embed interactive charts in R Markdown documents.
 
        •	Build dashboards for a comprehensive view of data.
 
   3.	**Simple Architecture**
 
        •	UI (User Interface): Defines how the app looks and collects user inputs.
 
        •	Server Script: Executes R code and sends results back to the user interface.

## Creating the input Event Table and Timeline Explorer

### Preparing the Events Table

To generate the data for the timeline visualization:

   1.	**Required Variables**
 
        •	Patient_ID: Unique identifier for each patient.
 
        •	Event Classification: Types of events (e.g., diagnosis, treatment, etc.).
 
        •	Event Date: Date when the event occurred.
 
   2.	**Rules for Data Preparation**
 
        •	Each patient should have only one date per event type.
 
        •	If multiple dates exist for the same event, use the earliest date.
 

### Generating the Timeline Explorer

The app uses this prepared events table to create a dynamic timeline plot, enabling users to:

   1.	View heatmaps showing event frequency and distribution over time.
 
   2.	Compare events across categories relative to a reference event.
 
   3.	Analyze data with visual markers for median timing and annotated occurrence counts.
 

## Code Description: app.R

The app.R script performs the following tasks:

   1.	**Data Preparation**
 
        •	Loads the events dataset.
 
        •	Identifies the first occurrence of each event for every patient.
 
        •	Filters out patients with a “Diagnosis” event that occurred after other events.
 
   2.	**Interactive Visualization**
 
        •	Allows users to select events for visualization.
 
        •	Displays two interactive timeline plots:
 
        •	Heatmap: Frequency and distribution of events over time.
 
        •	Timeline Plot: Insights into median timings and annotated occurrences.

## How to Use

   1.	Clone this repository to your local machine.
 
   2.	Open the app.R file in RStudio or another IDE.
 
   3.	Run the app using the Shiny framework:
 

    shiny::runApp("app.R")


   4.	Interact with the timeline visualizations to explore your data.

This Shiny app provides a robust solution for exploring event-based data, helping users identify meaningful patterns and insights with ease.

## Navigating the timeline explorer

1. After running the R Shiny app code, the window appears as shown in the snippet below
![Timeline Explorer App](https://github.com/bc-teixeira/TimeLine_Explorer/blob/main/DOC/Plot_1.png?raw=true)

3. Select the event from the drop down box to get the timeline explorer plot for the specific event
![Select Event](https://github.com/bc-teixeira/TimeLine_Explorer/blob/main/DOC/Plot_2.png?raw=true)

4. We can zoom the required portion of the plot for better visualization.
   Red portion in the plot represents the maximum number of patients had the event at that timepoint
![Zoom-in](https://github.com/bc-teixeira/TimeLine_Explorer/blob/main/DOC/Plot_3.png?raw=true)


   
