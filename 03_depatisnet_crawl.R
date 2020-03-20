library(RSelenium, quietly = TRUE, warn.conflicts = FALSE)
library(tidyverse , quietly = TRUE, warn.conflicts = FALSE)
library(rappdirs , quietly = TRUE, warn.conflicts = FALSE)
library(seleniumPipes, quietly = TRUE, warn.conflicts = FALSE)
library(utf8, quietly = TRUE, warn.conflicts = FALSE)
library(data.table, quietly = TRUE, warn.conflicts = FALSE)


###This starts selenium###
#java -Dwebdriver.chrome.driver="/docker/chromedriver.exe" -jar /docker/selenium-server-standalone-4.0.0-alpha-1.jar -port 4440
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
                      browser = "chrome") 



remDr$open(silent = T)
initial_setup_depatisnet_search()



initial_setup_depatisnet_search <- function() {
  remDr$deleteAllCookies()
  remDr$navigate("https://depatisnet.dpma.de/DepatisNet/depatisnet?window=1&space=menu&content=index&action=ikofax")
  address_element <- remDr$findElement(using = 'class', value = 'dropdown_search')
  address_element$clearElement()
  #Enable all the buttons
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "Pub")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "Icm")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "Ab")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "Icp")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "Mcsf")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "Ti")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "In")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "Sp")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "Ad")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "Cpc")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "Pa")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "Icsf")] ')
  webElem$clickElement()
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "Ti")] ')
  webElem$clickElement()
  ##Setting it elements on page to 250##
  webElem <- remDr$findElement(using = 'xpath', value = '//*[(@id = "hitsPerPage")]')
  webElem$sendKeysToElement(list("2"))
}

#remDr$screenshot(display = TRUE)

later_setup_depatisnet_search <- function(){
  remDr$navigate("https://depatisnet.dpma.de/DepatisNet/depatisnet?window=1&space=menu&content=index&action=ikofax")
  address_element <- remDr$findElement(using = 'class', value = 'dropdown_search')
  address_element$clearElement()
}

f_crawl_depatisnet <- function(string_for_query) {
  #loading page and correcting buttons#
  initial_setup_depatisnet_search()
  #writing the input into the query#
  address_element <- remDr$findElement(using = 'class', value = 'dropdown_search')
  address_element$clearElement()
  address_element$sendKeysToElement(list(string_for_query))
  Sys.sleep(5)
  ##Going to the next page##
  webElem <- remDr$findElement(using = "name", "Recherche")
  webElem$clickElement()
  
  ##Download data##
  #remDr$navigate("https://depatisnet.dpma.de/DepatisNet/depatisnet?window=1&space=main&content=&firstdoc=1&action=download_treffer_csv")
}

full_run <- function (start, end, datastring){
  
  ##creating the table to write the data into##
  depatisnet_data <- setNames(data.table(matrix(nrow = 0, ncol = 16)),
                              c("lfd..Nummer", "Veröffentlichungs.Nummer", "Anmeldedatum",
                                "Veröffentlichungs.Datum", "IPC.Hauptklasse", 
                                "IPC.Neben..Indexklassen", "Gemeinsame.Patentklassifikation..CPC.",
                                "Reklassifizierte.IPC..MCD.", "Prüfstoff.IPC", "Erfinder", 
                                "Anmelder.Inhaber", "Titel", "Zusammenfassung", "PDF.URL",
                                "Sequenzprotokoll.URL", "Recherchierbarer.Text.URL"))
  for (i in start:end){
    print(paste0(i,"/",end))
    print(system.time({f_crawl_depatisnet(datastring[i])}))
    Sys.sleep(5)
     ## check it##
    doc <- XML::htmlParse(remDr$getPageSource()[[1]], encoding = "UTF-8")
    table_tmp <- XML::readHTMLTable(doc, as.data.frame = T) 
    table <- table_tmp[[1]] %>% . [,c(1,3:17)]
    print(nrow(table))
    
      depatisnet_data <-  rbind(depatisnet_data, table,  use.names=FALSE)
    
    
    }
    
  }
  print("done")
  remDr$close()
  return(depatisnet_data)
}




