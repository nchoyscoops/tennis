library(caret)
library(dplyr)
library(tidyverse)
library(broom)
library(simputation)
library(readxl)


# Function pre-processes data by taking a file name, reads it, and adds columns. Passes the player dataframe to build_model
pre_process<-function(filename){

# Read Files
tennis_clusters<-read_excel("/Users/nolanchoy/Desktop/tennis_project/tennis/tennis_clusters.xlsx",1)
player<-read_excel(filename,1)

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

build_model(player)
}