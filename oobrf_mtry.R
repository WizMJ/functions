oobrf_mtry<-function(data, ntree){
library(randomForest)
#library(dplyr)
#library(ggplot2)
n<-c(1,7,15,30,122,158,227,350,451,498,500,513,578,599,602,647,649,709,880,964,1000,1232,
     1245,1890,2570,3400,5100,9303,10025,12347)
R<-length(n)
mtry<-seq(floor((ncol(data)-1)/3-1),floor((ncol(data)-1)/3+1))
names(mtry) <- as.character(c(mtry[1],paste("base",mtry[2]),mtry[3]))
form <- as.formula(paste0(colnames(data)[ncol(data)],"~."))
oob.error <- matrix(NA,R,length(mtry),dimnames=list(NULL,names(mtry)))
# 1st 시도
for (j in 1:length(mtry)){
for (i in 1:R){
#default nodesize: 분류는 1개 회귀는 5개
set.seed(n[i])
rf <- randomForest(form,data,ntree=ntree,mtry=mtry[j])
oob.error[i,j] <- mean(rf$mse)
}
}
compare <- apply(oob.error,2,mean)
#Bottom Check
step <- 1
while (compare[1] < compare[2]){
bottom.error <- matrix(NA,R,1,dimnames=list(NULL,as.character(mtry[1]-step)))
oob.error <- cbind(bottom.error,oob.error)
for (i in 1:R){
set.seed(n[i])
rf <- randomForest(form,data,ntree=ntree,mtry=mtry[1]-step)
oob.error[i,1] <- mean(rf$mse)
}
compare <- apply(oob.error,2,mean)
step <- step+1
if (mtry[1]-step==0) break
}
#Top Check
step <- 1
while (compare[length(compare)] < compare[length(compare)-1]){
  top.error <- matrix(NA,R,1,dimnames=list(NULL,as.character(mtry[3]+step)))
  oob.error <- cbind(oob.error,top.error)
  for (i in 1:R){
  set.seed(n[i])
  rf <- randomForest(form,data,ntree=ntree,mtry=mtry[3]+step)
  oob.error[i,ncol(oob.error)]<-mean(rf$mse)
  }
  compare <- apply(oob.error,2,mean)
  step <- step+1
}
mtry <- as.numeric(names(compare[which.min(compare)]))
rf <- randomForest(form,data,ntree=ntree,mtry=mtry,importance=TRUE)
imp <- importance(rf)
#visualization
#impMSE<-data.frame(Variables=row.names(imp),value=round(imp[,1],2))
#impMSE$Criterion<-"%IncMSE"
#impMSE<-impMSE %>% mutate(Rank=paste0("#",rank(desc(imp[,1]))))
#impNode<-data.frame(Variables=row.names(imp),value=round(imp[,2],2))
#impNode$Criterion<-"Node.Purity"
#impNode<-impNode %>% mutate(Rank=paste0("#",rank(desc(imp[,2]))))
#varimp<-bind_rows(impMSE,impNode)
#ggplot(varimp, aes(x=))
varImpPlot(rf)
return(list(OOB.Error=compare,importance=imp,rf=rf))
}

