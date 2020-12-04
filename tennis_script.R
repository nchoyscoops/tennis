library(caret)
library(dplyr)
library(tidyverse)
library(broom)
library(factoextra)
library(simputation)
library(readxl)

#init
tennis_clusters<-read_excel("/Users/nolanchoy/Desktop/tennis_project/tennis/data/tennis_clusters.xlsx",1)
pete_sampras<-read_excel("/Users/nolanchoy/Desktop/tennis_project/tennis/data/pete_sampras.xlsx",1)

ps2<-pete_sampras
name<-"Pete Sampras"

#generate new columns for loser_cluster, winner_cluster, won_vs_cluster, opponent_cluster, w_l
set.seed(350)
ps2<-ps2%>%
  left_join(tennis_clusters[,c("name","cluster")],by=c("loser_name"="name"))%>%
  rename(loser_cluster=cluster) %>%
  left_join(tennis_clusters[,c("name","cluster")],by=c("winner_name"="name"))%>%
  rename(winner_cluster=cluster)%>%
  mutate(won_vs_cluster=ifelse(winner_name==name,loser_cluster,NA),lost_vs_cluster=ifelse(winner_name==name,NA,winner_cluster))%>%
  mutate(opponent_cluster=ifelse(is.na(won_vs_cluster),lost_vs_cluster,won_vs_cluster))%>%
  mutate(w_l=ifelse(is.na(opponent_cluster),NA,ifelse(is.na(lost_vs_cluster),"w",ifelse(is.na(won_vs_cluster),"l",NA))))

#split data into training and test with 75% in training
ps2<-ps2[!is.na(ps2$w_l),]
training_set<-createDataPartition(ps2$w_l,p=.75,list=FALSE)
ps2_training<-ps2[training_set,]
ps2_test<-ps2[-training_set,]

#logistic regression
ps2_training$surface<-factor(ps2_training$surface)
#set as factors w_l and opponent_cluster
ps2_training$w_l<-factor(ps2_training$w_l)
ps2_training$opponent_cluster<-factor(ps2_training$opponent_cluster)

#model 1 without adjusting for surface and model 2 adjusting for surface
logitps2_m1<-glm(w_l ~ opponent_cluster, data=ps2_training, family=binomial)
logitps2_m2<-glm(w_l ~ opponent_cluster + surface, data=ps2_training, family=binomial)
# 
# #example test of win probability
# newdata = data.frame(opponent_cluster=24, surface='G')
# newdata$opponent_cluster<-factor(newdata$opponent_cluster)
# newdata$surface<-factor(newdata$surface)
# print(predict(logitps2_m1, newdata, type="response"))
