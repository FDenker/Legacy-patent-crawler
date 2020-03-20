#java -Dwebdriver.chrome.driver="/docker/chromedriver.exe" -jar /docker/selenium-server-standalone-4.0.0-alpha-1.jar -port 4440
#devtools::install_github("DavisVaughan/furrr")
#library(furrr)
#library(future)
#library("parallel")
#no_cores <- detectCores() - 1
library(purrr)
library(stringr)
start <- 30
end <-33
##For which of the groups do want to run this##
for (i in start:end) {
  
  source("08_get_patent_id_for_aktenzeichen.R")
  group_number <- i
  print(paste0("Loading group number: ",group_number, " | ",start,"-", end))
  source("07_dpmaregister_crawl.R")
  source("02_cleanup_and_prep_for_selenium.R")
    
  ## Running the clean_data function of the 02_script and then creating the vector of strings for the query##
  data_for_query <- create_dpmaregister_string(clean_data(group_number))
  ## running the depaisnetcrawler on this vector of strings
  #remDr$open()
  print(length(data_for_query))
  system.time({ data_dpma_register  <- full_run_dpma(1,length(data_for_query),data_for_query)})
  print("querying the patent ids") 
  data_dpma_register$patent_id <- map_chr(.x=data_dpma_register$Aktenzeichen,get_aktenzeichen_pat_id) 

  ## Saving this queried information in an RDS file###
  saveRDS(data_dpma_register, file = paste0("data/dpma_register/data_dpma_register_group_akz_",group_number, ".rds"))
  print(paste0("Loading group number: ",group_number, " successfull"))
}

#rstudioapi::jobRunScript("C:/Users/Frederic Denker/OneDrive - Zeppelin-University gGmbH/Dokumente/Semester 7/clean_patent_project/Patent_project/000_master_script_dpmaregister.R", importEnv = TRUE)

