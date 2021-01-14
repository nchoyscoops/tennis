library(caret)
library(dplyr)
library(tidyverse)
library(Metrics)

# Cross Validation

# Exclude rows where the opponent's cluster(therefore w_l) is unknown/NA these players are undocumented(not enough match information)
player<-player[!is.na(player$w_l),]
player<-player[!is.na(player$surface),]

# Factorize w_l and opponent_cluster
player$w_l<-factor(player$w_l)
player$opponent_cluster<-factor(player$opponent_cluster)

# Brier Summary function returns Brier Score
brier_summary <- function(data, lev = NULL, model = NULL){
  Y_obs <- as.numeric(data[,"obs"])-1 #get observed win/loss as 1/0
  Y_pre <- as.data.frame(data[ ,"w"]) #get probabilities
  Brier<-(Y_pre-Y_obs)^2 
  Brier_all=sum(Brier)/nrow(data)
  names(Brier_all)="Brier Score"
  return(Brier_all)
}

oldw <- getOption("warn")
options(warn = -1)

train_control <- trainControl(
  method = "cv",
  number = 10, # 10-fold cross validation
  classProbs = TRUE,
  summaryFunction=brier_summary
)

model <- train(
  w_l ~ opponent_cluster+surface,
  data = player,
  trControl = train_control,
  method = "glm",
  family="binomial",
  metric="Brier Score"
)


print(model)


#Tests
playertest<-player


#Print average
average<-(sum(as.numeric(playertest$w_l)-1)/nrow(playertest))
print(c("Winrate", average))

# # Brier Score for Win Rate
# # faulty because Win rate is calculated for the entire dataset and not cross-validated thereby artificially deflating Brier Score
# playertest<-playertest%>%
#   mutate(brier=((as.numeric(w_l)-1)-average)^2)
# wr_b_score<-mean(playertest$brier)
# print(c("Winrate Brier Score",wr_b_score))


#Brier Score for Win Rate (adapted from https://stats.stackexchange.com/questions/61090/how-to-split-a-data-set-to-do-10-fold-cross-validation)
playertest<-playertest[sample(nrow(playertest)),] #Randomly shuffle the data
folds <- cut(seq(1,nrow(playertest)),breaks=10,labels=FALSE) #Create 10 equally size folds
wr2_b_score<-c()
for(i in 1:10) #Perform 10 fold cross validation
  { 
  testIndexes <- which(folds==i,arr.ind=TRUE)  #Segement your data by fold using the which() function
  testData <- playertest[testIndexes, ]
  trainData <- playertest[-testIndexes, ]
  
  average<-(sum(as.numeric(testData$w_l)-1)/nrow(testData))
  trainData<-trainData%>%
    mutate(brier=((as.numeric(w_l)-1)-average)^2)
  wr2_b_score<-c(wr2_b_score,mean(trainData$brier))
}
print(c("Winrate Brier Score",mean(wr2_b_score)))


#Brier Score for Elo Win Probability (https://www.betfair.com.au/hub/tennis-elo-modelling/#:~:text=Elo%20works%20by%20assigning%20a,%2C%20the%20probability%20becomes%2024.1%25.)
#This is fine because Win Probability is not dependent on past data therefore no training needs to occur
playertest<-playertest%>%
  mutate(pwin=1/(1+10^((loser_eloRating-winner_eloRating)/400)))

playertest<-playertest%>%
  mutate(brier=((as.numeric(w_l)-1)-pwin)^2)
pwin_b_score<-mean(playertest$brier)
print(c("Elo Brier Score",pwin_b_score))


#Cluster-Elo Win Probability Model
model <- train(
  w_l ~ opponent_cluster+surface+pwin,
  data = playertest,
  trControl = train_control,
  method = "glm",
  family="binomial",
  metric="Brier Score"
)
print(c("Cluster-Elo Brier Score",as.numeric(model$results[2])))


options(warn = oldw)


# #split data into training and test with 75% in training
#
# player<-player[!is.na(player$w_l),]
# training_set<-createDataPartition(player$w_l,p=.75,list=FALSE)
# player_training<-player[training_set,]
# player_test<-player[-training_set,]
# 
# #logistic regression prep
# 
# #set as factors surface, w_l, and opponent_cluster
# player_training$surface<-factor(player_training$surface)
# player_training$w_l<-factor(player_training$w_l)
# player_training$opponent_cluster<-factor(player_training$opponent_cluster)
# 
# model<-train(w_l ~ opponent_cluster, data=player_training, method="glm", family="binomial")
# 
# #model 1 without adjusting for surface and model 2 adjusting for surface
# logitplayer_m1<-glm(w_l ~ opponent_cluster, data=player_training, family=binomial)
# logitplayer_m2<-glm(w_l ~ opponent_cluster + surface, data=player_training, family=binomial)


# #example test of win probability

# newdata = data.frame(
#   opponent_cluster=25
#   #, surface='G'
#   )
# newdata$opponent_cluster<-factor(newdata$opponent_cluster)
# # newdata$surface<-factor(newdata$surface)
# print(predict(logitplayer_m1, newdata, type="response"))
