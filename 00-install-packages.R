#==============================================================================
# 00-install-packages.R
# Purpose: install R packages and provide information about how to create
# OAuth token to query Twitter's API
# Author: Pablo Barbera
# Adaptation: Camila Lainetti de Morais
#==============================================================================

#### INSTALLING R PACKAGES FROM CRAN ####

doInstall <- TRUE  # Change to FALSE if you don't want packages installed.

toInstall <- c(
    "devtools", ## necessary to install smappR package
    "ROAuth", ## rstudio warning
    "ggplot2", "scales", "gridExtra",  ## gplot2 and extensions
    "streamR", ## library to capture and parse Tweets
    "twitteR", ## library to query Twitter REST API
    "Matrix", ## efficient storage of sparse matrices
    "yaml", ## read yaml files
    "httr", ## http requests
    "reshape2", ## reshape data frames
    "R2WinBUGS" ## used in Metropolis sampler
    )

if(doInstall){
    install.packages(toInstall, repos = "http://cran.r-project.org")
    library(devtools)
    install_github("SMAPPNYU/smappR")
    install_github("pablobarbera/twitter_ideology/pkg/tweetscores")
}


### INSTALLING STAN #### 

# For most up-to-date instructions, go to:
# https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started

Sys.setenv(MAKEFLAGS = "-j2") 
remove.packages("rstan")
remove.packages("StanHeaders")
if (file.exists(".RData")) file.remove(".RData")

install.packages("rstan", type = "source")

# original way is deprecated
# source('http://mc-stan.org/rstan/install.R', echo = TRUE, max.deparse.length = 2000)
# install_rstan()

### REGISTERING OAUTH TOKEN ###

## Step 1: go to dev.twitter.com and sign in
## Step 2: click on your username (top-right of screen) and then on "My applications"
## Step 3: click on "Create New App"
## Step 4: fill name, description, and website (it can be anything, even google.com).
##         (Leave callback ULR empty)
## Step 5: Agree to user conditions and enter captcha.
## Step 6: copy consumer key and consumer secret and paste below

# In order to successfully run ROAuth installing, it's required to run
# next line in terminal:
# sudo apt-get install libcurl4-openssl-dev, libssl-dev

install.packages("ROAuth", dependencies = TRUE)
library(ROAuth)

requestURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "https://api.twitter.com/oauth/authorize"
consumerKey <- "My_Consumer_Key"
consumerSecret <- "My_Consumer_Secret"
my_oauth <- OAuthFactory$new(consumerKey=consumerKey,
  consumerSecret=consumerSecret, requestURL=requestURL,
  accessURL=accessURL, authURL=authURL)

## run this line and go to the URL that appears on screen
my_oauth$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))

## Setting working folder
## From windows machine usually this works
# setwd("H:\\credentials\\twitter")
## From Linux/Mac computer, something like...
# setwd("credentials/twitter/")

## now you can save oauth token for use in future sessions with twitteR or streamR
save(my_oauth, file="my_oauth")

