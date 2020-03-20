####merging data####
require(dplyr)
uspto_query_data<- readRDS("data/uspto_query_data/full_uspto_query_data_15_k.rds") %>% unnest(applications)


full_data_uspto_crawler <- readRDS(paste0("data/uspto_download_files/data_group_",1,".rds"))

for (i in 2:30){
  database <- readRDS(paste0("data/uspto_download_files/data_group_",i,".rds"))
  full_data_uspto_crawler <- rbind(full_data_uspto_crawler, database)
}
names(uspto_query_data)
names(full_data_uspto_crawler)

uspto_joined <- left_join(full_data_uspto_crawler,uspto_query_data, by = c("Uspat_id"="patent_number"))
View(uspto_joined)


full_data_dpma_register <- readRDS(paste0("data/dpma_register/data_dpma_register_group_akz_",1,".rds"))

for (i in 2:39){
  print(i)
  database <- readRDS(paste0("data/dpma_register/data_dpma_register_group_akz_",i,".rds"))
  full_data_dpma_register <- rbind(full_data_dpma_register, database)
}
full_data_dpma_register$int_pat_id_joined <- substr(full_data_dpma_register$patent_id, 1, 14)
names(full_data_dpma_register)



full_data_depatisnet <- readRDS(paste0("data/depatisnet_files/data_depatisnet_group_1.rds"))
for (i in 2:30){
  database <- readRDS(paste0("data/depatisnet_files/data_depatisnet_group_",i,".rds"))
  full_data_depatisnet <- rbind(full_data_depatisnet, database)
}

setnames(full_data_depatisnet,  c("lfd..Nummer", "Veröffentlichungs.Nummer", "Anmeldedatum",
                                  "Veröffentlichungs.Datum", "IPC.Hauptklasse", 
                                  "IPC.Neben..Indexklassen", "Gemeinsame.Patentklassifikation..CPC.",
                                  "Reklassifizierte.IPC..MCD.", "Prüfstoff.IPC", "Erfinder", 
                                  "Anmelder.Inhaber", "Titel", "Zusammenfassung", "PDF.URL",
                                  "Sequenzprotokoll.URL", "Recherchierbarer.Text.URL"))

###creating linking data


uspto_joined_de <- uspto_joined %>% subset(.,Int_pat_country_code=="DE")

#### match with a blacklist of strings####

uspto_joined_de$int_pat_id_bereinigt <- gsub(" ","",uspto_joined_de$Int_pat_id)
##Deleting all the . numbers at the end of the patent id##
uspto_joined_de$int_pat_id_bereinigt <- gsub("\\..*","",uspto_joined_de$int_pat_id_bereinigt)
uspto_joined_de$int_pat_id_bereinigt <- gsub("\\,*","",uspto_joined_de$int_pat_id_bereinigt)
uspto_joined_de$int_pat_id_bereinigt <- gsub("\\-*","",uspto_joined_de$int_pat_id_bereinigt)
uspto_joined_de$int_pat_id_bereinigt <- gsub("\\/*","",uspto_joined_de$int_pat_id_bereinigt)
uspto_joined_de$int_pat_id_bereinigt <- gsub("A[0-9]A[0-9]","",uspto_joined_de$int_pat_id_bereinigt)
uspto_joined_de$int_pat_id_bereinigt <- paste0('DE', uspto_joined_de$int_pat_id_bereinigt)
uspto_joined_de$int_pat_id_bereinigt <- gsub("DEWO","WO",uspto_joined_de$int_pat_id_bereinigt)

uspto_joined_de$valid_pat_id<- grepl("DE[0-9]{5,12}[A-Z]?[0-9]?$",uspto_joined_de$int_pat_id_bereinigt)

uspto_joined_de <- subset(uspto_joined_de, valid_pat_id==TRUE)


uspto_joined_de$int_pat_id_key <-  gsub("DE", "", uspto_joined_de$int_pat_id_bereinigt)

for (i in 1:length(uspto_joined_de$int_pat_id_key)){
  if (nchar(uspto_joined_de$int_pat_id_key[i])<12){
    for (a in 1:(12-nchar(uspto_joined_de$int_pat_id_key[i]))){
      uspto_joined_de$int_pat_id_key[i] <- paste0("0",uspto_joined_de$int_pat_id_key[i])
    }
  } 
  uspto_joined_de$int_pat_id_key[i] <- paste0("DE",uspto_joined_de$int_pat_id_key[i])
}
uspto_joined_de$int_pat_id_key <- substr(uspto_joined_de$int_pat_id_key, 1, 14)
View(uspto_joined_de)

#### join uspto_joined with dpma_register####

uspto_dpma_register_join<-inner_join(uspto_joined_de,full_data_dpma_register, by=c("int_pat_id_key"="int_pat_id_joined"))
uspto_dpma_register_join$day_difference <- difftime(as.Date(uspto_dpma_register_join$Anmeldetag, format= "%d.%m.%y" ),as.Date(uspto_dpma_register_join$app_date), units = "days")/365
uspto_dpma_register_join$type_of_ip <- as.character("Patent")
uspto_dpma_register_join$type_of_ip[uspto_dpma_register_join$Schutzrecht %in% "Gebrauchsmuster"]<- as.character("Utility model")


uspto_dpma_register_join_na_omit<- uspto_dpma_register_join %>% na.omit()
hist(as.numeric(uspto_dpma_register_join_na_omit$day_difference), breaks = c(1,2,3,4,5,6,7,8,9,89))
names(uspto_dpma_register_join_na_omit)
ggplot(data=uspto_dpma_register_join_na_omit,  aes(day_difference, color=Schutzrecht)) + geom_histogram()
uspto_dpma_register_join$application_year_fp <- substr(uspto_dpma_register_join$Anmeldetag,7,10)


####join uspto_linked with depatisnet ####
view(full_data_depatisnet)
full_data_depatisnet$int_pat_id_key <- substr(full_data_depatisnet$Veröffentlichungs.Nummer, 1, 14)
uspto_depatisnet_join<-inner_join(uspto_joined_de,full_data_depatisnet, by=c("int_pat_id_key"="int_pat_id_key"))
#uspto_depatisnet_join<-inner_join(uspto_depatisnet_join,full_data_dpma_register, by=c("int_pat_id_key"="int_pat_id_key"))
view(uspto_depatisnet_join)
uspto_depatisnet_join$year_difference <- difftime(as.Date(uspto_depatisnet_join$Anmeldedatum, format= "%d.%m.%y" ),as.Date(uspto_depatisnet_join$app_date), units = "days")/365
nrow(uspto_depatisnet_join)
ggplot(data=uspto_depatisnet_join,  aes(year_difference)) + geom_histogram()
uspto_depatisnet_join$application_year_fp <- substr(uspto_depatisnet_join$Anmeldedatum,7,10)

####join dpma_register with depatisnet####