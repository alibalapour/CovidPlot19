library(RCurl)
library(lubridate)
library(progress)
library(tidyverse)
library(tidyr)
globalVariables(c('Country', 'Confirmed', 'Deaths'))


#' getData
#'
#' Provides a General dataset of daily and Cumulative cases and deaths of covid-19
#' @return a DataFrame grouped by Country and Date has the number of deaths and cases and daily deaths and daily cases
#' @import RCurl
#' @import lubridate
#' @import progress
#' @import tidyverse
#' @import tidyr
#' @import utils
#' @import dplyr
#' @import stringr
#' @importMethodsFrom utils download.file read.csv
#' @importMethodsFrom stringr str_extract
#' @importMethodsFrom dplyr select rename mutate case_when group_by summarise arrange lag
#' @export
getData <- function(){

  mainDF <- data.frame()
  dateInterval <- as.numeric(today() - as_date('2020-01-22') - 1)
  pb <- progress_bar$new(total = dateInterval)
  notImportant <- sapply(1:dateInterval, function(i){
    date <- (as_date("2020-01-22") + days(i))

    day <- day(date)
    day <- ifelse(day < 10, paste('0', day, sep=''), as.character(day))
    month <- month(date)
    month <- ifelse(month < 10, paste('0', month, sep=''), as.character(month))
    date <- paste(month, day, as.character(year(date)),sep = "-")
    date <- paste(date, 'csv', sep = ".")

    path <- paste("data/", date, sep = '')
    if(! file.exists(path)){
      download.file(paste("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/",
                          date, sep = ''),
                    destfile = path, method = "curl", quiet = T,)
    }

    df <- read.csv(path)

    if(nrow(df) != 0){
      countryName <- ''
      dateName <- ''

          selectedCols <- c('Confirmed', 'Deaths')
      for (j in names(df)){
        if(! is.na(str_extract(j, 'Country'))){
          selectedCols <- append(selectedCols, j)
          countryName <- j
        }
        if(! is.na(str_extract(j, 'Update'))){
          selectedCols <- append(selectedCols, j)
          dateName <- j
        }
      }

      df %>%
        select(selectedCols) %>%
        rename('Country' = countryName,
               'Date' = dateName) -> df


      df$Date <- str_extract(date, '[0-9]+-[0-9]+-[0-9]+')

      mainDF <<- rbind(mainDF, df)
    }
    pb$tick()
  })

  df <- mainDF

  df %>%
    mutate(Country = case_when(
      Country == 'Mainland China' ~ 'China',
      TRUE ~ as.character(Country)
    )) -> df

  df$Date <- as_date(df$Date, format = '%m-%d-%Y')
  df %>%
    replace_na(list(Deaths = 0, Confirmed = 0)) -> df

  df %>%group_by(Date, Country) %>%
    summarise(Confirmed = sum(Confirmed), Deaths = sum(Deaths)) %>%
    group_by(Date) %>%
    arrange(Country) %>%
    group_by(Country, Date) %>%
    summarise(Country, Confirmed, Deaths) %>%
    mutate(DailyConfirmed = Confirmed - lag(Confirmed),
           DailyDeaths = Deaths - lag(Deaths)) %>%
    replace_na(list(DailyDeaths = 0, DailyConfirmed = 0)) %>%
    mutate(DailyDeaths = case_when(
      DailyDeaths < 0 ~ 0,
      TRUE ~ DailyDeaths
    ), DailyConfirmed = case_when(
      DailyConfirmed < 0 ~ 0,
      TRUE ~ DailyConfirmed
    )) -> df


  return(df)
}

