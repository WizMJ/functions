# Find lamda for Regularizational Regression by k folds Cross-Validation
cvreg_lam<-function(data,k,no.lam,al){   
library(glmnet)
n<-c(1,7,15,30,122,158,227,350,451,498,500,513,578,599,602,647,649,709,880,964,1000,1232,
     1245,1890,2570,3400,5100,9303,10025,12347)
form<-as.formula(paste0(colnames(data)[ncol(data)],"~."))
x<-model.matrix(form,data)[,-1]  #절편은 제거해야함
y<-data[,ncol(data)]

sh<-10^seq(8,-2,length=no.lam)
cv.errors<-array(NA,dim=c(k,no.lam,length(n)),dimnames=list(NULL,paste(1:no.lam)))
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

for (j in 1:k){
  test<-cv$subset[which(cv$which==j)]
  train<-(-test)
  ridge.fit<-glmnet(x[train,],y[train],alpha=al,lambda=sh,thresh=1e-12)
  pred<-predict(ridge.fit,s=sh,newx=x[test,])
  cv.errors[j,,m]<-apply((y[test]-pred)^2,2,mean)
}
}
MSE_avg<-apply(cv.errors,2,mean)
std<-apply(cv.errors,2,sd)
Top3<-head(sort(MSE_avg),3)
out<-glmnet(x,y,alpha=al) #sh별도 지정안해도 됨. 아래 coef에서 s를 지정하기 때문
par(mfrow=c(1,2))
plot(MSE_avg,type='b')
plot(out)
#Top1
coef<-predict(out,s=sh[as.integer(names(Top3)[1])],type="coefficients")[1:ncol(data),]
names(Top3)<-sh[as.integer(names(Top3))]
return(list(MSE_avg=MSE_avg,MSE_se=std,Top3lambda=Top3,Top1Coef=coef))
}

# 만약 lambda의 범위를 조정해 최적의 lambda값 사용시 아래 사용
#bestlam<-rep(NA,30)
#for (i in 1:30){
#set.seed(i)
#cv.out<-cv.glmnet(x,y,alpha=0,nfolds=10) #using lambda default
#bestlam[i]<-cv.out$lambda.min
#}
#sh<-seq(mean(bestlam)/10,mean(bestlam)*10,length=100)
