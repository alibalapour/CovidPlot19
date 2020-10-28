library(tidyverse)
theme_set(theme_bw())
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(rgeos)
globalVariables(c('name'))




#' plotOnWorldMap
#'
#' Draw a World map which each countrie's color(fill) showing number of selected type(Daily Cases, Daily Deaths, All Deaths, All Cases)
#' @param date, a string on format 'year-month-day'
#' @param type, a string which can be 'Confirmed', 'Deaths', 'DailyConfirmed', 'DailyDeaths'
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

  # error handling
  tryCatch(date, stop('Please Enter a date in the function parameters!'))
  tryCatch(type, stop('Please Enter a type in the parameters!'))

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
