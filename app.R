library(shiny)
library(tidyverse)
library(DT)

# -----------------------------
# Load Dataset
# -----------------------------
# Keep the CSV in the same folder as app.R

data <- read_csv("WA_Fn-UseC_-HR-Employee-Attrition.csv") %>%
  mutate(
    Department      = as.factor(Department),
    JobRole         = as.factor(JobRole),
    OverTime        = as.factor(OverTime),
    Gender          = as.factor(Gender),
    JobSatisfaction = as.factor(JobSatisfaction)
  )

# -----------------------------
# CSS (inline, no www folder needed)
# -----------------------------

app_css <- "
body {
  background-color: #f4f6f9;
  font-family: 'Segoe UI', Helvetica, Arial, sans-serif;
  color: #333;
}

/* Page title */
.container-fluid > h2 {
  color: #1f3b63;
  font-weight: 700;
  padding-bottom: 10px;
  border-bottom: 3px solid #2c7be5;
  margin-bottom: 20px;
}

/* Sidebar */
.well.sidebar-card, .col-sm-4 > .well {
  background: #ffffff;
  border: none;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  text-align: left;
}

/* KPI cards */
.kpi-card {
  background: #ffffff;
  border: none;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  text-align: center;
  border-top: 4px solid #2c7be5;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.kpi-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 14px rgba(0, 0, 0, 0.12);
}

.kpi-card h4 {
  color: #6b7a90;
  font-size: 14px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-top: 0;
}

.kpi-card h2 {
  color: #2c7be5;
  font-weight: 700;
  margin: 5px 0 0 0;
}

/* Section headings */
.col-sm-8 > h3 {
  color: #1f3b63;
  font-weight: 600;
}

.section-title {
  color: #1f3b63;
  font-weight: 600;
  margin-top: 25px;
  padding-left: 10px;
  border-left: 4px solid #2c7be5;
}

/* Plot containers */
.shiny-plot-output {
  background: #ffffff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  padding: 10px;
}

/* Data table */
.dataTables_wrapper {
  background: #ffffff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  padding: 15px;
}
"

# -----------------------------
# UI
# -----------------------------

ui <- fluidPage(
  
  tags$head(
    tags$style(HTML(app_css))
  ),
  
  titlePanel("Employee Performance Analysis"),
  
  sidebarLayout(
    
    sidebarPanel(
      h4("Dashboard Filters"),
      
      selectInput(
        "department",
        "Select Department:",
        choices  = c("All", levels(data$Department)),
        selected = "All"
      ),
      
      selectInput(
        "overtime",
        "Select Overtime:",
        choices  = c("All", levels(data$OverTime)),
        selected = "All"
      ),
      
      selectInput(
        "jobrole",
        "Select Job Role:",
        choices  = c("All", levels(data$JobRole)),
        selected = "All"
      ),
      
      selectInput(
        "gender",
        "Select Gender:",
        choices  = c("All", levels(data$Gender)),
        selected = "All"
      )
    ),
    
    mainPanel(
      
      h3("Employee Performance Dashboard"),
      br(),
      
      fluidRow(
        column(4, wellPanel(class = "kpi-card",
                            h4("Total Employees"),
                            h2(textOutput("totalEmployees")))),
        column(4, wellPanel(class = "kpi-card",
                            h4("Average Performance"),
                            h2(textOutput("avgPerformance")))),
        column(4, wellPanel(class = "kpi-card",
                            h4("Average Monthly Income"),
                            h2(textOutput("avgIncome"))))
      ),
      
      h4("Performance by Department", class = "section-title"),
      plotOutput("departmentPlot", height = "350px"),
      
      h4("Performance by Job Role", class = "section-title"),
      plotOutput("jobRolePlot", height = "450px"),
      
      h4("Training vs Performance", class = "section-title"),
      plotOutput("trainingPlot", height = "350px"),
      
      h4("Overtime vs Performance", class = "section-title"),
      plotOutput("overtimePlot", height = "350px"),
      
      h4("Job Satisfaction vs Performance", class = "section-title"),
      plotOutput("satisfactionPlot", height = "350px"),
      
      h4("Employee Data", class = "section-title"),
      DTOutput("dataTable"),
      
      br()
    )
  )
)

# -----------------------------
# SERVER
# -----------------------------

server <- function(input, output, session) {
  
  # Filtered data
  filtered_data <- reactive({
    
    result <- data
    
    if (input$department != "All") {
      result <- result %>% filter(Department == input$department)
    }
    
    if (input$overtime != "All") {
      result <- result %>% filter(OverTime == input$overtime)
    }
    
    if (input$jobrole != "All") {
      result <- result %>% filter(JobRole == input$jobrole)
    }
    
    if (input$gender != "All") {
      result <- result %>% filter(Gender == input$gender)
    }
    
    result
  })
  
  # Helper: average performance by a grouping column
  avg_perf <- function(df, group_col) {
    df %>%
      group_by({{ group_col }}) %>%
      summarise(
        Average_Performance = mean(PerformanceRating, na.rm = TRUE),
        .groups = "drop"
      )
  }
  
  # PerformanceRating is only 3 or 4, so show the axis from 3 to 4
  perf_scale <- coord_cartesian(ylim = c(3, 4))
  
  # -----------------------------
  # Summary Cards
  # -----------------------------
  
  output$totalEmployees <- renderText({
    nrow(filtered_data())
  })
  
  output$avgPerformance <- renderText({
    req(nrow(filtered_data()) > 0)
    round(mean(filtered_data()$PerformanceRating, na.rm = TRUE), 2)
  })
  
  output$avgIncome <- renderText({
    req(nrow(filtered_data()) > 0)
    paste0(
      "$",
      format(
        round(mean(filtered_data()$MonthlyIncome, na.rm = TRUE)),
        big.mark = ","
      )
    )
  })
  
  # -----------------------------
  # Department Plot
  # -----------------------------
  
  output$departmentPlot <- renderPlot({
    req(nrow(filtered_data()) > 0)
    
    ggplot(
      avg_perf(filtered_data(), Department),
      aes(x = Department, y = Average_Performance)
    ) +
      geom_col(fill = "#2c7be5") +
      perf_scale +
      labs(
        title = "Average Performance by Department",
        x = "Department",
        y = "Average Performance"
      ) +
      theme_minimal()
  })
  
  # -----------------------------
  # Job Role Plot
  # -----------------------------
  
  output$jobRolePlot <- renderPlot({
    req(nrow(filtered_data()) > 0)
    
    ggplot(
      avg_perf(filtered_data(), JobRole),
      aes(x = reorder(JobRole, Average_Performance),
          y = Average_Performance)
    ) +
      geom_col(fill = "#2c7be5") +
      coord_flip(ylim = c(3, 4)) +
      labs(
        title = "Average Performance by Job Role",
        x = "Job Role",
        y = "Average Performance"
      ) +
      theme_minimal()
  })
  
  # -----------------------------
  # Training Plot
  # -----------------------------
  
  output$trainingPlot <- renderPlot({
    req(nrow(filtered_data()) > 0)
    
    ggplot(
      avg_perf(filtered_data(), TrainingTimesLastYear),
      aes(x = TrainingTimesLastYear, y = Average_Performance)
    ) +
      geom_line(color = "#2c7be5") +
      geom_point(color = "#2c7be5", size = 3) +
      perf_scale +
      labs(
        title = "Training vs Performance",
        x = "Training Times Last Year",
        y = "Average Performance"
      ) +
      theme_minimal()
  })
  
  # -----------------------------
  # Overtime Plot
  # -----------------------------
  
  output$overtimePlot <- renderPlot({
    req(nrow(filtered_data()) > 0)
    
    ggplot(
      avg_perf(filtered_data(), OverTime),
      aes(x = OverTime, y = Average_Performance)
    ) +
      geom_col(fill = "#2c7be5") +
      perf_scale +
      labs(
        title = "Overtime vs Performance",
        x = "Overtime",
        y = "Average Performance"
      ) +
      theme_minimal()
  })
  
  # -----------------------------
  # Satisfaction Plot
  # -----------------------------
  
  output$satisfactionPlot <- renderPlot({
    req(nrow(filtered_data()) > 0)
    
    ggplot(
      avg_perf(filtered_data(), JobSatisfaction),
      aes(x = JobSatisfaction, y = Average_Performance)
    ) +
      geom_col(fill = "#2c7be5") +
      perf_scale +
      labs(
        title = "Job Satisfaction vs Performance",
        x = "Job Satisfaction (1 = Low, 4 = Very High)",
        y = "Average Performance"
      ) +
      theme_minimal()
  })
  
  # -----------------------------
  # Data Table
  # -----------------------------
  
  output$dataTable <- renderDT({
    datatable(
      filtered_data(),
      options = list(pageLength = 10, scrollX = TRUE)
    )
  })
}

# -----------------------------
# Run Application
# -----------------------------

shinyApp(ui = ui, server = server)