library(caret)
library(dplyr)
library(tidyverse)
library(broom)
library(factoextra)
library(simputation)
library(readxl)

# "Summarize" script will run the model on all datasets and compute the average Brier Score between them all.
# The process can take up to 15 minutes.
# The purpose of this is to test if the cluster model is better than the average win rate method 
#   on average for all players.

# Return list of files with more than threshold matches/rows (exclude those with less)
removefromfilelist_rowthreshold<-function(filelist, threshold){
  filelistreturn<-filelist
  c<-1
  for(i in filelistreturn) {
    player<-read_excel(i,1)
    if(nrow(player)<threshold){ #if you want less than the threshold, change the sign (>,<) here
      filelistreturn<-filelistreturn[-c]
    }
    c<-c+1
  }
  return(filelistreturn)
}

filenames <- list.files("./data", pattern="*.xlsx", full.names=TRUE)
tennis_clusters<-read_excel("./tennis_clusters.xlsx",1)

filenames<-removefromfilelist_rowthreshold(filenames, 200) #change row threshold here

#Run Here
clusterbrier<-c(integer(length(filenames)))
wrbrier<-c(integer(length(filenames)))
elobrier<-c(integer(length(filenames)))
c<-1 #counter
tStart<-Sys.time()
for(i in filenames) {
  pre_process(i) #run the model on file i
  print(c) #prints counter
  c<-c+1
}

print(Sys.time()-tStart)
print(mean(clusterbrier))
print(mean(wrbrier))
print(mean(elobrier))





