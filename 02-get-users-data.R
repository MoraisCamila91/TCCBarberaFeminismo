#==============================================================================
# 02-get-users-data.R
# Purpose: create list of users who follow 3 or more political accounts, and
# then download their data from Twitter API to apply spam and geography filter
# Author: Pablo Barbera
# Adaptation: Camila Lainetti de Morais
#==============================================================================
toInstall <- c("ggplot2", "scales", "R2WinBUGS", "devtools", "yaml", "httr", "RJSONIO")
install.packages(toInstall, repos = "http://cran.r-project.org")
library(devtools)

install_github("pablobarbera/twitter_ideology/pkg/tweetscores", dependencies = TRUE)
library(tweetscores)

install_github("pablobarbera/streamR/streamR", dependencies = TRUE)
library(streamR)

library(devtools)
library(dplyr)
library(tweetscores)
library(streamR)
library(tidyverse)

# setwd('your_location')
source('auxiliary_functions/functions.R')

outfolder <- 'data/followers_lists/'
userfile <- 'data/output/userlist-tcc.rdata'
outfolder <- 'data/followers_lists/'
userfile <- 'data/output/userlist-tcc.rdata'

users_dt_file <- 'data/output/userlist-elite-tcc-6.rdata'
users_dt_left <- 'data/output/userlist-elite-tcc-left-ids.rdata'
load(userfile)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## creating user list
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# opening all follower lists and merging them into a single list

fls <- list.files(outfolder, full.names=TRUE)
followers.list <- list(NULL)
for (i in 1:length(fls)){
	load(fls[i])
	followers.list[[i]] <- followers
	cat(i, "of", length(fls), "\n")
}

all_users_list <- unlist(followers.list)
cat(length(unique(all_users_list))) # counting number of unique users
userlistfollowers <- table(all_users_list) # aggregating at user level

# keeping list of users who follow 3+ politicians
userlistfollowers <- userlistfollowers[userlistfollowers>=3]
save(userlistfollowers, file=userfile)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## download user information from Twitter API
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# list of IDs to download now
left.ids <- userlistfollowers
left.ids <- as.data.frame(left.ids)
left.ids$id <- as.list(levels(left.ids$all_users_list))

# getting list of IDs already downloaded (if any)
if (file.exists(users_dt_file)) {
  load(users_dt_file)
}

if (exists("users_dt") && is.data.frame(get("users_dt"))) {
  done.ids <- users_dt
} else {
  done.ids <- c() 
}

if (file.exists(users_dt_left)) {
  load(users_dt_left)
} else {
  left.ids <- userlistfollowers
  left.ids <- as.data.frame(left.ids)
  left.ids$id <- as.list(levels(left.ids$all_users_list))
  left.ids <- anti_join(left.ids, done.ids, by=c("id" = "id"))
}

t <- 0

# loop over users
while (length(left.ids$all_users_list)>0){
    # take random sample of 100 users
    new.users <- sample_n(left.ids, 100)

    # get user information from Twitter API    
    error <- tryCatch(j <- getUsers(ids=new.users$all_users_list, ## users lookup, 300 requests
    	oauth="credentials/twitter"),
            error=function(e) e)
    if (inherits(error, 'error')) {
        cat("Error! On to the next one...")
        cat(format(Sys.time(), "%a %b %d %X %Y")) 
        testerror <- function(err) {
         tryCatch(
           expr={
             if (err[["httpHeader"]][["status"]] == "429") {
               Sys.sleep(60*7)
             }
           },
           error=function(e){
             Sys.sleep(1)
           }
         )
        }
        
        sleeping <- testerror(error)
        next
    }
    
    # managing API output
    len <- sapply(j, length)
    n <- max(len)
    len <- n - len
    
    # adjusting API outcome
    j_df <- data.frame(t(mapply(function(x,y) c(x, rep(NA, y)), j, len)))
    
    if (!"status" %in% colnames(j_df)) {
      next
    }
    
    j_df <- j_df %>% unnest_wider(status, names_sep=".")
    j_df$random_number <- runif(nrow(j_df), min=0, max=1)
    j_df <- j_df %>% select(id_str, 
                            id, 
                            created_at, 
                            random_number, 
                            followers_count, 
                            status.created_at, 
                            statuses_count, 
                            friends_count, 
                            location)
    
    j_df <- j_df %>% 
      rename(idint = id,
             id = id_str,
             created_at_or_timestamp = created_at,
             followers = followers_count,
             last_tweet = status.created_at,
             statuses_or_tweets = statuses_count,
             following_count = friends_count)
    
    if (exists("users_dt") && is.data.frame(get("users_dt"))) {
      users_dt <- rbind(j_df, users_dt)
    } else {
      users_dt <- j_df
    }
    
    save(users_dt, file=users_dt_file)

    # removing done IDs from list
    left.ids <- anti_join(left.ids, new.users)
    save(left.ids, file=users_dt_left)

    # information on console
    cat("\n ", length(left.ids$all_users_list), " accounts left!\n")
    cat(format(Sys.time(), "%a %b %d %X %Y"))
    rm(j)
}


####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##### applying simple spam classifier + applying geography classifier
####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Adjusting formats
users_dt$id <- unlist(users_dt$id)
users_dt$idint <- unlist(users_dt$idint)
users_dt$created_at_or_timestamp <- unlist(users_dt$created_at_or_timestamp)
users_dt$followers <- unlist(users_dt$followers)
users_dt$statuses_or_tweets <- unlist(users_dt$statuses_or_tweets)
users_dt$following_count <- unlist(users_dt$following_count)
users_dt$location <- unlist(users_dt$location)

users_dt$created_at_or_timestamp <- substr(users_dt$created_at_or_timestamp,5,nchar(users_dt$created_at_or_timestamp))
users_dt$last_tweet <- substr(users_dt$last_tweet,5,nchar(users_dt$last_tweet))

users_dt$created_at_or_timestamp <- str_replace(users_dt$created_at_or_timestamp, pattern = "\\d+\\:\\d+\\:\\d+\\ ", replacement = "")
users_dt$last_tweet <- str_replace(users_dt$last_tweet, pattern = "\\d+\\:\\d+\\:\\d+\\ ", replacement = "")

users_dt$created_at_or_timestamp <- str_replace(users_dt$created_at_or_timestamp, pattern = "\\+\\d+\\ ", replacement = "")
users_dt$last_tweet <- str_replace(users_dt$last_tweet, pattern = "\\+\\d+\\ ", replacement = "")

users_dt$created_at_or_timestamp <- gsub(" ", "-", users_dt$created_at_or_timestamp, fixed = TRUE)
users_dt$last_tweet <- gsub(" ", "-", users_dt$last_tweet, fixed = TRUE)

users_dt$created_at_or_timestamp <- gsub("Jan", "01", users_dt$created_at_or_timestamp, fixed = TRUE)
users_dt$created_at_or_timestamp <- gsub("Feb", "02", users_dt$created_at_or_timestamp, fixed = TRUE)
users_dt$created_at_or_timestamp <- gsub("Mar", "03", users_dt$created_at_or_timestamp, fixed = TRUE)
users_dt$created_at_or_timestamp <- gsub("Apr", "04", users_dt$created_at_or_timestamp, fixed = TRUE)
users_dt$created_at_or_timestamp <- gsub("May", "05", users_dt$created_at_or_timestamp, fixed = TRUE)
users_dt$created_at_or_timestamp <- gsub("Jun", "06", users_dt$created_at_or_timestamp, fixed = TRUE)
users_dt$created_at_or_timestamp <- gsub("Jul", "07", users_dt$created_at_or_timestamp, fixed = TRUE)
users_dt$created_at_or_timestamp <- gsub("Aug", "08", users_dt$created_at_or_timestamp, fixed = TRUE)
users_dt$created_at_or_timestamp <- gsub("Sep", "09", users_dt$created_at_or_timestamp, fixed = TRUE)
users_dt$created_at_or_timestamp <- gsub("Oct", "10", users_dt$created_at_or_timestamp, fixed = TRUE)
users_dt$created_at_or_timestamp <- gsub("Nov", "11", users_dt$created_at_or_timestamp, fixed = TRUE)
users_dt$created_at_or_timestamp <- gsub("Dec", "12", users_dt$created_at_or_timestamp, fixed = TRUE)

users_dt$last_tweet <- gsub("Jan", "01", users_dt$last_tweet, fixed = TRUE)
users_dt$last_tweet <- gsub("Feb", "02", users_dt$last_tweet, fixed = TRUE)
users_dt$last_tweet <- gsub("Mar", "03", users_dt$last_tweet, fixed = TRUE)
users_dt$last_tweet <- gsub("Apr", "04", users_dt$last_tweet, fixed = TRUE)
users_dt$last_tweet <- gsub("May", "05", users_dt$last_tweet, fixed = TRUE)
users_dt$last_tweet <- gsub("Jun", "06", users_dt$last_tweet, fixed = TRUE)
users_dt$last_tweet <- gsub("Jul", "07", users_dt$last_tweet, fixed = TRUE)
users_dt$last_tweet <- gsub("Aug", "08", users_dt$last_tweet, fixed = TRUE)
users_dt$last_tweet <- gsub("Sep", "09", users_dt$last_tweet, fixed = TRUE)
users_dt$last_tweet <- gsub("Oct", "10", users_dt$last_tweet, fixed = TRUE)
users_dt$last_tweet <- gsub("Nov", "11", users_dt$last_tweet, fixed = TRUE)
users_dt$last_tweet <- gsub("Dec", "12", users_dt$last_tweet, fixed = TRUE)

# all users formatted
users_dt$created_at_or_timestamp <- as.Date(users_dt$created_at_or_timestamp, format = "%m-%d-%Y")
users_dt$last_tweet <- as.Date(users_dt$last_tweet, format = "%m-%d-%Y")
save(users_dt, file='data/output/userlist-elite-tcc-7.rdata')

# filtering: followers (min = 20), tweets (min = 50), last tweet in 2020

# without br filter
users_filter <- filter(users_dt, followers >= 20, statuses_or_tweets >= 50, last_tweet >= "2020-01-01")
save(users_filter, file='data/output/userlist-elite-tcc-7-filter.rdata')

# with br filter
users_filter_br <- filter(users_dt, followers >= 20, statuses_or_tweets >= 50, last_tweet >= "2020-01-01", str_detect(tolower(location), 'brasil|brazil|br')) 
save(users_filter_br, file='data/output/userlist-elite-tcc-7-filter-br.rdata')