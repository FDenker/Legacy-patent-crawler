require(curl)
require(rvest)

get_aktenzeichen_pat_id <- function(aktenzeichen){
  aktenzeichen_bereinigt <- gsub("\\ ","",aktenzeichen)
  aktenzeichen_bereinigt <- gsub("\\..*","",aktenzeichen_bereinigt)
  aktenzeichen_bereinigt <- gsub("[PG]","",aktenzeichen_bereinigt)
    if (nchar(aktenzeichen_bereinigt)<12){
      for (a in 1:(12-nchar(aktenzeichen_bereinigt))){
        aktenzeichen_bereinigt <- paste0("0",aktenzeichen_bereinigt)
      }
    } 
  aktenzeichen_bereinigt <- paste0("DE",aktenzeichen_bereinigt)
  #print(Patent_number)
  return(aktenzeichen_bereinigt)
  
} 

#print(get_aktenzeichen_pat_id(testdata$Aktenzeichen[100]))

#closeAllConnections()
#url <- paste0("https://register.dpma.de/DPMAregister/pat/register?AKZ=",
#              aktenzeichen_bereinigt,
#              "&CURSOR=1")
#print(aktenzeichen_bereinigt)
#
#tryCatch({html <- read_html(curl(url,handle = curl::new_handle("useragent" = "Mozilla/5.0")))
#char <- html %>% html_text() %>% as.character() %>% gsub(x= .,"\n", "BREAK")}
#,error = function(c) {
#  print("Error message")
#  print(url)
#  Sys.sleep(10)
#  html <- read_html(curl(url, handle = curl::new_handle("useragent" = "Mozilla/5.0")))
#  char <- html %>% html_text() %>% as.character() %>% gsub(x= .,"\n", "BREAK")
#},
#warning = function(c) "warning")
#
#closeAllConnections()