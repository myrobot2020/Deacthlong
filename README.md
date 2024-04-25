# Deacthlong
Retail Sales Data

# Customer Transactions Analysis Project

## Overview

This project involves the analysis of customer transactions data extracted from a retail database. The aim is to gain insights into customer behavior, seasonal trends, and profitability. The analysis is performed using R programming language and various packages such as `tidyverse`, `lubridate`, `prophet`, and others.

## Data

The data used in this analysis consists of customer transactions recorded over multiple years. Each transaction includes information such as Customer ID, Product details, Quantity, Price, and Invoice Date. The data is stored in an Excel file named `customer_transactions_sample.xlsx`, containing multiple sheets for different years.

## Analysis Steps

1. **Data Preparation**: The Excel data is loaded into R using the `readxl` package. Data cleaning and preprocessing steps include renaming columns, converting data types, filtering for relevant products and countries, and aggregating transaction quantities by day.

2. **Exploratory Data Analysis (EDA)**: Visualizations are created using `ggplot2` to explore trends in aggregated transaction quantities over time.

3. **Time Series Forecasting**: Time series forecasting is performed using the `prophet` package to predict future transaction quantities. The forecast is visualized along with upper and lower bounds.

4. **Profitability Analysis**: Profitability metrics are calculated, including total profits by country and revenue share during holiday seasons.

5. **Regression Analysis**: Linear regression models are fitted to explore relationships between variables such as working days, unique products, and customer counts.

## Results

The analysis provides insights into customer behavior, seasonal trends, and factors affecting profitability. Key findings include:

- Identification of popular product categories such as Christmas-related items.
- Seasonal patterns in transaction quantities, with increased sales during holiday seasons.
- Relationships between variables such as working days, unique products, and customer counts, influencing profitability.

## Files

- `customer_transactions_sample.xlsx`: Excel file containing raw data.
- `analysis_script.Rmd`: R Markdown file containing the R code for data analysis.
- `README.md`: This file providing an overview of the project.

## Usage

To replicate the analysis, follow these steps:

1. Ensure R and RStudio are installed on your system.
2. Clone or download the repository to your local machine.
3. Open the `analysis_script.Rmd` file in RStudio.
4. Install required R packages if not already installed (e.g., using `install.packages("package_name")`).
5. Run the R code chunks in the script to perform the analysis step-by-step.

## Contributors


Feel free to contribute to this project by suggesting improvements, providing feedback, or adding new analysis techniques.

