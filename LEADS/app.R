library(shiny)
library(DT)
library(dplyr)

# Example data
# leads <- your_data_source_here
leads_dash <- leads %>% select(Lead_Scholar, Job_Title, Type, Year, Organization)

# Assuming leads_dash is your actual dataset

# Define UI for application
ui <- fluidPage(
  titlePanel("LEADS Scholars"),
  sidebarLayout(
    sidebarPanel(
      selectInput("nameFilter", "Filter by Name", choices = c("Show All", unique(leads_dash$Lead_Scholar)), selected = "Show All"),  # Dropdown filter by Name
      selectInput("orgFilter", "Filter by Organization", choices = c("Show All", unique(leads_dash$Organization)), selected = "Show All")  # Dropdown filter by Organization
    ),
    mainPanel(
      DTOutput("table")  # Output for the table
    )
  )
)

# Define server logic
server <- function(input, output) {
  output$table <- renderDT({
    filteredData <- leads_dash  # Initialize with the entire dataset

    # Filter data based on selected name
    if (input$nameFilter != "Show All") {
      filteredData <- filteredData[filteredData$Lead_Scholar == input$nameFilter, ]
    }

    # Filter data based on selected organization
    if (input$orgFilter != "Show All") {
      filteredData <- filteredData[filteredData$Organization == input$orgFilter, ]
    }

    if (input$nameFilter == "Show All" && input$orgFilter == "Show All") {
      filteredData <- leads_dash  # Display all data when both filters are set to 'Show All'
    }

    datatable(filteredData, options = list(pageLength = 150))  # Set the default display length to show 25 entries
  })
}

# Run the application
shinyApp(ui = ui, server = server)
