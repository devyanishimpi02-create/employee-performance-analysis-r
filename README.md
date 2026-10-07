# Employee Performance Analysis (R Shiny)

An interactive dashboard built with R and Shiny to explore how employee performance relates to department, job role, overtime, training and job satisfaction.

**Live app:** https://devyani232006.shinyapps.io/employee_performance_analysis_r/

## Features

- **Filters:** Department, Overtime, Job Role and Gender
- **Summary cards:** total employees, average performance rating, average monthly income
- **Charts (average performance rating):**
  - by department
  - by job role
  - by training times last year
  - by overtime
  - by job satisfaction
- **Data table:** searchable, paginated view of the filtered employee data
- **Custom CSS:** card-style layout with a clean blue theme

All cards, charts and the table update together when a filter changes.

## Dataset

[IBM HR Analytics Employee Attrition & Performance](https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset) (`WA_Fn-UseC_-HR-Employee-Attrition.csv`).
It is a fictional dataset created by IBM data scientists, with about 1,470 employee records.

## Tech stack

- R
- [shiny](https://shiny.posit.co/)
- [tidyverse](https://www.tidyverse.org/) (dplyr, ggplot2, readr)
- [DT](https://rstudio.github.io/DT/)

## Run locally

1. Clone the repository:

   ```bash
   git clone https://github.com/YOUR-USERNAME/employee-performance-analysis-r.git
   cd employee-performance-analysis-r
   ```

2. Install the required packages in R:

   ```r
   install.packages(c("shiny", "tidyverse", "DT"))
   ```

3. Run the app:

   ```r
   shiny::runApp()
   ```

Make sure `app.R` and `WA_Fn-UseC_-HR-Employee-Attrition.csv` are in the same folder.

## Project structure

```
.
├── app.R
├── WA_Fn-UseC_-HR-Employee-Attrition.csv
├── README.md
└── .gitignore
```

## Notes on the analysis

- `PerformanceRating` only takes the values 3 and 4 in this dataset, and most employees are rated 3. The charts therefore use a y-axis from 3 to 4 to make differences visible, which also makes small gaps look larger than they are.
- This is exploratory analysis. It shows patterns between groups but does not show cause and effect.

## Deployment

Deployed on [shinyapps.io](https://www.shinyapps.io) using the `rsconnect` package:

```r
rsconnect::deployApp()
```

## Author

Devyani
