bootlm_coef<-function(data){
  library(boot)
  bootstrap<-function(data,index){ #1에서 nrow까지 nrow만큼 복원추출
  return(coef(lm(as.formula(paste0(colnames(data)[ncol(data)],"~.")),
                                  data,subset=index)))
  }
  set.seed(1)  #초기값만 같게 하기 위함
  output<-boot(data,bootstrap,R=1000) # 1000번 반복
  #결과값
  ori.coef<-output$t0
  boot.coef<-colMeans(output$t)
  bias<-boot.coef-ori.coef
  std.error<-apply(output$t,2,sd)
  t.value<-boot.coef/std.error
  p.value<-2*(1-pt(abs(t.value),nrow(data)-length(ori.coef)))
 
  if (length(ori.coef)==1){
    dim<-1
    } else if (length(ori.coef)<=4){
    dim<-2
    } else {
    dim<-3
    } 
  par(mfrow=c(dim,dim))  # 변수 (intercept포함 1~ 9번 까지 plot)
  length<-length(ori.coef)
  if (length>9){
    length<-9}
  for (i in 1:length){
  boxplot(output$t[,i])
  abline(boot.coef[i],0,lty=2,lwd=1.5)  # bootstrap의 average
  abline(ori.coef[i],0,col="red",lty=2,lwd=1.5) #lm공식의 average
  }
  return(cbind(ori.coef,boot.coef,bias,std.error,t.value,p.value))
  }
