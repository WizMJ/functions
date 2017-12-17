#Validation by Holdout or CV for Linear Model, RIDGE, LASSO, RandomForest
Validation<-function(data,method,learner,optvar,nReps,size){
if (leaner =="Lasso" | learner =="Ridge"){
library(glmnet)
x<-model.matrix(form,data)[,-1]; y<-data[,ncol(data)] #for Ridge and Lasso
else if (learner =="lm"){
library(leaps)
}
else if (learner == "randomForest"){
library(randomForest)
}
#nReps은 최대 30까지
n <- c(1,7,15,30,122,158,227,350,451,498,500,513,578,599,602,647,649,709,880,964,1000,1232,
       1245,1890,2570,3400,5100,9303,10025,12347)  
form <- as.formula(paste0(colnames(data)[ncol(data)],"~."))
#Train & Test Set Division
if (method =="Holdout"){
for (i in 1:nReps){
set.seed(n[i])
train<-sample(1:nrow(data),nrow(data)*size)
test<-(-train)

test.mat<-model.matrix(form,data[test,]) #for lm

# fit
lm.fit<-regsubsets(form,data=data[train,],nvmax=var)
lm.coef<-coef(lm.fit,var)
ridge.fit<-glmnet(x[train,],y[train],alpha=0,lambda=lambda0,thresh=1e-12)
lasso.fit<-glmnet(x[train,],y[train],alpha=1,lambda=lambda1,thresh=1e-12)

#prediction
lm.pred<-test.mat[,names(lm.coef)]%*%lm.coef
ridge.pred<-predict(ridge.fit,s=lambda0,newx=x[test,])
lasso.pred<-predict(lasso.fit,s=lambda1,newx=x[test,])
lm.MSE<-mean((y[test]-lm.pred)^2)
ridge.MSE<-mean((y[test]-ridge.pred)^2)
lasso.MSE<-mean((y[test]-lasso.pred)^2)
compare.MSE[i,]<-c(lm.MSE,ridge.MSE,lasso.MSE)
}

MSE_avg<-apply(compare.MSE,2,mean)
std<-apply(compare.MSE,2,sd)
result<-rbind(MSE_avg,std)
return(list(result))
}
#coef 구할 경우 
#ridge.coef<-predict(ridge.fit,s=lambda0,type="coefficients")[1:ncol(orig_data),]
#lasso.coef<-predict(lasso.fit,s=lambda1,type="coefficients")[1:ncol(orig_data),]
