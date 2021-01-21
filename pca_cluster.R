library(tidyverse)
library(broom)
library(readxl)
library(openxlsx)


# Script to generate PCA coordinates and K-means clusters

tennis_clusters<-read_excel("./tennis_clusters.xlsx",1)

tennis_matrix <- tennis_clusters %>%
  select(-starts_with(c("number","pc1","pc2","cluster"))) %>% 
  select_if(is.numeric) %>% 
  as.matrix()


tennis_pca<-prcomp(
  tennis_matrix,
  center=TRUE,
  scale=TRUE
)

drop_vars <- c("BP_svd_ovpr_ratio", "BP_conv_ovpr_ratio", "df2s_pct", "1st_pct")

tennis_pca_revised <- tennis_clusters %>%
  select(-starts_with(c("number","pc1","pc2","cluster"))) %>% 
  select_if(is.numeric) %>%
  select(-drop_vars) %>% 
  as.matrix() %>% 
  prcomp(center = TRUE, scale = TRUE)

pca_coords <- augment(tennis_pca_revised) %>% 
  select(.rownames, .fittedPC1, .fittedPC2) %>% 
  mutate(.fittedPC1 = .fittedPC1 * -1)

set.seed(2308)

tennis_km <- kmeans(pca_coords %>% select(-.rownames), centers = 28) #set number of cluster centers

tennis_clusters_revised <- tennis_clusters %>% 
  select(-starts_with(c("pc1","pc2","cluster"))) %>% 
  mutate(cluster = factor(tennis_km$cluster)) %>% 
  mutate(pc1 = pca_coords$.fittedPC1,
         pc2 = pca_coords$.fittedPC2)

# Uncomment to write a new tennis_clusters xlsx file
# write.xlsx(tennis_clusters_revised, "../tennis_clusters.xlsx") #.. to go back a directory or .for in current directory

# # Run Charts
# tennis_pca_revised %>%
# fviz_contrib(choice = "var", axes = 1) %>%
# fviz_contrib(choice = "var", axes = 2)

cluster_plot<-ggplot(tennis_clusters_revised,
       aes(pc1, pc2, color=cluster))+
         geom_point(show.legend = FALSE)+
         theme_bw()+
         theme(panel.grid=element_blank(),
               axis.ticks = element_blank(),
               plot.title.position = "plot")+
         labs(x="PC1", 
              y="PC2", 
              title="Players Grouped by First and Second Principal Components",
              subtitle = "Number of groups: 28")

  # get coordinates: tennis_clusters_revised[which(tennis_clusters_revised$name == "John Isner"), ]$pc1
  cluster_plot<-cluster_plot+
  annotate("text",x=-12.15635,y=-2.859145, label="Isner", size=2)+
  annotate("text",x=-12.39951,y=0.0842846, label="Opelka", size=2)+
  annotate("text",x=-13.52525273,y=-1.160271, label="Karlovic", size=2)+
  annotate("text",x=-10.43659,y=-0.04998409, label="Arthurs", size=2)+
  annotate("text",x=1.870487,y=-5.733101, label="Hewitt", size=2)+
  annotate("text",x=3.023816,y=-5.464648, label="Chang", size=2)+
  annotate("text",x=1.681962,y=-6.828446, label="Murray", size=2)+
  annotate("text",x=-2.890758,y=-2.792262, label="Fish", size=2)+
  annotate("text",x=-1.138847,y=-3.1298978, label="Haas", size=2)+
  annotate("text",x=1.492485,y=-9.711259, label="Djokovic", size=2)+
  annotate("text",x=-2.328836,y=-9.677202, label="Federer", size=2)+
  annotate("text",x=2.239228,y=-10.79461, label="Nadal", size=2)
  
print(cluster_plot)
  

