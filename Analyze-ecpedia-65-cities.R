
library(tidyverse)
source("~/toClip.R")

all_hotels <- read_csv('data/EXP-All-hotels.csv') %>% mutate(UID = 1:n())


# cleanse -----------------------------------------------------------------
hotel_data <-
  all_hotels %>% 
  mutate(`Total number of rooms` = as.numeric(`Total number of rooms`)
  ) #%>% glimpse()



# Create city rank --------------------------------------------------------
glimpse(hotel_data)

range01 <- function(x){(x-min(x))/(max(x)-min(x))}

hotels_ranked <- 
  hotel_data %>% 
  group_by(City_name) %>% 
  mutate_at(vars(`Room cleanliness`:`Hotel condition`,`Count of reviews`), function(x) ifelse(is.na(x),1,x)) %>% 
  mutate_at(vars(`Room cleanliness`:`Hotel condition`,`Count of reviews`), function(x) ifelse(x==0,1,x)) %>% 
  mutate(`Scaled Count of reviews` = range01(`Count of reviews`)*5) %>% 
  ungroup() %>% 
  rowwise() %>% 
  mutate(Avergae_score = mean(c(`Hotel condition`,`Room comfort`
                                ,`Service & Staff`,`Room cleanliness`
                                ,`Scaled Count of reviews`
                                , `Stars out of 5`
  ), na.rm = T)) %>%
  ungroup() %>% 
  group_by(City_name) %>% 
  arrange(desc(Avergae_score)) %>% 
  mutate(City_rank = row_number()) %>% 
  ungroup()

# geo-coding locations ----------------------------------------------------
library(googleway)
# View quota: https://console.developers.google.com/apis/dashboard?project=pure-phalanx-133123&duration=PT1H
my_api_key <- "AIzaSyD3GKOiPLyGs_tvF6kgltm4kg66jCGfkBo"
set_key(my_api_key)

with_addresses <- 
  hotels_ranked %>% 
  filter(!is.na(Address)) %>% 
  mutate(full_address = paste0(with_addresses$Address, ", ",with_addresses$City_name))


if(file.exists("data/geocoded_addresses.csv")){
  already_geocoded <- suppressMessages(read_csv("data/geocoded_addresses.csv"))
} else {
  already_geocoded <- tibble()
}

yet_to_geocode <- anti_join(with_addresses, already_geocoded, by = "UID")

for(i in 1:nrow(yet_to_geocode)){
  message(i," of ",nrow(yet_to_geocode))
  # i <- 1
  the_row <- yet_to_geocode[i,]
  the_address <- as.character(the_row$full_address)
  status <- FALSE
  try_count <- 0
  while(status!="OK"&try_count<5){
    message("Geocodeing ",the_address)
    coded <- google_geocode(the_address, simplify = F)
    coded_out <- jsonlite::fromJSON(coded, simplifyVector = F)
    status <- coded_out$status
    try_count <- try_count+1
  }
  if(try_count<5){
    message("     ...successful")
    coded_data <- coded_out$results[[1]]
    coded_data$address_components <- NULL
    
    the_row$formatted_address <- coded_data$formatted_address
    the_row$lat <- coded_data$geometry$location$lat
    the_row$lon <- coded_data$geometry$location$lng
    the_row$place_id <- coded_data$place_id
    
    geocoded_frame <- the_row
    
    if(!file.exists('data/geocoded_addresses.csv')){
      write_csv(geocoded_frame, 'data/geocoded_addresses.csv', append = F)
    } else {
      write_csv(geocoded_frame, 'data/geocoded_addresses.csv', append = T)
    }
  } else {
    message("     ...couldn't geocode")
    message("     ...with status: ", status)
    
    coded_data <- data.frame(NA)
    the_row$formatted_address <- NA
    the_row$lat <- NA
    the_row$lon <- NA
    the_row$place_id <- NA
    
    geocoded_frame <- the_row
    
    if(!file.exists('data/geocoded_addresses.csv')){
      write_csv(geocoded_frame, 'data/geocoded_addresses.csv', append = F)
    } else {
      write_csv(geocoded_frame, 'data/geocoded_addresses.csv', append = T)
    }
  }
  
  
}

# file.remove("data/geocoded_addresses.csv")



