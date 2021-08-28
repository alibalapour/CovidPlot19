library(tidyverse)
library(lubridate)


#' plotTimeSeries
#'
#' Draw a time series line plot based on number of type(Daily Cases, Daily Deaths, All Deaths, All Cases)
#' @param startDate, a string on format 'year-month-day', shows start date
#' @param endDate, a string on format 'year-month-day', shows end date. endDate must be greater than startDate
#' @param country, a string of selected country
#' @param type, a string which can be 'Cases', 'Deaths', 'DailyCases', 'DailyDeaths'
#' @import tidyverse
#' @import lubridate
#' @import ggplot2
#' @import dplyr
#' @import plotly
#' @import hrbrthemes
#' @import orca
#' @importMethodsFrom dplyr select rename mutate case_when group_by summarise arrange lag filter left_join
#' @importMethodsFrom ggplot2 ggplot aes geom_line aes_string labs
#' @export
plotTimeSeries <- function(startDate, endDate, country, type, static=F){

  df <- getData()

  df$Date = as.Date(df$Date)

  df %>%
    filter(Country == country,
           Date >= startDate,
           Date <= endDate) -> df

  color <- case_when(
    type == 'Cases' ~ '#69b3a2',
    type == 'Deaths' ~ '#30576B',
    type == 'DailyCases' ~ '#05AFF2',
    type == 'DailyDeaths' ~ '#BF2604'
  )

  description <- case_when(
    type == 'Cases' ~ 'Cases',
    type == 'Deaths' ~ 'Deaths',
    type == 'DailyCases' ~ 'Daily Cases',
    type == 'DailyDeaths' ~ 'Daily Deaths'
  )


  # Usual area chart
  p <- df %>%
    ggplot( aes(x=Date)) +
    geom_area(aes_string(y = type), fill=color, alpha=0.5) +
    geom_line(aes_string(y = type), color=color) +
    labs(y = description, x = 'Date', title = paste(
      description, 'in', country, 'between', startDate, 'to', endDate
      )
    ) +
    theme_ipsum()

  # Turn it interactive with ggplotly
  if(static){
    p
  }
  else{
    ggplotly(p)
  }


}
