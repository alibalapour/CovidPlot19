library(tidyverse)
library(lubridate)


#' plotTimeSeries
#'
#' Draw a time series line plot based on number of type(Daily Cases, Daily Deaths, All Deaths, All Cases)
#' @param startDate, a string on format 'year-month-day', shows start date
#' @param endDate, a string on format 'year-month-day', shows end date. endDate must be greater than startDate
#' @param country, a string of selected country
#' @param type, a string which can be 'Confirmed', 'Deaths', 'DailyConfirmed', 'DailyDeaths'
#' @examples
#' plotTimeSeries('2020-9-21', '2020-10-21', 'US', 'DailyConfirmed')
#' @import getData
#' @export
plotTimeSeries <- function(startDate, endDate, country, type){
  df <- getData()

  df %>%
    filter(Country == country,
           Date >= startDate,
           Date <= endDate) -> df

  color <- case_when(
    type == 'Confirmed' ~ '#69b3a2',
    type == 'Deaths' ~ '#30576B',
    type == 'DailyConfirmed' ~ '#05AFF2',
    type == 'DailyDeaths' ~ '#BF2604'
  )

  description <- case_when(
    type == 'Confirmed' ~ 'Deaths',
    type == 'Deaths' ~ 'Confirmed Cases',
    type == 'DailyConfirmed' ~ 'Daily Confirmed Cases',
    type == 'DailyDeaths' ~ 'Daily Deaths'
  )

  df %>%
    ggplot(aes(x = Date)) +
    geom_line(aes_string(y = type), color="#69b3a2") +
    labs(y = description)

}