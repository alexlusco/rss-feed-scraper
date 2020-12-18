
#install.packages("pacman")
pacman::p_load(tidyverse, lubridate, rvest, googlesheets4)

rss_urls <- c( #RSS FEED URLS, E.G. GOOGLE ALERTS )

sheet_url <-  #GOOGLE SHEET URL, NOTE THIS SCRAPE USES AN "IDs" SHEET AND AN "Alerts" SHEET

for (r in rss_urls){
  
  ids_sheet <- suppressMessages(read_sheet(sheet_url, sheet = "IDs") %>% mutate(Title = as.character(Title)))

  ids <- read_html(r) %>% #these tags refer to google alert RSS feeds, may need to alter for other feeds
    html_nodes("entry") %>%
    html_nodes("id") %>%
    html_text(trim = TRUE)
  
  titles <- read_html(r) %>%
    html_nodes("entry") %>%
    html_nodes("title") %>%
    html_text(trim = TRUE)
    
  links <- read_html(r) %>%
    html_nodes("entry") %>%
    html_nodes("link") %>%
    html_attr("href")
  
  abstracts <- read_html(r) %>%
    html_nodes("entry") %>%
    html_nodes("content") %>%
    html_text(trim = TRUE) %>%
    as.character()
  
  published <- read_html(r) %>%
    html_nodes("entry") %>%
    html_nodes("published") %>%
    html_text(trim = TRUE)
  
  updated <- read_html(r) %>%
    html_nodes("entry") %>%
    html_nodes("updated") %>%
    html_text(trim = TRUE)
  
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
