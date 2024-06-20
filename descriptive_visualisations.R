
# DESCRIPTIVE VISUALISATIONS
# This R script produces the descriptive visualisations for the final thesis document.

## Libraries

#install.packages("tidyverse")
library(tidyverse)          # Used extensively for data manipulation and plotting

#install.packages("timetk")
library(timetk)             # Used for time series plotting functions like plot_time_series

#install.packages("lubridate")
library(lubridate)          # Used for date manipulation

#install.packages("cowplot")
library(cowplot)            # Used for arranging multiple plots

#install.packages("jtools")
library(jtools)             # Used for customizing ggplot themes

#install.packages("extrafont")
library(extrafont)          # Used for additional fonts in plots

#install.packages("showtext")
library(showtext)           # Used for additional fonts in plots

#install.packages("patchwork")
library(patchwork)          # Used for combining multiple ggplots

#install.packages("imputeTS")
library(imputeTS)           # Used for missing data imputation

#install.packages("scales")
library(scales) 


font_add_google("Lato", "lato")
showtext_auto()

font_add("Times New Roman", regular = "C:/Windows/Fonts/times.ttf",
         bold = "C:/Windows/Fonts/timesbd.ttf",
         italic = "C:/Windows/Fonts/timesi.ttf",
         bolditalic = "C:/Windows/Fonts/timesbi.ttf")


theme_apa_up <- theme_apa() +
  theme(
    text = element_text(family = "lato"),
    plot.title = element_text(family =  "Times New Roman", size = 12, hjust = 0, face = "bold"),
    plot.subtitle = element_text(family = "Times New Roman", size = 12, hjust = 0, face = "italic"),
    axis.title = element_text(family = "lato", size = 10),
    axis.text = element_text(family = "lato", size = 9),
    legend.title = element_text(family = "lato", size = 10),
    legend.text = element_text(family = "lato", size = 9)
  )

theme_apa_up_patch <- theme_apa() +
  theme(
    text = element_text(family = "lato"),
    plot.title = element_blank(),
    plot.subtitle = element_blank(),
    axis.title = element_text(family = "lato", size = 10),
    axis.text = element_text(family = "lato", size = 9),
    legend.title = element_text(family = "lato", size = 10),
    legend.text = element_text(family = "lato", size = 9)
  )



## Data


data <- read.csv("C:/Users/rnvis/Documents/Thesis/Data/full_data.csv")



data <- data |> 
  mutate(date = ymd(date)) |> 
  drop_na(AC) 

### Missing data


set.seed(123)

data$GDP_month <- na_interpolation(data$GDP_month)
data$production_agg_month <-na_interpolation(data$production_agg_month)


data <- data |> 
  drop_na(cat_prod) |> 
  filter(!(channel_code %in% c(6, 2))) |>  #do not include channel: 'other' and 'cash and carry
  filter(!(cat_prod %in% c("Coffee_and_tea", "confectionery_desserts", "Household_essentials", "personal_care"))) 




## Descriptive Statistics

### Visualisation


#### Products


#Transforming data for plotting the equivalenu units per product
e_u_cat<-data |> 
  drop_na() |> 
  group_by(date, cat_prod) |> 
  mutate(sum = sum(e_u)) |> 
  ungroup() |> 
  distinct(date, sum, cat_prod,  .keep_all = TRUE) 


v1_products<- e_u_cat |> 
  plot_time_series(date, sum, 
                   .smooth_alpha = c(0.5),
                   .color_var = product_categories ,
                   .facet_ncol = 3,
                   .interactive = FALSE,
                   .legend_show = TRUE,
                   .smooth = FALSE,
                   .x_lab = "Date",
                   .y_lab = "Equivalent Units sold",
                   .color_lab = "Product") +
  theme_apa_up +
  scale_y_continuous(labels = label_number(scale = 1e-6))+
  labs(title = "Figure 1",
       subtitle = "Time Series Equivalent Units by Product")

#Transforming data for plotting the sum of equivalent units (all products gathered) by autonomous community 
e_u_AC<-data |> 
  drop_na() |> 
  group_by(date, AC_code) |> 
  mutate(sum = sum(e_u)) |> 
  ungroup() |> 
  distinct(AC, date, sum, .keep_all = TRUE) 


#Plotting the sum of equivalent units by autonomous community using ggplot
v2_AC <- e_u_AC |> plot_time_series(date, sum, 
                                    .facet_scales = "free", 
                                    .facet_collapse =FALSE, 
                                    .facet_vars = AC,
                                    .smooth_alpha = c(0.5),
                                    .color_var = year(date),
                                    .facet_ncol = 3,
                                    .interactive = FALSE,
                                    .legend_show = FALSE,
                                    .x_lab = "Date",
                                    .y_lab = "Equivalent Units sold",
                                    .color_lab = "Year") +
  theme_apa_up+
  scale_y_continuous(labels = label_number(scale = 1e-6))+
  theme(legend.position = "none")+
  labs(title = "Figure 2",
       subtitle = "Time Series of the Aggregated Equivalent Units by Autonomous Community")

#plotting the sum of equivalent units by autonomous community and product type
e_u_AC_cat<-data |> 
  drop_na() |> 
  group_by(date, AC_code, cat_prod) |> 
  mutate(sum = sum(e_u)) |> 
  ungroup() |> 
  distinct(AC, date, sum, cat_prod, .keep_all = TRUE) 


v3_product_ac <- e_u_AC_cat |> 
  group_by(AC) |> 
  plot_time_series(date, sum, 
                   .facet_scales = "free", 
                   .facet_collapse =FALSE,
                   .smooth_alpha = c(0.5),
                   .color_var = product_categories,
                   .facet_ncol = 3,
                   .interactive = FALSE,
                   .legend_show = FALSE,
                   .smooth = FALSE,
                   .x_lab = "Date",
                   .y_lab = "Equivalent Units sold",
                   .color_lab = "Product") +
  theme_apa_up+
  scale_y_continuous(labels = label_number(scale = 1e-6))+
  guides(color = guide_legend(title = "Product"))+
   labs(title = "Figure 3",
       subtitle = "Time Series Equivalent Units by Product and Autonomous community")



#### Channels

# Creating a function to generate the plots
seaon_ac_total_func<- function(filter_channel, title_suffix, figure) {
  
  #Transforming data for plotting the sum of equivalent units by autonomous community and channel
  
  e_u_AC_c<-data|> 
    drop_na() |> 
    group_by(date, AC_code, channel) |> 
    mutate(sum = sum(e_u)) |> 
    ungroup() |> 
    distinct(AC, date, sum, channel, .keep_all = TRUE) 
  
  
  e_u_AC_c |>
    filter(channel %in% filter_channel) |> 
    group_by(AC) |> 
    plot_time_series(date, sum, 
                     .facet_scales = "free", 
                     .facet_collapse = FALSE,
                     .smooth_alpha = c(0.5),
                     .color_var = channel,
                     .facet_ncol = 3,
                     .interactive = FALSE,
                     .legend_show = TRUE,
                     .smooth = FALSE,
                     .x_lab = "Date",
                     .y_lab = "Equivalent Units sold",
                     .color_lab = "Sales channel") +
    theme_apa_up+
    scale_y_continuous(labels = label_number(scale = 1e-6))+
    guides(color = guide_legend(title = "Sales Channel"))+
    labs(title = paste(figure),
         subtitle = paste("Time Series Equivalent Units by Sales Channel", title_suffix))
}

inc_tradicional <- data$channel
excl_tradicional <-data$channel[data$channel != "Tradicional"]

filter_channel <- list(inc_tradicional, excl_tradicional)
title_suffix <- c("", "(excluding tradicional)")
figure <- c("Figure 4", "Figure 5")


x <- list()

for (i in seq_along(title_suffix)) {
  x[[i]] <- seaon_ac_total_func(filter_channel[[i]],title_suffix[i], figure[i] )
}



v4_channel_inc_tradicional <- plot_grid(plotlist = x[1])
v5_channel_ex_tradicional <- plot_grid(plotlist = x[2])


#### Consumer Price Index

cpi <- data |> 
  distinct(AC, food_cpi, non_alc_bev_cpi, alc_bev_cpi, pers_care_cpi, date) |> 
  rename("Food" = food_cpi, "Non-alcoholic beverages" = non_alc_bev_cpi, "Alcoholic beverages" = alc_bev_cpi, "Personal care products" = pers_care_cpi) |> 
  pivot_longer(cols = c("Food", "Non-alcoholic beverages", "Alcoholic beverages", "Personal care products"), names_to = "CPI_type", values_to = "CPI_value") |> 
  drop_na() 


v6_cpi <-cpi |> 
  group_by(AC) |> 
  plot_time_series(date, CPI_value, 
                   .facet_scales = "free", 
                   .facet_collapse =FALSE,
                   .smooth_alpha = c(0.5),
                   .color_var = CPI_type,
                   .facet_ncol = 3,
                   .interactive = FALSE,
                   .legend_show = TRUE,
                   .smooth = FALSE,
                   .title = "Consumer Price Index per Product Type for each Autonomous Community",
                   .x_lab = "Date",
                   .y_lab = "Consumer Price Index",
                   .color_lab = "CPI type")+
  theme_apa_up+
  guides(color = guide_legend(title = "CPI type"))+
  labs(title = "Figure 6",
       subtitle = "Consumer Price Index per Product Type for each Autonomous Community")



#### GDP

v7_gdp <-data |> 
  filter(year >2017 & year<2023) |> 
  plot_time_series(year, GDP, 
                   .facet_scales = "free", 
                   .facet_collapse =FALSE,
                   .smooth_alpha = c(0.5),
                   .color_var = AC,
                   .facet_ncol = 3,
                   .interactive = FALSE,
                   .smooth = FALSE,
                   .x_lab = "Year",
                   .y_lab = "GDP")+
  theme_apa_up+
  guides(color = guide_legend(title = "Autonomous Community"))+
  labs(title = "Figure 7",
       subtitle = "GDP per Autonomous Community")




#### Production


v8_production <-data |> 
  filter(year >2017 & year <2023 ) |> 
  plot_time_series(year, production_agg, 
                   .facet_scales = "free", 
                   .facet_collapse =FALSE,
                   .smooth_alpha = c(0.5),
                   .facet_ncol = 3,
                   .interactive = FALSE,
                   .smooth = FALSE,
                   .x_lab = "Year",
                   .y_lab = "Production Aggregation")+
  theme_apa_up+
  scale_y_continuous(labels = label_number(scale = 1e-6))+
  labs(title = "Figure 8",
       subtitle = "Time Series Production Aggregation")


### Seasonality


#### Visualisation


##### Equivalent units by Autonomous Community


season_ac_func <- function(ac_sub){
  
  data |>
    drop_na() |> 
    filter(AC_code %in% ac_sub) |> 
    group_by(AC, date) |> 
    mutate(sum = sum(e_u)) |> 
    ungroup() |> 
    group_by(AC) |> 
    plot_seasonal_diagnostics(date, sum,
                              .feature_set = c("month.lbl", "year"),
                              .interactive = FALSE,
                              .geom = "boxplot",
                              .title = "Seasonality Diagnostics by Autonomous Community",
                              .y_lab = "Equivalent Units Sold (* million)")+
    scale_y_continuous(labels = label_number(scale = 1e-6))+
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

sub_1 <- c(1,4,7)
sub_2 <- c(8,9,10)
sub_3 <- c(11,12,16)
ac_sub <- list(data$AC_code, sub_1, sub_2, sub_3)

x <- list()

for (i in seq_along(ac_sub)) {
  x[[i]] <- season_ac_func(ac_sub[[i]])
}



plot_grid(plotlist = x[2])
plot_grid(plotlist = x[3])
plot_grid(plotlist = x[4])


##### Equivalent units by product category



unique_cat_prod <- unique(data$cat_prod)

# Create the first list with the first 5 distinct cat_prod values
list_cat_prod_1_5 <- unique_cat_prod[1:4]
list_cat_prod_6_10 <- unique_cat_prod[5:8]
list_cat_prod_11_15 <- unique_cat_prod[9:11]


# Creating a function to loop over seasonality plot with different paarameters
season_prod_func <- function(cat_prod_select, feature_set, title, subtitle, x_lab, y_lab){
  
  
  data |> 
    drop_na(cat_prod) |> 
    filter(cat_prod %in% cat_prod_select) |> 
    group_by(cat_prod, date) |> 
    mutate(sum = sum(e_u)) |> 
    ungroup() |> 
    plot_seasonal_diagnostics(date, sum,
                              .feature_set = feature_set,
                              .facet_vars = product_categories,
                              .interactive = FALSE,
                              .geom = "boxplot",
                              .x_lab = x_lab,
                              .y_lab = y_lab,)+
    scale_y_continuous(labels = label_number(scale = 1e-6))+
    theme_apa_up+
    labs(title = title,
         subtitle = subtitle,
         caption = NULL )+
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  
}

#Creating a list of the subsets of product categories to loop over
cat_prod_select <- list(list_cat_prod_1_5, list_cat_prod_6_10, list_cat_prod_11_15, list_cat_prod_1_5, list_cat_prod_6_10, list_cat_prod_11_15)

# Creating vectors with parameters for the seasonality plot
feature_set <- c("year", "year", "year", "month.lbl", "month.lbl",  "month.lbl" )
title <- c("Annex B", "", "", "Annex A", "", "")
subtitle <- c("Seasonality Diagnostics per Product Category (year)", "", "", "Seasonality Diagnostics per Product Category (month)", "", "")
x_lab <- c("year", "year", "year", "month", "month", "month")
y_lab <- c("", "Equivalent Units Sold (* 1000)", "", "", "Equivalent Units Sold (* 1000)", "")

x <- list()

for (i in seq_along(feature_set)) {
  x[[i]] <- season_prod_func(cat_prod_select[[i]], feature_set[i], title[i],subtitle[i], x_lab[i], y_lab[i])
}

v9_season_year<- plot_grid(plotlist = x[1:3], nrow = 3,  rel_heights = c(1.2, 1.2, 1.2))
v10_season_month <-plot_grid(plotlist = x[4:6], nrow = 3, rel_heights = c(1.2, 1.2, 1.2))




### ACF and PACF diagnostics


data|> 
plot_acf_diagnostics(.date_var= date,
  .value = e_u) 

sub_1 <- c(1,4,7,8,9)
sub_2 <- c(10,11,12,16)

data |> 
  filter(AC_code %in% sub_1) |> 
  group_by(AC) |> 
  plot_acf_diagnostics(.date_var= date,
  .value = e_u)

data |> 
  filter(AC_code %in% sub_2) |> 
  group_by(AC) |> 
  plot_acf_diagnostics(.date_var= date,
  .value = e_u)

a1_ACF <- data|> 
  filter(cat_prod %in% list_cat_prod_1_5) |> 
  drop_na(cat_prod) |> 
   group_by(product_categories) |> 
  plot_acf_diagnostics(.date_var= date,
                       .value = e_u,
                       .interactive = FALSE,
                       .lags = 24,
                       .title = "",
                       .x_lab = "") +
  theme_apa_up+
  theme(plot.title = element_blank(),  
        axis.title.x = element_blank())

a2_ACF <- data |> 
  filter(cat_prod %in% list_cat_prod_6_10) |> 
   group_by(product_categories) |> 
  plot_acf_diagnostics(.date_var= date,
                       .value = e_u,
                       .interactive = FALSE,
                       .lags = 24,
                       .title = "",
                       .x_lab = "")+
  theme_apa_up

a3_ACF <- data |> 
  filter(cat_prod %in% list_cat_prod_11_15) |> 
   group_by(product_categories) |> 
  plot_acf_diagnostics(.date_var= date,
                       .value = e_u,
                       .interactive = FALSE,
                       .lags = 24,
                       .title = "")+
  theme_apa_up

acf_plot<-a1_ACF+a2_ACF+a3_ACF+ plot_layout(nrow = 3) +
  plot_annotation(
  title = "Annex C",
  subtitle = "ACF and PACF Diagnostics")&
  theme_apa_up


