

library(rvest); library(tidyverse); library(httr)

# First, download this google doc as html: https://docs.google.com/document/d/122GLuyEnhQbAFbOMGqnj4nSAD2OW13DpkAxsxsGJTsA/edit

# Read downloaded html and extract links using rvest.  Will work with dedup'ed object "links_dedupe"
doc <- read_html("~/../Downloads/CodeforAtlantaListofOpenDataResources.html")
links <- data_frame(link = doc %>% html_nodes("a") %>% html_attr("href"))
links <- links %>%
     mutate(link2 = str_extract(link, "(?<=q=).+(?=/?\\&sa)")) %>%
     filter(!is.na(link))
links_dedupe <- links %>% select(link2) %>% distinct() %>% filter(!is.na(link2)) %>%
     mutate(redirect_url = NA_character_, status = NA_character_)

# Functions for making HEAD calls on each link (use function possibly & safely for error handling)
get_page_status <- function(link){
     http_status(HEAD(link))$message
}
safe_get_page_status <- possibly(get_page_status, otherwise = "error")

safe_head <- safely(HEAD, otherwise = "error")

# Loop through each link and grab status; save results to data frame links_dedupe
for(i in 1:nrow(links_dedupe)){
     original_url <- links_dedupe$link2[i]
     cat(i, ":", original_url, "\n")
     initial_header <- safe_head(original_url)
     if(length(initial_header$result) == 1){
          if(initial_header$result == "error"){
               new_url <- "error"
               links_dedupe$status[i] <- "error"
               links_dedupe$redirect_url[i] <- "error"
          }
     } else{
          new_url <- initial_header$result$url
          links_dedupe$status[i] <- safe_get_page_status(new_url)
          links_dedupe$redirect_url[i] <- new_url
     }
}

# Write to CSV
today_string <- str_replace_all(as.character(lubridate::today()), "-", "")
write_csv(links_dedupe, paste0("ATL Open Data Google Drive - link status ", today_string, ".csv"))
     