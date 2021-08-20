library(RCurl)
library(lubridate)
library(progress)
library(tidyverse)
library(tidyr)
globalVariables(c('Country', 'Cases', 'Deaths'))


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
getData <- function(saveData=F){

  if (saveData){
    dir.create('data/')
  }

  # Create mainDF that is the main data-frame for the covid statistics
  mainDF <- data.frame()

  # The starting date of the data in the reference repo, was January 22
  dateInterval <- as.numeric(today() - as_date('2020-01-22') - 1)

  # pb is for progress bar to show the proportion of the data which is processed
  pb <- progress_bar$new(total = dateInterval)

  # This function downloads the data and create initial dataframe
  notImportant <- sapply(1:dateInterval, function(i){

    # Creating date
    date <- (as_date("2020-01-22") + days(i))
    day <- day(date)
    day <- ifelse(day < 10, paste('0', day, sep=''), as.character(day))
    month <- month(date)
    month <- ifelse(month < 10, paste('0', month, sep=''), as.character(month))
    date <- paste(month, day, as.character(year(date)),sep = "-")
    date <- paste(date, 'csv', sep = ".")

    # url of data repository
    url = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/"

    # Check status of saving data
    if(saveData){
      path <- paste("data/", date, sep = '')
      if(! file.exists(path)){
        download.file(paste(url, date, sep = ''), destfile = path, quiet = T)
      }
      df <- read.csv(path)
    }
    else if(! saveData){
      df <- read.csv(paste(url, date, sep = ''))
    }


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

      # Binding Created df for each day(df) to mainDF
      mainDF <<- rbind(mainDF, df)
    }
    # Tick the progress bar
    pb$tick()
  })

  # Changing name of some countries
  mainDF %>%
    mutate(Country = case_when(
      Country == 'Mainland China' ~ 'China',
      TRUE ~ as.character(Country)
    )) -> mainDF

  names(mainDF)[names(mainDF) == 'Confirmed'] <- 'Cases'

  # Formatting dates
  mainDF$Date <- as_date(mainDF$Date, format = '%m-%d-%Y')

  # Replacing na data with 0
  mainDF %>%
    replace_na(list(Deaths = 0, Cases = 0)) -> mainDF

  # Creating DailyCases and DailyDeaths in the mainDF
  mainDF %>% group_by(Date, Country) %>%
    summarise(Cases = sum(Cases), Deaths = sum(Deaths)) %>%
    group_by(Date) %>%
    arrange(Country) %>%
    group_by(Country, Date) %>%
    summarise(Country, Cases, Deaths) %>%
    mutate(DailyCases = Cases - lag(Cases),
           DailyDeaths = Deaths - lag(Deaths)) %>%
    replace_na(list(DailyDeaths = 0, DailyCases = 0)) %>%
    mutate(DailyDeaths = case_when(
      DailyDeaths < 0 ~ 0,
      TRUE ~ DailyDeaths
    ), DailyCases = case_when(
      DailyCases < 0 ~ 0,
      TRUE ~ DailyCases
    )) -> mainDF


  return(mainDF)
}

