


library(tidyverse)
theme_set(theme_bw())
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(rgeos)


plotOnWorldMap <- function(date, type){
  main_df <- getData()

  df <- main_df
  df %>%
    filter(Date == '2020-10-15') -> df

  world <- ne_countries(scale = "medium", returnclass = "sf")
  world %>%
    mutate(Country = name) %>%
    group_by(Country) %>%
    mutate(Country = case_when(
      Country == 'United States of America' ~ 'US',
      TRUE ~ Country
    )) -> world



  new_df <- merge(world, df, by = 'Country')


  ggplot(data = new_df) +
    geom_sf(aes(fill = DailyConfirmed)) +
    scale_fill_viridis_c(option = "plasma", trans = "sqrt")

}
