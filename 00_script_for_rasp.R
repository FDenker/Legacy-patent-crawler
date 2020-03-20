#### script for raspberry pi###


#rstudioapi::jobRunScript("C:/Users/Frederic Denker/OneDrive - Zeppelin-University gGmbH/Dokumente/Semester 7/clean_patent_project/Patent_project/01_uspto_crawler_full_script.R", importEnv = TRUE)

start <- 44
end <- 44
##For which of the groups do want to run this##
for (i in start:end) {
  #source("01_uspto_crawler_full_script.R")
  group_number <- i
  
  start_line <- (1+(group_number-1)*500)
  end_line <- ((group_number*500))
  print(start_line)
  print(end_line)
  system.time({ data <- crawl_of_list_function(linkmaker(start_line,end_line))})
  saveRDS(data, file = paste0("/home/pi/documents/data_group_",group_number, ".rds"))
  print(paste0("Saving group number: ",group_number, " successfull"))
}

#rstudioapi::jobRunScript("C:/Users/frede/OneDrive - Zeppelin-University gGmbH/Dokumente/Semester 7/us_ger_patent_scraping/00_script_for_rasp.R", importEnv = TRUE)
