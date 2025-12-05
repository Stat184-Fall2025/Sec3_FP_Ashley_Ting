# Step 1.1 Install tidyverse 
install.packages("tidyverse")   # Installs the tidyverse collection (dplyr, ggplot2, readr, etc.) for data wrangling and visualization

# Step 1.2 Load tidyverse
library(tidyverse)              # Loads tidyverse so we can use functions like read_csv(), filter(), mutate(), ggplot(), etc.

# Step 2.1 Load the historical CPI data from Desktop
historical_raw <- read_csv("~/Desktop/184 project/historicalcpi.csv")   # Reads the historical CPI file from your Desktop into R

# Step 2.2 Load the forecast CPI data from Desktop
forecast_raw   <- read_csv("~/Desktop/184 project/CPIForecast.csv")     # Reads the USDA forecast file from your Desktop into R

# Step 2.3 Open both datasets in spreadsheet view (RStudio)
View(historical_raw)   # Opens the historical CPI dataset in a spreadsheet-like window so you can inspect rows and columns
View(forecast_raw)     # Opens the forecast dataset in a spreadsheet-like window to see its structure and content

# Step 3.1 Create a cleaned historical dataset for All food (2005–2024)
allfood_hist <- historical_raw %>%
  filter(str_detect(`Consumer Price Index item`, "All food"),  # Keep rows where the item text contains "All food"
         Year >= 2005, Year <= 2024) %>%                      # Restrict the years to 2005–2024
  mutate(Year = as.integer(Year)) %>%                         # Ensure Year is stored as an integer
  rename(pct_change = `Percent change`) %>%                   # Rename Percent change to pct_change
  mutate(type = "Historical") %>%                             # Tag these rows as Historical values
  select(Year, pct_change, type)                              # Keep only the three columns we need

View(allfood_hist)                                            # Inspect the cleaned historical All food data

# Step 3.2 Create a cleaned forecast dataset for top-level All food (2025–2026)

allfood_fc <- forecast_raw %>%
  filter(`Top-level` == "All food") %>%                # Keep only rows where Top-level is exactly "All food"
  filter(is.na(Aggregate)) %>%                         # Keep only the top-level All food rows (no subcategories)
  filter(Attribute %in% c("Mid point of prediction interval 2025",
                          "Mid point of prediction interval 2026")) %>%  # Keep only midpoint forecasts for 2025 and 2026
  mutate(
    Year       = parse_number(Attribute),              # Extract the year (2025 or 2026) from the Attribute text
    pct_change = Value,                                # Use Value as the forecasted percent change
    type       = "Forecast"                            # Tag these rows as Forecast values
  ) %>%
  select(Year, pct_change, type)                       # Keep only Year, pct_change, and type

View(allfood_fc)                                       # Inspect the cleaned forecast All food data

# Step 4.1 Combine historical and forecast data into one table
allfood_cpi <- bind_rows(allfood_hist, allfood_fc) %>%  # Stack the Historical and Forecast tables on top of each other
  arrange(Year)                                         # Sort the combined data by Year in ascending order

# Step 4.2 Inspect the combined dataset
View(allfood_cpi)                                       # Open the combined table to confirm it has years 2005–2026 and both types


# Step 5.0 Create a dataset for the forecast line that starts from 2024
forecast_line <- allfood_hist %>%
  filter(Year == 2024) %>%                 # Use the last historical year (2024) as the starting point
  mutate(type = "Forecast") %>%            # Label this row as Forecast
  bind_rows(allfood_fc %>%                 # Add the 2025–2026 forecast rows
              mutate(type = "Forecast"))

# Step 5.0b Build helper datasets and fix factor levels for 'type'
lines_df <- bind_rows(
  allfood_hist %>% mutate(type = "Historical"),  # 2005–2024
  forecast_line                                   # 2024–2026
) %>%
  mutate(type = factor(type, levels = c("Historical", "Forecast")))

points_df <- bind_rows(
  allfood_hist %>% mutate(type = "Historical"),  # 2005–2024
  allfood_fc   %>% mutate(type = "Forecast")     # 2025–2026
) %>%
  mutate(type = factor(type, levels = c("Historical", "Forecast")))

# Step 5.1 Final plot
food_cpi_plot <- ggplot(lines_df,
                        aes(x = Year,
                            y = pct_change,
                            linetype = type,
                            color    = type)) +   # Both linetype & color depend on 'type'
  geom_line(linewidth = 1) +                      # Draw lines
  geom_point(data = points_df,
             aes(x = Year, y = pct_change,
                 color = type),
             size = 2) +                          # Draw points
  # Here we explicitly define color & linetype mapping
  scale_linetype_manual(
    name   = "Data type",
    breaks = c("Historical", "Forecast"),
    values = c("Historical" = "solid",
               "Forecast"   = "dashed"),
    labels = c("Historical values (2005–2024)",
               "Forecast values (2025–2026)")
  ) +
  scale_color_manual(
    name   = "Data type",
    breaks = c("Historical", "Forecast"),
    values = c("Historical" = "black",   # Historical = black
               "Forecast"   = "blue"),   # Forecast   = blue
    labels = c("Historical values (2005–2024)",
               "Forecast values (2025–2026)")
  ) +
  labs(
    title    = "U.S. Food Inflation Rate (All food CPI Percent Change), 2005–2026",
    subtitle = "2005–2024 are historical All food CPI percent changes; 2025–2026 are USDA forecast midpoints",
    x        = "Year",
    y        = "Percent change (%)",
    caption  = "Source: USDA Economic Research Service, Food Price Outlook"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "right",
    plot.title      = element_text(face = "bold"),
    plot.subtitle   = element_text(margin = margin(b = 8))
  )

food_cpi_plot

#part 2
#A
# Vector of the four food categories we want to compare
items4 <- c("Eggs", "Pork", "Beef and veal", "Fresh fruits")

# Historical data for the four items, 2005–2024
hist_4items <- historical_raw %>%
  filter(`Consumer Price Index item` %in% items4,   # Keep only these four CPI items
         Year >= 2005, Year <= 2024) %>%           # Restrict years to 2005–2024
  mutate(
    item       = `Consumer Price Index item`,       # Save the item name in a simpler column
    Year       = as.integer(Year),
    pct_change = `Percent change`,                 # Rename Percent change to pct_change
    type       = "Historical"                      # Tag all rows as Historical
  ) %>%
  select(item, Year, pct_change, type)             # Keep only the columns we need

View(hist_4items)                                  # Check: 4 items × 20 years

#B
# Eggs: midpoint forecast for 2025 and 2026
eggs_fc <- forecast_raw %>%
  filter(`Top-level` == "All food",
         Aggregate   == "Food at home",
         `Mid-level` == "Eggs",
         str_detect(Attribute, "Mid point of prediction interval")) %>%  # 2025 & 2026
  mutate(
    item       = "Eggs",
    Year       = parse_number(Attribute),        # Extract 2025 or 2026
    pct_change = Value,
    type       = "Forecast"
  ) %>%
  filter(Year %in% c(2025, 2026)) %>%            # Keep only 2025–2026
  select(item, Year, pct_change, type)

# Pork: midpoint forecast for 2025 and 2026
pork_fc <- forecast_raw %>%
  filter(`Top-level` == "All food",
         Aggregate   == "Food at home",
         `Mid-level` == "Meats, poultry, and fish",
         `Low-level` == "Meats",
         Disaggregate == "Pork",
         str_detect(Attribute, "Mid point of prediction interval")) %>%
  mutate(
    item       = "Pork",
    Year       = parse_number(Attribute),
    pct_change = Value,
    type       = "Forecast"
  ) %>%
  filter(Year %in% c(2025, 2026)) %>%
  select(item, Year, pct_change, type)

# Beef and veal: midpoint forecast for 2025 and 2026
beef_fc <- forecast_raw %>%
  filter(`Top-level` == "All food",
         Aggregate   == "Food at home",
         `Mid-level` == "Meats, poultry, and fish",
         `Low-level` == "Meats",
         Disaggregate == "Beef and veal",
         str_detect(Attribute, "Mid point of prediction interval")) %>%
  mutate(
    item       = "Beef and veal",
    Year       = parse_number(Attribute),
    pct_change = Value,
    type       = "Forecast"
  ) %>%
  filter(Year %in% c(2025, 2026)) %>%
  select(item, Year, pct_change, type)

# Fresh fruits: midpoint forecast for 2025 and 2026
freshfruits_fc <- forecast_raw %>%
  filter(`Top-level` == "All food",
         Aggregate   == "Food at home",
         `Mid-level` == "Fruits and vegetables",
         `Low-level` == "Fresh fruits and vegetables",
         `Disaggregate` == "Fresh fruits",
         str_detect(Attribute, "Mid point of prediction interval")) %>%
  mutate(
    item       = "Fresh fruits",
    Year       = parse_number(Attribute),
    pct_change = Value,
    type       = "Forecast"
  ) %>%
  filter(Year %in% c(2025, 2026)) %>%
  select(item, Year, pct_change, type)

# Combine forecasts for the four items (2025–2026)
fc_4items <- bind_rows(eggs_fc, pork_fc, beef_fc, freshfruits_fc)

View(fc_4items)   # Should have 8 rows: 4 items × 2 years (2025 & 2026)


#C
# Build line dataset: historical + forecast line segment starting from 2024
forecast_line_4items <- hist_4items %>%
  filter(Year == 2024) %>%                     # Use 2024 as the starting point for the dashed line
  mutate(type = "Forecast") %>%                # Label 2024 as Forecast for the dashed segment
  bind_rows(fc_4items)                         # Add 2025–2026 forecast rows

lines_4items <- bind_rows(hist_4items, forecast_line_4items) %>%    # 2005–2024 (solid) + 2024–2026 (dashed)
  mutate(
    type = factor(type, levels = c("Historical", "Forecast")),
    item = factor(item, levels = c("Eggs", "Pork", "Beef and veal", "Fresh fruits"))
  )

# Build point dataset: historical points + true forecast points (2025–2026)
points_4items <- bind_rows(hist_4items, fc_4items) %>%
  mutate(
    type = factor(type, levels = c("Historical", "Forecast")),
    item = factor(item, levels = c("Eggs", "Pork", "Beef and veal", "Fresh fruits"))
  )

# Final multi-category plot: 4 lines, colors & shapes by item, dashed segment for forecasts
cpi_4items_plot <- ggplot(lines_4items,
                          aes(x = Year,
                              y = pct_change,
                              color    = item,      # Different colors for each category
                              linetype = type)) +   # Solid = Historical, dashed = Forecast
  geom_line(linewidth = 1) +
  geom_point(data = points_4items,
             aes(shape = item, color = item),
             size = 2) +
  scale_linetype_manual(
    name   = "Data type",
    values = c("Historical" = "solid",
               "Forecast"   = "dashed"),
    labels = c("Historical (2005–2024)",
               "Forecast (2025–2026)")
  ) +
  scale_color_manual(
    name   = "Food category",
    values = c("Eggs"          = "orange",
               "Pork"          = "pink",
               "Beef and veal" = "darkgreen",
               "Fresh fruits"  = "yellow")
  ) +
  scale_shape_manual(
    name   = "Food category",
    values = c("Eggs"          = 16,   # filled circle
               "Pork"          = 17,   # triangle
               "Beef and veal" = 15,   # square
               "Fresh fruits"  = 18)   # diamond
  ) +
  labs(
    title    = "Food Inflation by Category (CPI Percent Change), 2005–2026",
    subtitle = "Historical percent changes for Eggs, Pork, Beef and veal, and Fresh fruits (2005–2024), plus USDA midpoint forecasts for 2025–2026",
    x        = "Year",
    y        = "Percent change (%)",
    caption  = "Source: USDA Economic Research Service, Food Price Outlook"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "right",
    plot.title      = element_text(face = "bold"),
    plot.subtitle   = element_text(margin = margin(b = 8))
  )

cpi_4items_plot   # Draw the plot


#D
# Combine historical and forecast data for the four items
cpi_4items_all <- bind_rows(hist_4items, fc_4items) %>% 
  mutate(
    type = factor(type, levels = c("Historical", "Forecast")),          # For alpha legend
    item = factor(item, levels = c("Eggs", "Pork", "Beef and veal", "Fresh fruits"))
  )
# Bar chart: compare four categories over time (2005–2026)
cpi_4items_bar <- ggplot(
  cpi_4items_all,
  aes(x = factor(Year),                     # Treat Year as a categorical axis for bars
      y = pct_change,
      fill  = item,                         # Different colors for the four food categories
      alpha = type)                         # Stronger alpha for Historical, lighter for Forecast
) +
  geom_col(position = position_dodge(width = 0.8)) +  # Side-by-side bars within each year
  scale_fill_manual(
    name   = "Food category",
    values = c("Eggs"          = "orange",
               "Pork"          = "firebrick",
               "Beef and veal" = "darkgreen",
               "Fresh fruits"  = "royalblue")
  ) +
  scale_alpha_manual(
    name   = "Data type",
    values = c("Historical" = 1,    # Solid bars for historical values
               "Forecast"   = 0.5), # Lighter bars for forecast values
    labels = c("Historical (2005–2024)",
               "Forecast (2025–2026)")
  ) +
  labs(
    title    = "Food Inflation by Category (CPI Percent Change), 2005–2026",
    subtitle = "Bars show yearly percent changes for Eggs, Pork, Beef and veal, and Fresh fruits;\nlighter bars indicate USDA midpoint forecasts for 2025–2026",
    x        = "Year",
    y        = "Percent change (%)",
    caption  = "Source: USDA Economic Research Service, Food Price Outlook"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "right",
    plot.title      = element_text(face = "bold"),
    plot.subtitle   = element_text(margin = margin(b = 8)),
    axis.text.x     = element_text(angle = 45, hjust = 1)  # Rotate x labels so years are readable
  )

cpi_4items_bar


# Summary table for four food categories:
# historical mean/min/max (2005–2024) and forecasts for 2025–2026

summary_4items <- hist_4items %>%
  group_by(item) %>%                                         # Group by food category
  summarise(
    mean_2005_2024 = mean(pct_change, na.rm = TRUE),         # Average historical inflation
    min_2005_2024  = min(pct_change, na.rm = TRUE),          # Lowest historical year
    max_2005_2024  = max(pct_change, na.rm = TRUE)           # Highest historical year
  ) %>%
  left_join(
    fc_4items %>%
      select(item, Year, pct_change) %>%                     # Keep only forecasts
      tidyr::pivot_wider(
        names_from  = Year,
        values_from = pct_change,
        names_prefix = "forecast_"
      ),
    by = "item"
  ) %>%
  mutate(
    across(where(is.numeric), ~ round(.x, 1))                # Round all numeric columns to 1 decimal place
  ) %>%
  arrange(item)                                              # Sort rows by item name

summary_4items                                               # View in console

# Make a cleaner version of the summary table for viewing / screenshot
summary_4items_pretty <- summary_4items %>%
  # Give columns clearer, presentation-style names
  rename(
    Item                 = item,
    `Mean 2005–2024 (%)` = mean_2005_2024,
    `Min 2005–2024 (%)`  = min_2005_2024,
    `Max 2005–2024 (%)`  = max_2005_2024,
    `Forecast 2025 (%)`  = forecast_2025,
    `Forecast 2026 (%)`  = forecast_2026
  ) %>%
  # Ensure numeric values are nicely rounded (just in case)
  mutate(
    across(where(is.numeric), ~ round(.x, 1))   # Keep 1 decimal place for all numeric columns
  ) %>%
  arrange(Item)                                 # Sort rows by item name

# Open the table in spreadsheet view (good for screenshot)
View(summary_4items_pretty)                     # RStudio will show a clean table window
