

library(readxl)
library(tidyverse)

fils <- dir("Expedia 64 Cities Raw Xls")

out_list <- list()
for(i in 1:length(fils)){
  # i<-1
  cat(i)
  dr <- "Expedia 64 Cities Raw Xls"
  xls <- readxl::read_excel(paste(dr,fils[i], sep = "/"))
  out_list[[i]] <- xls
  
}

all_hotels <- 
  out_list %>% 
  bind_rows()

write_csv(all_hotels, 'data/EXP-All-hotels.csv')