#==============================================================================
# 01-get-twitter-data.R
# Purpose: download list of Twitter followers of politicians from Twitter API
# Details: follower lists are stored in 'outfolder' as .Rdata files
# Author: Pablo Barbera
# Adaptation: Camila Lainetti de Morais
#==============================================================================

# back from credential creation
# setwd('your_location')

outfolder <- 'data/followers_lists/'
source('auxiliary_functions/functions.R')

# open list of political elites from paper
load("data/elites-data-tcc.Rdata")

# unique elite data frame
# names(eliteData)

# subset accounts with more than 2K followers
eliteData <- eliteData[eliteData$followers_count>2000,]

# first check if there's any list of followers already downloaded to 'outfolder'
accounts.done <- gsub(".rdata", "", list.files(outfolder))
accounts.left <- eliteData$simple_screen_name[tolower(eliteData$simple_screen_name) %in% tolower(accounts.done) == FALSE]
accounts.left <- accounts.left[!is.na(accounts.left)]

# loop over the rest of accounts, downloading follower lists from API
while (length(accounts.left) > 0){

    # sample randomly one account to get followers
    new.user <- sample(accounts.left, 1)
    cat(new.user, " -- ", length(accounts.left), " accounts left!\n")   
    
    # download followers (with some exception handling...) 
    error <- tryCatch(followers <- getFollowers(screen_name=new.user,
        oauth="credentials/twitter"), error=function(e) e)
    Sys.sleep(5)
    if (inherits(error, 'error')) {
        cat("Error! On to the next one...")
        Sys.sleep(5)
        next
    }
    
    # save to file and remove from lists of "accounts.left"
    file.name <- paste0(outfolder, new.user, ".rdata")
    save(followers, file=file.name)
    accounts.left <- accounts.left[-which(accounts.left %in% new.user)]

}

