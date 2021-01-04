library(readxl)

replace_player_file<-function(file_name){
  player_file<-read.csv(file_name,1)
  player_name_vector<-as.vector(as.matrix(player_file[,c("winner_name","loser_name")]))
  name<-tail(names(sort(table(player_name_vector))), 1)
  #split name by space into "firstname" "lastname"
  playername<-strsplit(name, " ")%>%
    unlist
  #add "_" between
  fileplayername<-c(playername[1],"_",playername[2])
  b<-paste(c("./data/",fileplayername,".csv"),sep="", collapse="")
  new_name <- sub('.csv', '.xlsx', b, fixed = TRUE)
  openxlsx::write.xlsx(player_file, new_name, row.names = FALSE)
  if (file.exists(paste(c("./data/",fileplayername,".xlsx"),sep="", collapse=""))) {
    #Delete file if new version exists
    file.remove(file_name)
  }
}

# filenames <- list.files("./data", pattern="*.csv", full.names=TRUE)
# for(i in filenames) {
#   a <- read.csv(i)
#   new_name <- sub('.csv', '.xlsx', i, fixed = TRUE)
#   write.xlsx(a, new_name)
# }