library(tidyverse)
theme_set(theme_bw())
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(rgeos)



#' plotOnWorldMap
#'
#' Draw a World map which each countrie's color(fill) showing number of selected type(Daily Cases, Daily Deaths, All Deaths, All Cases)
#' @param date, a string on format 'year-month-day'
#' @param type, a string which can be 'Confirmed', 'Deaths', 'DailyConfirmed', 'DailyDeaths'
#' @export
plotOnWorldMap <- function(date, type){
  main_df <- getData()

  df <- main_df
  df %>%
    filter(Date == as_date(date)) -> df

  world <- ne_countries(scale = "medium", returnclass = "sf")
  world %>%
    mutate(Country = name) %>%
    group_by(Country) %>%
    mutate(Country = case_when(
      Country == 'United States' ~ 'US',
      TRUE ~ Country
    )) -> world

  new_df <- left_join(world, df, by = 'Country')

  new_df %>%
    replace_na(list(DailyConfirmed = 0, DailyDeaths = 0,
                    Confirmed = 0, Deaths = 0)) -> new_df

  ggplot(data = new_df) +
    geom_sf(aes_string(fill = type)) +
    scale_fill_viridis_c(option = "plasma", trans = "sqrt")

}
