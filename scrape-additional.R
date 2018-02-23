
library(rvest)
library(httr)
library(tidyverse)
library(parallel)
library(stringr)

if(!dir.exists("raw_html")){
  dir.create("raw_html")
}

all_hotels <- suppressWarnings(suppressMessages(read_csv('data/EXP-hotels.csv')))

extract_pattern <- 
  paste("https://www.expedia.*.chkin=[0-9]+[/][0-9]+[/][0-9]+&chkout=[0-9]+[/][0-9]+[/][0-9]+"
                          , "https://www.expedia.*.chkin=.*.&chkout=.*."
                          , sep = "|")
replace_pattern <- "chkin=.*.&chkout=.*."

all_hotels <- 
  all_hotels %>% 
  mutate(check_in_date = format(Sys.Date()+10, format = "%d/%m/%Y")
         , check_out_date = format(Sys.Date()+20, format = "%d/%m/%Y")
         , modified_link = str_extract(`Source url`, extract_pattern)
         , modified_link = str_replace_all(modified_link, replace_pattern, "chkin=%s&chkout=%s")
         , todays_link = sprintf(modified_link, check_in_date ,check_out_date)
         ) 

all_links <- all_hotels$`todays_link`

if(file.exists("already_downloaded.csv")){
  already_downloaded <- suppressMessages(read_csv("already_downloaded.csv"))
} else {
  already_downloaded <- data_frame("link"=NA)
}


not_yet_downloaded <- all_links[!basename(all_links) %in% already_downloaded$link]
not_yet_downloaded <- not_yet_downloaded[1:10]

out_list <- list()
for(ii in 1:length(not_yet_downloaded)){
  # ii <- 1
  message("#=======> ",ii," of ",length(not_yet_downloaded))
  link <- not_yet_downloaded[ii]
  successcode <- NA
  res <- httr::GET(link)
  successcode <- res$status_code
  counterlimit <- 0
  while(successcode!=200 & counterlimit <= 5){
    secs <- base::sample(1:8, 1, replace = T)
    message("didn't work, waiting ",secs," seconds and trying again")
    Sys.sleep(secs)
    res <- httr::GET(link)
    successcode <- res$status_code
    counterlimit <- counterlimit+1
  }
  
  if(counterlimit>5){
    next
  } else {
    raw_html <- read_html(res)
    out_list[[ii]] <- raw_html
    if(!file.exists("already_downloaded.csv")){
      write_csv(data_frame(link), "already_downloaded.csv", append = F)
    } else {
        write_csv(data_frame(link), "already_downloaded.csv", append = T)
      }
  }
  
  
  
  write_rds(out_list, "raw_html/all_xml.rds")
}

# file.remove("raw_html/all_xml.rds")
# file.remove("already_downloaded.csv")

out_list %>% map(function(x) html_text(html_nodes(x,"#hotel-amenities"))) %>% map(~substr(.x,1,30)) 



