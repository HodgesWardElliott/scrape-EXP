

library(readxl)
library(tidyverse)

fils <- dir("Raw xls output")

out_list <- list()
for(i in 1:length(fils)){
  # i<-1
  cat(i)
  dr <- "/Users/timkiely/Dropbox (hodgeswardelliott)/Data Science/Tim_Kiely/Hotel Reviews/scrape-expedia/Raw xls output/"
  xls <- readxl::read_excel(paste0(dr,fils[i]))
  out_list[[i]] <- xls
  
}

all_hotels <- 
  out_list %>% 
  bind_rows()

write_csv(all_hotels, 'data/EXP-hotels.csv')