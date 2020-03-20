
full_database <- readRDS(paste0("data/uspto_download_files/data_group_",1,".rds"))

for (i in 2:30){
  database <- readRDS(paste0("data/uspto_download_files/data_group_",i,".rds"))
  full_database <- rbind(full_database, database)
}

saveRDS(full_)
all_pat_ger <- full_database  %>% subset(.,is.na(Int_pat_id)) %>% view()

write.table(full_database, file = "full_database.csv", sep = ";")


full_faulty_lines <-  readRDS(paste0("data/depatisnet_files/faulty_lines/faulty_line_group",1,".rds"))
                              
for (i in 2:30){
  database_faulty <- readRDS(paste0("data/depatisnet_files/faulty_lines/faulty_line_group",i,".rds"))
  full_faulty_lines <- rbind(full_faulty_lines, database_faulty)
}

View(full_faulty_lines)


get_aktenzeichen_pat_id <- function(aktenzeichen){
  aktenzeichen <- as.character(aktenzeichen)
  aktenzeichen_bereinigt <- gsub("\\ ","",aktenzeichen)
  aktenzeichen_bereinigt <- gsub("\\.","",aktenzeichen_bereinigt)
  aktenzeichen_bereinigt <- gsub("[PG]","",aktenzeichen_bereinigt)
  closeAllConnections()
  url <- paste0("https://register.dpma.de/DPMAregister/pat/register?AKZ=",
                aktenzeichen_bereinigt,
                "&CURSOR=1")
  
  tryCatch({html <- read_html(curl(url,handle = curl::new_handle("useragent" = "Mozilla/5.0")))
  char <- html %>% html_text() %>% as.character() %>% gsub(x= .,"\n", "BREAK")}
  ,error = function(c) {
    Sys.sleep(10)
    html <- read_html(curl(url, handle = curl::new_handle("useragent" = "Mozilla/5.0")))
    char <- html %>% html_text() %>% as.character() %>% gsub(x= .,"\n", "BREAK")
    print("Error message")
  },
  warning = function(c) "warning")
  
  closeAllConnections()
  
  Patent_number <- str_match(char, 'Originaldokument: (.*?);') %>% .[,2]
  print(Patent_number)
  class(Patent_number)
  return(Patent_number)
  
} 