require(dplyr,quietly = TRUE, warn.conflicts = FALSE)
require(xml2,quietly = TRUE, warn.conflicts = FALSE)
require(rvest,quietly = TRUE, warn.conflicts = FALSE)
require(stringr,quietly = TRUE, warn.conflicts = FALSE)
require(data.table,quietly = TRUE, warn.conflicts = FALSE)
require(dplyr,quietly = TRUE, warn.conflicts = FALSE)
require(rlang,quietly = TRUE, warn.conflicts = FALSE)
require(assertr,quietly = TRUE, warn.conflicts = FALSE)
require(httr,quietly = TRUE, warn.conflicts = FALSE)
require(curl,quietly = TRUE, warn.conflicts = FALSE)

#do_call 
#source

#setwd("C:/Users/Frederic Denker/OneDrive - Zeppelin-University gGmbH/Dokumente/Semester 7/ASR/Patentprojekt/Downloads_selenium")

#install.packages("devtools")
#library(devtools)
#install.packages("assertr")
#ip address 26.02 212.62.220.110 @ZU
#ip address 01.03 37.201.6.15 @Home

#Whole polulation: 845675
#Sample size chosen: 458

#vector_random_sample <- sample (c(1:845674), size= 84567,replace =F)
#http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&u=%2Fnetahtml%2FPTO%2Fsearch-adv.htm&r=49&p=1&f=G&l=50&d=PTXT&S1=DE.FREF.&OS=FREF/DE&RS=FREF/DE
linkmaker <- function(starting_point,ending_point){
  vector_of_links <- c("")
  vector_of_links <- vector_of_links[-1]
  vector_of_numbers<- readRDS("vector_random_sample.rds")
  for(i in starting_point:ending_point){
    link <- paste0("http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&u=%2Fnetahtml%2FPTO%2Fsearch-adv.htm&r=",
                   vector_of_numbers[i],
                   "&p=1&f=G&l=50&d=PTXT&S1=DE.FREF.&OS=FREF/DE&RS=FREF/DE") 
    vector_of_links <- c(vector_of_links, link)
  }
  return(vector_of_links)
}


crawl_function <- function(link_to_crawl){
  patentx <- as_string(link_to_crawl)
  closeAllConnections()
  tryCatch({pahtml <- read_html(curl(patentx,handle = curl::new_handle("useragent" = "Mozilla/5.0")))}
           ,error = function(c) {
             Sys.sleep(10)
             pahtml <- read_html(curl(patentx, handle = curl::new_handle("useragent" = "Mozilla/5.0")))
             print("Error message")
           },
           warning = function(c) "warning")
  #system.time({pahtml <- patentx %>% read_html() })
  char <- pahtml %>% html_text() %>% as.character() %>% gsub(x= .,"\n", "BREAK")
  
  dirtypat <- str_match(char, "Foreign Patent Documents(.*?)Other References") %>% .[,2] %>%
    strsplit(x = ., split = "BREAK") %>% 
    unlist %>%
    .[which(. != "" & . != "  ")]
  dirtypat2 <- str_match(char, "United States Patent: (.*?)BREAK") %>% .[,2] 

  foreign_priority_filing <-  str_match(char, "Foreign Application Priority Data(.*?)Current U.S. Class:") %>% .[,2] %>% 
    strsplit(x = ., split = "BREAK") %>% .[[1]] %>% 
    .[which(. != "" & . != "  ")]
  if(!is_empty(dirtypat)){
    datapat <- data.frame("Link" = patentx,
                          "Int_pat_id" = dirtypat[seq(1,(length(dirtypat)-2),3)],
                          "Int_pat_date" = dirtypat[seq(2,(length(dirtypat)-1),3)],
                          "Int_pat_country_code" = dirtypat[seq(3,length(dirtypat),3)],
                          "Uspat_id" = dirtypat2[])
  } else { 
    #patent format is different -> we try Primary Examiner
    patent_format_2 <- str_match(char, "Foreign Patent Documents(.*?)Primary Examiner") %>% .[,2] %>%
      strsplit(x = ., split = "BREAK") %>% 
      unlist %>%
      .[which(. != "" & . != "  ")]
    
    if(!is_empty(patent_format_2)){
      datapat <- data.frame("Link" = patentx,
                            "Int_pat_id" = patent_format_2[seq(1,(length(patent_format_2)-2),3)],
                            "Int_pat_date" = patent_format_2[seq(2,(length(patent_format_2)-1),3)],
                            "Int_pat_country_code" = patent_format_2[seq(3,length(patent_format_2),3)],
                            "Uspat_id" = dirtypat2[])
    } else  {
      print("ERROR")
      datapat <- data.frame("Link" = patentx,
                            "Int_pat_id" = "ERROR",
                            "Int_pat_date" = "ERROR",
                            "Int_pat_country_code" = "ERROR",
                            "Uspat_id" = dirtypat2[])
    }
  }
  
  
  return(datapat)
}

crawl_of_list_function <- function(crawl_list_to_go_through){
  
  crawled_data=data.table(Link=factor(), Int_pat_id=factor(), Int_pat_date=factor(), Int_pat_country_code=factor(), Uspat_id=numeric())
  for(i in 1:length(crawl_list_to_go_through)){
    print(i)
    link <- crawl_list_to_go_through[i]
    print(link)
    print(system.time({data_to_add <- crawl_function(link)}))
    #to avoid ban 
    
    crawled_data <- rbind(crawled_data, data_to_add)
  }
  return(crawled_data)
}


group <- 39
print(group)
#rstudioapi::jobRunScript("C:/Users/Frederic Denker/OneDrive - Zeppelin-University gGmbH/Dokumente/Semester 7/clean_patent_project/Patent_project/01_uspto_crawler_full_script.R", importEnv = TRUE)

start <- (1+(group-1)*500)
end <- ((group*500))
print(start)
print(end)
system.time({ data <- crawl_of_list_function(linkmaker(start,end))})


saveRDS(data, file = paste0("data/uspto_download_files/data_group_",group, ".rds"))

print("success")

#data3 <- readRDS("data/uspto_download_files/data_group_3.rds")
#data <- readRDS("data/uspto_download_files/data_group_1.rds")

