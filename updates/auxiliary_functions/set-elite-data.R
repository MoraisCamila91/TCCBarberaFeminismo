#==============================================================================
# set-elite-data.R
# Purpose: set Elite data from cv
# Details: -
# Author: Camila Lainetti de Morais
#==============================================================================

getwd()
eliteData <- read.csv(file='data/investigation_data/twitter_elite_data.csv',sep=',',header=T)
save(eliteData, file="data/elites-data-tcc.Rdata")
