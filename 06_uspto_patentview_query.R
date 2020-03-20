### pull additional data for the US patents from patentsview###

library(patentsview)
library(leaflet)
library(htmltools)
library(dplyr)
library(tidyr)
library(patentsview)
library(openxlsx)
require(data.table)
#https://ropensci.org/blog/2017/09/19/patentsview/


full_database <- readRDS(paste0("data/uspto_download_files/data_group_",1,".rds"))

for (i in 2:30){
  database <- readRDS(paste0("data/uspto_download_files/data_group_",i,".rds"))
  full_database <- rbind(full_database, database)
}

#full_database$Uspat_id




fields <- c(c("patent_number", "patent_year","app_date","app_country","assignee_country"))
full_uspto_query_data <- setNames(data.table(matrix(nrow = 0, ncol = 4)),
                                  c("patent_number", "patent_year", "assignees",
                                    "applications"))  
unique_uspto_numbers <- unique(full_database$Uspat_id)
saveRDS(unique_uspto_numbers, file= "uniqueusptonumbers.rds")
for (i in 11:20){
print(paste0(((i*50)-49),"-",(50*i)))  

  
query <- with_qfuns( # with_qfuns is basically just: with(qry_funs, ...)
  and(contains(patent_number = as.character(unique_uspto_numbers[((i*50)-49):(50*i)]))
  )
)

# Send HTTP request to API's server:
print(system.time({pv_res<- search_pv(query = query, fields = fields,all_pages = TRUE)} )) 

relevant_uspto_data_from_query <- pv_res %>% .[[1]] %>% .[[1]]

full_uspto_query_data <- rbind(full_uspto_query_data,relevant_uspto_data_from_query )
}


#test_frame <- pv_res %>% .[[1]] %>% .[[1]] %>% unnest(assignees) %>% unnest(applications)

View(test_frame)
testi3[,2] <- as.data.frame(sort(unique(all_pat_ger$Uspat_id[1:50])))
testi3 <- as.data.frame(sort(unique(data$patents$patent_number)))
write.xlsx(data$patents$patent_number, "data_uspto.xlsx")


full_join(as.data.frame(unique(all_pat_ger$Uspat_id[1:50])),as.data.frame(unique(data$patents$patent_number)))

View(full_join(data,all_pat_ger[1:50,],by=c("patent_number"="Uspat_id"), keep=T))


# Send HTTP request to API's server:
pv_res <- search_pv(query = query, fields = fields, all_pages = TRUE)
data <-  pv_res$data$patents


data <-  pv_res$data$patents
data[,3] <- pv_res$data$patents %>%  unnest(assignees) %>% 
  select(assignee_id, patent_number,
         assignee_longitude, assignee_latitude)
  

unnest(assignees) %>%
  select(assignee_id, assignee_organization, patent_number,
         assignee_longitude, assignee_latitude)
qry_1 <- '{"_contains":{"patent_number":10579239}}'
pv_res<- search_pv(query = qry_1, fields = fields,all_pages = TRUE)
