
if(!"pacman"%in%installed.packages())install.packages("pacman")
pacman::p_load(rvest, httr, tidyverse, parallel, stringr)

fils <- dir("raw_html")

input_html <- read_html(paste0("raw_html/",fils[1]))

hotel_name <- 
  input_html %>% 
  html_nodes("#hotel-name") %>% 
  html_text()

title_stars <- 
  input_html %>% 
  html_node(".value-title") %>% 
  html_attr("title") %>% 
  as.numeric()

address_street <- 
  input_html %>% 
  html_node(".street-address") %>% 
  html_text()
  
address_city <- 
  input_html %>% 
  html_node(".city") %>% 
  html_text()

address_province <- 
  input_html %>% 
  html_node(".province") %>% 
  html_text()

hotel_descr_text <- 
  input_html %>% 
  html_node(".hotel-description") %>% 
  html_text()

hotel_amenities_text <- 

  html_node("#hotel-amenities") %>% 
  html_text()


allxl <- read_csv("data/EXP-hotels.csv")
S <- html_session(allxl$`Source url`[1])

input_html %>% 
  html_node("hotel-map") %>% 
  html_text()

# see: https://stackoverflow.com/questions/29185501/r-language-how-to-make-a-click-on-webpage-using-rvest-or-rcurl


res <- POST("http://www.tradingeconomics.com/",
            encode="form",
            user_agent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.50 Safari/537.36"),
            add_headers(`Referer`="http://www.tradingeconomics.com/",
                        `X-MicrosoftAjax`="Delta=true"),
            body=list(
              `ctl00$AjaxScriptManager1$ScriptManager1`="ctl00$ContentPlaceHolder1$defaultUC1$CurrencyMatrixAllCountries1$UpdatePanel1|ctl00$ContentPlaceHolder1$defaultUC1$CurrencyMatrixAllCountries1$LinkButton1",
              `__EVENTTARGET`="ctl00$ContentPlaceHolder1$defaultUC1$CurrencyMatrixAllCountries1$LinkButton1",
              `srch-term`="",
              `ctl00$ContentPlaceHolder1$defaultUC1$CurrencyMatrixAllCountries1$GridView1$ctl01$DropDownListCountry`="top",
              `ctl00$ContentPlaceHolder1$defaultUC1$CurrencyMatrixAllCountries1$ParameterContinent`="",
              `__ASYNCPOST`="false"))

res <- GET("https://maps.googleapis.com/maps/api/js?v=3&callback=uitk.map.initPlugin&client=gme-expedia&language=en&sensor=false&channel=expedia-HotelInformation",
            encode = "form",
            user_agent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.167 Safari/537.36"),
            add_headers(`Referer`="https://www.expedia.co.uk/Atlanta-Hotels-Super-8-College-ParkAtlanta-Airport-West.h20056.Hotel-Information?chkin=22/2/2018&chkout=23/2/2018&rm1=a2&regionId=178232&hwrqCacheKey=ff1398d3-5bce-44a3-a946-6c61620e42dfHWRQ1519289108594&vip=false&c=ff8b02a1-53bd-4ef7-9777-890a9d516fbd&&exp_dp=46.03&exp_ts=1519289107760&exp_curr=GBP&swpToggleOn=false&exp_pg=HSR")
            )

read_html(res) %>% 
  html_text() %>% 
  str_extract_all("National")



sessh_html <- S %>% 
  jump_to("#section-reviews") %>% 
  read_html()
sessh_html %>% 
  html_attrs() %>% 
  html_text()



