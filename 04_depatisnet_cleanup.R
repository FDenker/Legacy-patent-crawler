####Aim is to load the dpma group files and to then clean them so they can be merged with the uspto group files#####

###loading the dpma files###




german_side_database <- readRDS(file = paste0("data/depatisnet_files/data_group_",group, ".rds"))
setnames(german_side_database,  c("lfd..Nummer", "Veröffentlichungs.Nummer", "Anmeldedatum",
                                                                   "Veröffentlichungs.Datum", "IPC.Hauptklasse", 
                                                                   "IPC.Neben..Indexklassen", "Gemeinsame.Patentklassifikation..CPC.",
                                                                   "Reklassifizierte.IPC..MCD.", "Prüfstoff.IPC", "Erfinder", 
                                                                   "Anmelder.Inhaber", "Titel", "Zusammenfassung", "PDF.URL",
                                                                   "Sequenzprotokoll.URL", "Recherchierbarer.Text.URL"))


german_side_database$int_pat_id_key <- gsub("[ABCTU][0-9]","", german_side_database$Veröffentlichungs.Nummer)
german_side_database$int_pat_id_key <- gsub("[ABCTU]","", german_side_database$int_pat_id_key)



all_pat_ger$int_pat_id_key <-  gsub("DE", "", all_pat_ger$int_pat_id_bereinigt)

for (i in 1:length(all_pat_ger$int_pat_id_key)){
  if (nchar(all_pat_ger$int_pat_id_key[i])<12){
    for (a in 1:(12-nchar(all_pat_ger$int_pat_id_key[i]))){
      all_pat_ger$int_pat_id_key[i] <- paste0("0",all_pat_ger$int_pat_id_key[i])
    }
  } 
  all_pat_ger$int_pat_id_key[i] <- paste0("DE",all_pat_ger$int_pat_id_key[i])
}


#test <- full_join(all_pat_ger$german_side_database[,15:17], by = "int_pat_id_key")

#german_side_database[,17]
