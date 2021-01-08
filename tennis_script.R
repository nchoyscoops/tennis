library(caret)
library(dplyr)
library(tidyverse)
library(broom)
library(factoextra)
library(simputation)
library(readxl)

player_name<-"Pete_Sampras"

# Read Files
tennis_clusters<-read_excel("/Users/nolanchoy/Desktop/tennis_project/tennis/data/tennis_clusters.xlsx",1)
player_file<-read_excel(paste(c("./data/",player_name,".xlsx"),sep="", collapse=""),1)

player<-player_file

# player name
player_name_vector<-as.vector(as.matrix(player[,c("winner_name","loser_name")]))
name<-tail(names(sort(table(player_name_vector))), 1)


# Pre-processing

# generate new columns for loser_cluster, winner_cluster, won_vs_cluster, opponent_cluster, w_l
# set.seed(350)
player<-player%>%
  left_join(tennis_clusters[,c("name","cluster")],by=c("loser_name"="name"))%>%
  rename(loser_cluster=cluster) %>%
  left_join(tennis_clusters[,c("name","cluster")],by=c("winner_name"="name"))%>%
  rename(winner_cluster=cluster)%>%
  mutate(won_vs_cluster=ifelse(winner_name==name,loser_cluster,NA),lost_vs_cluster=ifelse(winner_name==name,NA,winner_cluster))%>%
  mutate(opponent_cluster=ifelse(is.na(won_vs_cluster),lost_vs_cluster,won_vs_cluster))%>%
  mutate(w_l=ifelse(is.na(opponent_cluster),NA,ifelse(is.na(lost_vs_cluster),"w",ifelse(is.na(won_vs_cluster),"l",NA))))

source('~/Desktop/tennis_project/tennis/player_modeling.R')
