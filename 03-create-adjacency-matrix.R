#==============================================================================
# 03-create-adjacency-matrix.R
# Purpose: create adjacency matrix indicating what users follow each
# politician
# Author: Pablo Barbera
# Adaptation: Camila Lainetti de Morais
#==============================================================================

# setwd('your_location')
source('auxiliary_functions/functions.R')

## using the one with filtered br data
outfolder <- 'data/followers_lists/'
userfile <- 'data/output/userlist-elite-tcc-7-filter-br.rdata'
matrixfile <- 'data/output/adj-matrix-tcc-filter-br.rdata'

#==============================================================================
# CENSUS: M
#==============================================================================

fls <- list.files(outfolder, full.names=TRUE)
census <- gsub(paste0(outfolder, "\\/(.*).Rdata"), fls, repl="\\1")
m <- length(census)

#==============================================================================
# USERS: N
#==============================================================================

# loading entire user list following >=3 politicians
load(userfile)
n <- length(users_filter_br$id)

#==============================================================================
# CREATING ADJACENCY MATRIX
#==============================================================================

m <- length(fls)
rows <- list()
columns <- list()

followers.list <- list(NULL)
for (i in 1:length(fls)){
	load(fls[i])
	followers.list[[i]] <- followers
	cat(i, "of", length(fls), "\n")
}

pb <- txtProgressBar(min=1,max=m, style=3)
for (j in 1:m){
	cat(fls[j])
    load(fls[j])
    to_add <- which(users_filter_br$id %in% followers)
    rows[[j]] <- to_add
    columns[[j]] <- rep(j, length(to_add))
    setTxtProgressBar(pb, j)
}

rows <- unlist(rows)
columns <- unlist(columns)

# preparing sparse Matrix
library(Matrix)
y <- sparseMatrix(i=rows, j=columns)
rownames(y) <- users_filter_br$id
colnames(y) <- census

save(y, file=matrixfile)






