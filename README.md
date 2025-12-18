# How Have Food CPI Trends Changed Over the Past Two Decades?

## Overview

This project examines how food price inflation in the United States has changed over time using the Consumer Price Index (CPI). Specifically, we analyze the year by year CPI percentage change from 2005 to 2024 and summarize USDA forecasted values for 2025–2026. In addition, we extend the analysis to four specific food categories (eggs, pork, beef and veal, and fresh fruits) to highlight how inflation patterns differ substantially across food types.

The goal of the project is to better understand long-term trends in food inflation, identify periods of unusually high or low price changes, and compare historical behavior with USDA forecasts.

### Interesting Insight

One key insight from our analysis is that food price inflation experienced a significant spike around 2021–2022, with many categories showing sharp increases compared to previous years. This spike appears to be associated with pandemic-related supply chain disruptions and broader inflationary pressures that affected retail food prices across the country.
<img width="1732" height="1490" alt="visualation 1" src="https://github.com/user-attachments/assets/87e746ab-8e33-465e-9485-f4e38eca8080" />

## Data Sources and Acknowledgements

All data used in this project come from the USDA Economic Research Service (ERS) Food Price Outlook. The data is publicly available, updated regularly, and suitable for reproducible analysis.

Historical data (2005–2024):
historicalcpi.csv, which reports annual year-over-year percent changes in the CPI.

Forecast data (2025–2026):
CPIForecast.csv, using the midpoint of the USDA prediction intervals for the All food CPI and selected food categories.

Primary Data Source:
https://www.ers.usda.gov/data-products/food-price-outlook

We also acknowledge the support of course materials and guidance from the STAT 184 instructor and project template resources.

## Current Plan

Our project plan includes:

Data Wrangling & Cleaning:
Importing the USDA Food Price Outlook data, checking for tidy structure, and cleaning where necessary for analysis.

Exploratory Data Analysis (EDA):
Creating visualizations that show overall trends in CPI and differences across food categories.

Statistical Summaries:
Using descriptive statistics (e.g., dplyr::summarize(), psych::describe()) to summarize key patterns in the data.

Ethics & Open Science Reflection:
Discussing how the data satisfy FAIR and CARE principles and documenting coding practices using the PCIP system.

Final Report:
Rendering a reproducible Quarto PDF that ties together narrative text, figures, tables, and code documentation.

## Repo Structure

Sec3_FP_Ashley_Ting/
- Data Sources (CSV)/
    - CPIForecast.csv
    - historicalcpi.csv
- Data Visualizations/
    - vis_4category_cpi_hist.png
    - vis_4category_cpi_line.png
    - vis_allfood_cpi_hist_density.png
    - vis_allfood_cpi_line.png
    - vis_allfood_cpi_table.png
    - vis_allfood_maxmin_table.png
- MLA9.csl
- Project_Guidelines.md
- README.md
- Sec3_FP_FP_Ashley_Ting.R
- Sec3_FP_FP_Ashley_Ting.qmd
- Sec3_FP_FP_Ashley_Ting.pdf


## Authors

Ashley Song ajs10505@psu.edu
Ting Huang tfh5431@psu.edu
