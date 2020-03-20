#java -Dwebdriver.chrome.driver="/docker/chromedriver.exe" -jar /docker/selenium-server-standalone-4.0.0-alpha-1.jar -port 4440


###Run selenium###


start <- 3
end <- 10
##For which of the groups do want to run this##
for (i in start:end) {
source("02_cleanup_and_prep_for_selenium.R")
source("03_depatisnet_crawl.R")


group_number <- i
print(paste0("Loading group number: ",group_number, " | ",start,"/", end))

## Running the clean_data function of the 02_script and then creating the vector of strings for the query##
data_for_query <- create_depatisnet_string(clean_data(group_number))
## running the depaisnetcrawler on this vector of strings
#remDr$open()
system.time({ data_depatisnet  <- full_run(1,length(data_for_query),data_for_query)})

## Saving this queried information in an RDS file###

saveRDS(data_depatisnet, file = paste0("data/depatisnet_files/data_depatisnet_group_",group_number, ".rds"))
print(paste0("Loading group number: ",group_number, " successfull"))
}

#rstudioapi::jobRunScript("C:/Users/Frederic Denker/OneDrive - Zeppelin-University gGmbH/Dokumente/Semester 7/clean_patent_project/Patent_project/00_master_script.R", importEnv = TRUE)


##group 7 or 8 has problem of having A1A2 in the end of one of the ids #plsfix and DEWP also

