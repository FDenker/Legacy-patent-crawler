library(RSelenium, quietly = TRUE, warn.conflicts = FALSE)
library(tidyverse , quietly = TRUE, warn.conflicts = FALSE)
library(rappdirs , quietly = TRUE, warn.conflicts = FALSE)
library(seleniumPipes, quietly = TRUE, warn.conflicts = FALSE)
library(utf8, quietly = TRUE, warn.conflicts = FALSE)
library(data.table, quietly = TRUE, warn.conflicts = FALSE)


###Search for additional patent information on DPMA Register###
#
##eCaps <- list(
#  chromeOptions = 
#    list(prefs = list(
#      "profile.default_content_settings.popups" = 0L,
#      "download.prompt_for_download" = FALSE,
#      "download.default_directory" = "C:\\Users\\Frederic Denker\\OneDrive - Zeppelin-University gGmbH\\Dokumente\\Semester 7\\clean_patent_project\\Patent_project\\data\\temp"
#    )
#    ))
remDr <- remoteDriver(remoteServerAddr = 'localhost', 
                      port = 4440, 
                      browser = "chrome"
                      ) 






initial_setup_dpmaregister_search <- function() {
  remDr$deleteAllCookies()
  remDr$navigate("https://register.dpma.de/DPMAregister/pat/experte")
  address_element <- remDr$findElement(using = 'class', value = 'dropdown_search')
  address_element$clearElement()
  #Enable all the buttons
  #webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "checkbox_0")] ')
  #webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "checkbox_1")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "checkbox_2")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "checkbox_3")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "checkbox_4")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "checkbox_5")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "checkbox_6")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "checkbox_7")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "checkbox_8")]')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "checkbox_9")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "checkbox_10")] ')
  webElem$clickElement()
  ##Setting it elements on page to 250##
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "trefferProSeite")]')
  webElem$sendKeysToElement(list("2"))
}

#remDr$screenshot(display = TRUE)


f_crawl_dpmaregister <- function(string_for_query) {
  #loading page and correcting buttons#
 
  initial_setup_dpmaregister_search()
  #writing the input into the query#
  address_element <- remDr$findElement(using = 'class', value = 'dropdown_search')
  address_element$sendKeysToElement(list(string_for_query))
  Sys.sleep(5)
  #webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "checkbox_0")] ')
  #webElem$clickElement()
  ##Going to the next page##
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "rechercheStarten")]')
  webElem$clickElement()
  
}





full_run_dpma <- function (start, end, datastring){
  ##creating the table to write the data into##
  dpmaregister_data <- setNames(data.table(matrix(nrow = 0, ncol = 13)),
                              c("lfd..Nummer","Aktenzeichen","Schutzrecht" , "Status", "Bezeichnung",
                                "IPC.Hauptklasse", "IPC.Nebenklasse.n.", 
                                "Anmeldetag", "Erstveroeffentlichungstag",
                                "Eintragungstag", "Anmelder.Inhaber", "Erfinder", 
                                "Vertreter"))
  for (i in start:end){
    print(paste0(i," | from ", start, "-", end))
    print(system.time({f_crawl_dpmaregister(datastring[i])}))
    Sys.sleep(5)
    doc <- XML::htmlParse(remDr$getPageSource()[[1]], encoding = "UTF-8")
    table_tmp <- XML::readHTMLTable(doc, as.data.frame = T) 
    table <- table_tmp[[1]] %>% .[-1,c(1,3:14)]
    print(nrow(table))
    dpmaregister_data <-  rbind(dpmaregister_data, table,  use.names=FALSE)
    
  }
  print("done")
  remDr$close()
  return(dpmaregister_data)
}



create_dpmaregister_string <- function(all_pat_ger_input_frame){
  
  ##writing all the patent ids into strings for dpmaregister crawler###
  string_for_lookup_pat_id <- c("")
  for(i in 1:ceiling(nrow(all_pat_ger_input_frame)/100)){
    if(i!=ceiling(nrow(all_pat_ger_input_frame)/100)){
      string_for_lookup_pat_id[i] <- toString(all_pat_ger_input_frame$int_pat_id_bereinigt[((i-1)*100):(i*100)] ) %>% gsub(",", " OR PN=", .) 
    }else{
      string_for_lookup_pat_id[i] <- toString(all_pat_ger_input_frame$int_pat_id_bereinigt[((i-1)*100):nrow(all_pat_ger_input_frame)]) %>%
        gsub(",", " OR PN=", .)
    }
    string_for_lookup_pat_id[i] <- paste0("PN= ", string_for_lookup_pat_id[i])
    
  }
  
  return(string_for_lookup_pat_id)
}


remDr$open(silent = T)
initial_setup_dpmaregister_search()