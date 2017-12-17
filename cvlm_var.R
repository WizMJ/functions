# Find numbers of variables for linear regression by cross-validation
cvlm_var<-function(data,k,var){
n<-c(1,7,15,30,122,158,227,350,451,498,500,513,578,599,602,647,649,709,880,964,1000,1232,
     1245,1890,2570,3400,5100,9303,10025,12347)
library(leaps)
form<-as.formula(paste0(colnames(data)[ncol(data)],"~."))
cv.errors<-array(NA,dim=c(k,var,length(n)),dimnames=list(NULL,paste(1:var)))
# k-folds생성
wh<-rep(rep(1:k,each=T),nrow(data)/k)
if (nrow(data)%%k!=0){
  wh.add<-wh[1:(nrow(data)%%k)]
  wh<-c(wh,wh.add)
}
for (m in 1:length(n)){  #30번 set.seed iteration
set.seed(n[m])
subset<-sample(1:nrow(data),nrow(data),replace=FALSE)
cv<-data.frame(which=wh,subset=subset)
#cv<-cvFolds(nrow(orig_data),K=k) <-- cvToos Package사용시 상기code대신 사용
for (j in 1:k){  #j = k folds관련
  folds<-cv$subset[which(cv$which==j)]
  train<-data[-folds,] 
  test<-data[folds,]
  test_y<-test[,ncol(test)]
  best.fit<-regsubsets(form,data=train,nvmax=var)
  
for(i in 1:var){ # i 는 변수 갯수 
  mat<-model.matrix(form,test)
  coefi<-coef(best.fit,id=i)
  pred<-mat[,names(coefi)]%*%coefi
  cv.errors[j,i,m]=mean((test_y-pred)^2)
  }
}
}
MSE_avg<-apply(cv.errors,2,mean)
std<-apply(cv.errors,2,sd)
Top3<-head(sort(MSE_avg),3)
plot(MSE_avg,type='b')
return(list(MSE_avg=MSE_avg,MSE_sd=std,Top3variable=Top3))
}
