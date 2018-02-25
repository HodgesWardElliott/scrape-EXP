
if(!"pacman"%in%installed.packages())install.packages("pacman")
pacman::p_load(rvest, httr, tidyverse, parallel, stringr)

fils <- dir("raw_html")

input_html <- read_html(paste0("raw_html/",fils[1]))
