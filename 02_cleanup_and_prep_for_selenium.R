require(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(stringr)




clean_data <- function(group_number) {
  
  ###Read patent rds###
  database <- readRDS(paste0("data/uspto_download_files/data_group_",group_number,".rds"))
  
  all_pat_ger <- database %>% subset(.,Int_pat_country_code=="DE")
  
  ### match with a blacklist of strings###
  
  all_pat_ger$int_pat_id_bereinigt <- gsub(" ","",all_pat_ger$Int_pat_id)
  ##Deleting all the . numbers at the end of the patent id##
  all_pat_ger$int_pat_id_bereinigt <- gsub("\\..*","",all_pat_ger$int_pat_id_bereinigt)
  all_pat_ger$int_pat_id_bereinigt <- gsub("\\,*","",all_pat_ger$int_pat_id_bereinigt)
  all_pat_ger$int_pat_id_bereinigt <- gsub("\\-*","",all_pat_ger$int_pat_id_bereinigt)
  all_pat_ger$int_pat_id_bereinigt <- gsub("\\/*","",all_pat_ger$int_pat_id_bereinigt)
  all_pat_ger$int_pat_id_bereinigt <- gsub("A[0-9]A[0-9]","",all_pat_ger$int_pat_id_bereinigt)
  all_pat_ger$int_pat_id_bereinigt <- paste0('DE', all_pat_ger$int_pat_id_bereinigt)
  all_pat_ger$int_pat_id_bereinigt <- gsub("DEWO","WO",all_pat_ger$int_pat_id_bereinigt)
  
  all_pat_ger$valid_pat_id<- grepl("DE[0-9]{5,12}[A-Z]?[0-9]?$",all_pat_ger$int_pat_id_bereinigt)
  
  lines_to_delete <- subset(all_pat_ger,valid_pat_id==FALSE)
  
  if(nrow(lines_to_delete)>0){
    saveRDS(lines_to_delete,paste0("data/depatisnet_files/faulty_lines/faulty_line_group",group_number,".rds"))
  }
  # Exclude all faulty lines
  all_pat_ger <- subset(all_pat_ger, valid_pat_id==TRUE)
  #How it supposed to look like "DE[0-9]{5,12}[A-Z][0-9]
  all_pat_ger$int_pat_id_for_lookup <- paste0(all_pat_ger$int_pat_id_bereinigt, '/PN')
  
  print(paste0("WARNING: ",nrow(lines_to_delete), " faulty lines excluded"))
  
  return(all_pat_ger) 
 
}


##Row 223 of Group 11 make na due to very weird data


create_depatisnet_string <- function(all_pat_ger_input_frame){

##writing all the patent ids into strings for depatisnet crawler###
string_for_lookup_pat_id <- c("")
for(i in 1:ceiling(nrow(all_pat_ger_input_frame)/100)){
  if(i!=ceiling(nrow(all_pat_ger_input_frame)/100)){
    string_for_lookup_pat_id[i] <- toString(all_pat_ger_input_frame$int_pat_id_for_lookup[((i-1)*100):(i*100)] ) %>% gsub(",", " OR", .) 
  }else{
    string_for_lookup_pat_id[i] <- toString(all_pat_ger_input_frame$int_pat_id_for_lookup[((i-1)*100):nrow(all_pat_ger_input_frame)]) %>%
      gsub(",", " OR", .)
  }
  
}
return(string_for_lookup_pat_id)
}




