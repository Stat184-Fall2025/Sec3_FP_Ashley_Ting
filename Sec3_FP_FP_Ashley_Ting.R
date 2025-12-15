# Install tidyverse 
install.packages("tidyverse")
library(tidyverse)

# Load CPI data (reproducible within GitHub)
historical_raw <- read_csv("Data Sources (CSV)/historicalcpi.csv")
forecast_raw   <- read_csv("Data Sources (CSV)/CPIForecast.csv")

View(historical_raw) 
View(forecast_raw)   

# Data wrangling + cleaning: All food CPI (Historical: 2005–2024)
allfood_hist <- historical_raw %>%
  filter(str_detect(`Consumer Price Index item`, "All food"),
         Year >= 2005, Year <= 2024) %>%
  mutate(Year = as.integer(Year)) %>%
  rename(pct_change = `Percent change`) %>%
  mutate(type = "Historical") %>%
  select(Year, pct_change, type)

View(allfood_hist)

# Data wrangling + cleaning: All food CPI (Forecast: 2025–2026 midpoints)
allfood_fc <- forecast_raw %>%
  filter(`Top-level` == "All food") %>%
  filter(is.na(Aggregate)) %>%
  filter(Attribute %in% c("Mid point of prediction interval 2025",
                          "Mid point of prediction interval 2026")) %>%
  mutate(
    Year       = parse_number(Attribute),
    pct_change = Value,
    type       = "Forecast"
  ) %>%
  select(Year, pct_change, type)

View(allfood_fc)

# Combine datasets: All food CPI (Historical + Forecast)
allfood_cpi <- bind_rows(allfood_hist, allfood_fc) %>%
  arrange(Year)

View(allfood_cpi)

# Helper datasets for Plot 1: make the dashed forecast line start at 2024 (last historical year)
forecast_line <- allfood_hist %>%
  filter(Year == 2024) %>%
  mutate(type = "Forecast") %>%
  bind_rows(allfood_fc %>%
              mutate(type = "Forecast"))

lines_df <- bind_rows(
  allfood_hist %>% mutate(type = "Historical"),
  forecast_line
) %>%
  mutate(type = factor(type, levels = c("Historical", "Forecast")))

points_df <- bind_rows(
  allfood_hist %>% mutate(type = "Historical"),
  allfood_fc   %>% mutate(type = "Forecast")
) %>%
  mutate(type = factor(type, levels = c("Historical", "Forecast")))

# Plot 1: All food CPI percent change over time
food_cpi_plot <- ggplot(lines_df,
                        aes(x = Year,
                            y = pct_change,
                            linetype = type,
                            color    = type)) +
  geom_line(linewidth = 1) +
  geom_point(data = points_df,
             aes(x = Year, y = pct_change,
                 color = type),
             size = 2) +
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
    values = c("Historical" = "black",
               "Forecast"   = "blue"),
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

# Data wrangling + cleaning: Four categories (Eggs, Pork, Beef and veal, Fresh fruits)
items4 <- c("Eggs", "Pork", "Beef and veal", "Fresh fruits")

hist_4items <- historical_raw %>%
  filter(`Consumer Price Index item` %in% items4,
         Year >= 2005, Year <= 2024) %>%
  mutate(
    item       = `Consumer Price Index item`,
    Year       = as.integer(Year),
    pct_change = `Percent change`,
    type       = "Historical"
  ) %>%
  select(item, Year, pct_change, type)

View(hist_4items)

# Data wrangling + cleaning: Four categories forecast values (2025–2026 midpoints)
eggs_fc <- forecast_raw %>%
  filter(`Top-level` == "All food",
         Aggregate   == "Food at home",
         `Mid-level` == "Eggs",
         str_detect(Attribute, "Mid point of prediction interval")) %>%
  mutate(
    item       = "Eggs",
    Year       = parse_number(Attribute),
    pct_change = Value,
    type       = "Forecast"
  ) %>%
  filter(Year %in% c(2025, 2026)) %>%
  select(item, Year, pct_change, type)

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

fc_4items <- bind_rows(eggs_fc, pork_fc, beef_fc, freshfruits_fc)

View(fc_4items)

# Helper datasets for Plot 2: make the dashed forecast segment start at 2024 for each category
forecast_line_4items <- hist_4items %>%
  filter(Year == 2024) %>%
  mutate(type = "Forecast") %>%
  bind_rows(fc_4items)

lines_4items <- bind_rows(hist_4items, forecast_line_4items) %>%
  mutate(
    type = factor(type, levels = c("Historical", "Forecast")),
    item = factor(item, levels = c("Eggs", "Pork", "Beef and veal", "Fresh fruits"))
  )

points_4items <- bind_rows(hist_4items, fc_4items) %>%
  mutate(
    type = factor(type, levels = c("Historical", "Forecast")),
    item = factor(item, levels = c("Eggs", "Pork", "Beef and veal", "Fresh fruits"))
  )

# Plot 2: Four-category trend comparison
cpi_4items_plot <- ggplot(lines_4items,
                          aes(x = Year,
                              y = pct_change,
                              color    = item,
                              linetype = type)) +
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
    values = c("Eggs"          = 16,
               "Pork"          = 17,
               "Beef and veal" = 15,
               "Fresh fruits"  = 18)
  ) +
  labs(
    title    = "Food Inflation by Category (CPI Percent Change), 2005–2026",
    subtitle = "Historical percent changes (2005–2024), plus USDA midpoint forecasts for 2025–2026",
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

cpi_4items_plot

# Data wrangling: combine historical + forecast for bar chart view
cpi_4items_all <- bind_rows(hist_4items, fc_4items) %>% 
  mutate(
    type = factor(type, levels = c("Historical", "Forecast")),
    item = factor(item, levels = c("Eggs", "Pork", "Beef and veal", "Fresh fruits"))
  )

# Plot 3: Grouped bar chart
cpi_4items_bar <- ggplot(
  cpi_4items_all,
  aes(x = factor(Year),
      y = pct_change,
      fill  = item,
      alpha = type)
) +
  geom_col(position = position_dodge(width = 0.8)) +
  scale_fill_manual(
    name   = "Food category",
    values = c("Eggs"          = "orange",
               "Pork"          = "firebrick",
               "Beef and veal" = "darkgreen",
               "Fresh fruits"  = "royalblue")
  ) +
  scale_alpha_manual(
    name   = "Data type",
    values = c("Historical" = 1,
               "Forecast"   = 0.5),
    labels = c("Historical (2005–2024)",
               "Forecast (2025–2026)")
  ) +
  labs(
    title    = "Food Inflation by Category (CPI Percent Change), 2005–2026",
    subtitle = "Bars show yearly percent changes; lighter bars indicate USDA midpoint forecasts for 2025–2026",
    x        = "Year",
    y        = "Percent change (%)",
    caption  = "Source: USDA Economic Research Service, Food Price Outlook"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "right",
    plot.title      = element_text(face = "bold"),
    plot.subtitle   = element_text(margin = margin(b = 8)),
    axis.text.x     = element_text(angle = 45, hjust = 1)
  )

cpi_4items_bar

# Table: historical mean/min/max (2005–2024) + forecast midpoints (2025–2026)
summary_4items <- hist_4items %>%
  group_by(item) %>%
  summarise(
    mean_2005_2024 = mean(pct_change, na.rm = TRUE),
    min_2005_2024  = min(pct_change, na.rm = TRUE),
    max_2005_2024  = max(pct_change, na.rm = TRUE)
  ) %>%
  left_join(
    fc_4items %>%
      select(item, Year, pct_change) %>%
      tidyr::pivot_wider(
        names_from  = Year,
        values_from = pct_change,
        names_prefix = "forecast_"
      ),
    by = "item"
  ) %>%
  mutate(
    across(where(is.numeric), ~ round(.x, 1))
  ) %>%
  arrange(item)

summary_4items

# Table 1: cleaned version of the summary table
summary_4items_pretty <- summary_4items %>%
  rename(
    Item                 = item,
    `Mean 2005–2024 (%)` = mean_2005_2024,
    `Min 2005–2024 (%)`  = min_2005_2024,
    `Max 2005–2024 (%)`  = max_2005_2024,
    `Forecast 2025 (%)`  = forecast_2025,
    `Forecast 2026 (%)`  = forecast_2026
  ) %>%
  mutate(
    across(where(is.numeric), ~ round(.x, 1))
  ) %>%
  arrange(Item)

View(summary_4items_pretty)

# Table 2: three highest and three lowest historical inflation years (All food, 2005–2024)
allfood_extremes <- allfood_hist %>%
  select(Year, pct_change) %>%
  arrange(desc(pct_change)) %>%
  slice_head(n = 3) %>%
  mutate(Rank = paste0("Highest #", row_number())) %>%
  bind_rows(
    allfood_hist %>%
      select(Year, pct_change) %>%
      arrange(pct_change) %>%
      slice_head(n = 3) %>%
      mutate(Rank = paste0("Lowest #", row_number()))
  ) %>%
  mutate(pct_change = round(pct_change, 1)) %>%
  select(Rank, Year, pct_change) %>%
  arrange(desc(pct_change))

allfood_extremes_pretty <- allfood_extremes %>%
  rename(`Percent change (%)` = pct_change)

View(allfood_extremes_pretty)

# Plot 4: distribution of historical All food CPI percent changes (2005–2024)
allfood_dist_plot <- ggplot(allfood_hist, aes(x = pct_change)) +
  geom_histogram(
    binwidth = 1,
    boundary = 0,
    fill = "steelblue",
    color = "white",
    alpha = 0.7
  )+
  geom_density(aes(y = after_stat(density) * 1), linewidth = 1) +
  labs(
    title = "Distribution of U.S. Food Inflation Rate (All food CPI), 2005–2024",
    subtitle = "Histogram of yearly CPI percent changes with a density curve",
    x = "Percent change (%)",
    y = "Count",
    caption = "Source: USDA Economic Research Service, Food Price Outlook"
  ) +
  theme_minimal(base_size = 13)

allfood_dist_plot
