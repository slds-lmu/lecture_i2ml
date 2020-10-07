library(tidyverse)
library(data.table)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

data_tweepy = fread("tweepy_df.csv", encoding = "UTF-8")

data_tweepy =
  data_tweepy %>%
  mutate(created_at = as.Date(created_at)) 

mdb_on_twitter = data_tweepy %>% 
  summarise(mdb_on_twitter = unique(username))

# data_tweepy %>% 
#   summarize(n_users = n_distinct(username))
# 
# data_tweepy %>% 
#   group_by(username) %>% 
#   summarize(tweets = n()) %>% 
#   summary()
# 
# data_tweepy %>% 
#   filter(!mentions != "[]") %>% 
#   summarize(n = n())

convert_array_to_list = function(x) {
  
  inner = function(x) {
    
    if(x == "[]") {
      
      return(NA)
      
    }
    
    else {
      
      components = unlist(strsplit(x, "'"))
      components = components[-c(1, length(components))]
      components = components[grep(",", components, invert = TRUE)]
      return(components)
      
    }
    
    
  }
  
  return(lapply(x, inner))
  
}

data_tweepy = data_tweepy %>% 
  mutate(mentions = convert_array_to_list(mentions),
         hashtags = convert_array_to_list(hashtags))

