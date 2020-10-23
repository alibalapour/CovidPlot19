library(RCurl)
library(lubridate)
library(progress)
library(tidyverse)
library(tidyr)


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
    try(df$Date <- as_date(df$Date))

    mainDF <<- rbind(mainDF, df)
    pb$tick()
  })

  mainDF %>%
    replace_na(list(Deaths = 0, Confirmed = 0)) -> mainDF

  return(mainDF)
}
