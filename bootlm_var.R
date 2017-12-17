
bootlm_var<-function(data,R){
library(leaps)

var<-ncol(data)-1   #변수 Max. 19개 까지 작동함
form<-as.formula(paste0(colnames(data)[ncol(data)],"~."))
MSE_oob<-matrix(NA,R,var,dimnames=list(NULL,paste(1:var)))
for (j in 1:R){
  set.seed(j)
  index<-sample(nrow(data),nrow(data),replace=T)
  oob_index<-(-as.numeric(names(table(index))))
  train<-data[index,]
  oob<-data[oob_index,]
  #mat<-model.matrix(form,data) #bootstrap의 test set은 전체 set
  mat_oob<-model.matrix(form,oob)
  
  #prediction
  lm.fit<-regsubsets(form,data=train,nvmax=var)
  for (i in 1:var){
  coefi<-coef(lm.fit,i)
  pred_oob<-mat_oob[,names(coefi)]%*%coefi
  MSE_oob[j,i]<-mean((oob[,ncol(oob)]-pred_oob)^2)
  }
}

MSE_avg<-apply(MSE_oob,2,mean)
std<-apply(MSE_oob,2,sd)
Top3<-head(sort(MSE_avg),3)
plot(MSE_avg,type='b')
return(list(MSE_avg=MSE_avg,MSE_se=std,Top3variable=Top3))
}
