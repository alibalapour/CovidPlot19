library(tidyverse)
theme_set(theme_bw())
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(rgeos)
globalVariables(c('name', 'df'))



#' plotOnWorldMap
#'
#' Draw a World map which each countrie's color(fill) showing number of selected type(Daily Cases, Daily Deaths, All Deaths, All Cases)
#' @param date, a string on format 'year-month-day'
#' @param type, a string which can be 'Cases', 'Deaths', 'DailyCases', 'DailyDeaths'
#' @import tidyverse
#' @import sf
#' @import rnaturalearth
#' @import rnaturalearthdata
#' @import rgeos
#' @import ggplot2
#' @import dplyr
#' @importMethodsFrom dplyr select rename mutate case_when group_by summarise arrange lag filter left_join
#' @importMethodsFrom ggplot2 ggplot geom_sf aes_string scale_fill_viridis_c
#' @export
plotOnWorldMap <- function(date, type){

  # Getting data from repo and creating required data-frame
  df <- getData()

  # Selecting data of given date from data-from
  df %>%
    filter(Date == as_date(date)) -> df

  # ne_countries() returns world country polygons at a specified scale
  world <- ne_countries(scale = "medium", returnclass = "sf")

  # This part of code, create a data-frame based on countries that include information about map of countries
  world %>%
    mutate(Country = name) %>%
    group_by(Country) %>%
    mutate(Country = case_when(
      Country == 'United States' ~ 'US',
      TRUE ~ Country
    )) -> world

  # Left joining the world and df data-frames to prepare them to be plotted on world map
  new_df <- left_join(world, df, by = 'Country')

  # Removing NAs in data-frame
  new_df %>%
    replace_na(list(DailyConfirmed = 0, DailyDeaths = 0,
                    Confirmed = 0, Deaths = 0)) -> new_df

  # Ploting stage
  ggplot(data = new_df) +
    geom_sf(aes_string(fill = type)) +
    scale_fill_viridis_c(option = "plasma", trans = "sqrt")

}
