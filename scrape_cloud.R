#this version of the scrape is intended to be used in a cloud computing platform like heroku, for a local version see scrape_local.R

packages <- c('tidyverse', 'lubridate', 'rvest', 'googlesheets4')

run_setup <- function(packages) {
  invisible(suppressWarnings(suppressMessages(sapply(packages, require, character.only = TRUE, quietly = TRUE,  warn.conflicts = FALSE))))
}

run_setup(packages)

gs4_auth(
  scopes = 'https://www.googleapis.com/auth/spreadsheets',
  path = Sys.getenv('GOOGLE_DRIVE_KEY')
)

rss_urls <- c( #RSS FEED URLS, E.G. GOOGLE ALERTS )

sheet_url <-  #GOOGLE SHEET URL, NOTE THIS SCRAPE USES AN "IDs" SHEET AND AN "Alerts" SHEET

for (r in rss_urls){
  
  ids_sheet <- suppressMessages(read_sheet(sheet_url, sheet = "IDs") %>% mutate(Title = as.character(Title)))

  ids <- xml2::read_html(r) %>% #these tags refer to google alert RSS feeds, may need to alter for other feeds
    rvest::html_nodes("entry") %>%
    rvest::html_nodes("id") %>%
    rvest::html_text(trim = TRUE)
  
  titles <- xml2::read_html(r) %>%
    rvest::html_nodes("entry") %>%
    rvest::html_nodes("title") %>%
    rvest::html_text(trim = TRUE)
    
  links <- xml2::read_html(r) %>%
    rvest::html_nodes("entry") %>%
    rvest::html_nodes("link") %>%
    rvest::html_attr("href")
  
  abstracts <- xml2::read_html(r) %>%
    rvest::html_nodes("entry") %>%
    rvest::html_nodes("content") %>%
    rvest::html_text(trim = TRUE) %>%
    as.character()
  
  published <- xml2::read_html(r) %>%
    rvest::html_nodes("entry") %>%
    rvest::html_nodes("published") %>%
    rvest::html_text(trim = TRUE)
  
  updated <- xml2::read_html(r) %>%
    rvest::html_nodes("entry") %>%
    rvest::html_nodes("updated") %>%
    rvest::html_text(trim = TRUE)
  
  df_alerts <- tibble("Added" = now(),
                      "Reviewed" = NA,
                      "ID" = ids,
                      "Title" = titles, 
                      "Link" = links, 
                      "Abstract" = abstracts,
                      "Published" = published,
                      "Updated" = updated)
  
  df_alerts <- df_alerts %>% #clean a bit of the html from titles and abstracts
    mutate(Title = gsub("<.*?>", "", Title)) %>%
    mutate(Abstract = gsub("<.*?>", "", Abstract)) %>%
    mutate(Title = gsub("&#39;", "", Title)) %>%
    mutate(Abstract = gsub("&#39;", "", Abstract)) %>%
    distinct(Title, .keep_all = TRUE) %>%
    anti_join(ids_sheet, by = "Title")
  
  df_ids <- df_alerts %>%
    select(Title)
  
  sheet_append(sheet_url, df_alerts, sheet = "Alerts")
  sheet_append(sheet_url, df_ids, sheet = "IDs")
}
