
bootreg_lam<-function(data,no.lam,al,R){

form<-as.formula(paste0(colnames(data)[ncol(data)],"~."))
x<-model.matrix(form,data)[,-1]  #절편은 제거해야함
y<-data[,ncol(data)]

MSE_oob<-matrix(NA,R,no.lam,dimnames=list(NULL,paste(1:no.lam)))
sh<-10^seq(8,-2,length=no.lam)
for (j in 1:R){
set.seed(j)
train<-sample(nrow(data),nrow(data),replace=T)
oob<-(-as.numeric(names(table(train))))

#prediction
ridge.fit<-glmnet(x[train,],y[train],alpha=al,lambda=sh,thresh=1e-12)
pred<-predict(ridge.fit,s=sh,newx=x[oob,])
MSE_oob[j,]<-apply((y[oob]-pred)^2,2,mean)
}

MSE_avg<-apply(MSE_oob,2,mean)
std<-apply(MSE_oob,2,sd)
Top3<-head(sort(MSE_avg),3)
out<-glmnet(x,y,alpha=al) #sh별도 지정안해도 됨. 아래 coef에서 s를 지정하기 때문
par(mfrow=c(1,2))
plot(MSE_avg,type='b')
plot(out)
#Top1 Coef.
coef<-predict(out,s=sh[as.integer(names(Top3)[1])],type="coefficients")[1:ncol(data),]
names(Top3)<-sh[as.integer(names(Top3))]
return(list(MSE_avg=MSE_avg,MSE_se=std,Top3lambda=Top3,Top1Coef=coef))
}
