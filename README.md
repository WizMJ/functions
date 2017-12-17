### 개요

본 사용자 함수는 데이터 특성에 따른 최적의 머신러닝 모델링을 선택하기 위해 작성되었다. 본 함수의 주요 기능은 다음과 같다.

* 최적 머신러닝 모델링에 해당하는 주요 파라미터를 구할 수 있다.
* 관측치 갯수가 적을 경우에도(100개 이하) 최적 모델링을 추론가능하다. 
* 최적화된 머신러닝 모델들을 서로 비교해 가장 우수한 최종 머신러닝 모델링을 선택한다. 

본 사용자 함수를 통해 머신러닝 모델링 선택시 필요한 시간을 최소화할 수 있다. 본 사용자 함수에 적용된 모델링은 다중선형회귀, 능형회귀(Ridge), 라쏘(Lasso), 랜덤포레스트이며 최적치 산출을 위해서는 일반적으론 교차 검증(Cross Validation)을 100개 이하의 관측치일 경우 붓스트랩(Bootstrap)이 적용되었다.

### 사용자 함수별 목적

전체 사용자 함수와 각 함수별 목적은 다음와 같다. 

번호|함수명     | 목 적                                                                              |비 고
----|-----------|------------------------------------------------------------------------------------|-------------------
1.  |bootlm_coef|붓스트랩을 통해 선형회귀 계수를 구함                                                |관측치 100개 이하시
2.  |cvlm_var   |CV를 통해 다중회귀에서 교차검증 오차(RSS)가 가장 최소인 설명변수 갯수를 찾음        |
3.  |bootlm_var |붓스트랩을 통해 다중회귀의 MSE가 최소인 변수 갯수를 찾음                            |관측치 100개 이하시
4.  |cvreg_lam  |CV를 통해 능형회귀와 라쏘의 최적 수축 파라미터(lambda)를 구함                       |
5.  |bootreg_lam|붓스트랩을 이용, 능형회귀와 라쏘의 최적 수축파라미터를 구함                         |관측치 100개 이하시
6.  |compare_lm |데이터의 2/3는 훈련, 1/3은 검정으로 구별해 선형, 능형, 라쏘 회귀간의 MSE를 비교함   |30번 시뮬레이션 비교
7.  |oobrf_mtry |변수갯수(mtry)에 따른 랜덤포레스트의 OOB(Out of Bab)오차가 가장 적은 변수갯수를 찾음|30번 시뮬레이션 비교 

함수명은 검정방법, 적용모델링, 결과값 순으로 이름 지어져 사용자가 함수명을 통해 함수의 기능을 쉽게 알 수 있게 하였다. 

+ 예: bootlm_coef은 붓스트랩(boot)을 통해 선형회귀(lm)의 계수(coef)를 구하는 것 

cvlm_var(2번)과 bootlm_var(3번) 그리고 cvreg_lam(4번)과 bootreg_lam(5번)은 결과 값은 서로 같으나 그것을 검정하는 방법은 서로 다르다. 보통 관측치가 100개 이하의 적은 데이터일 경우 모집단 추론에 오차가 커지기 쉽다. 따라서 일반적인 경우에는 cv로 시작하는 함수(2번과 4번)를 사용하고 데이터가 적을 경우엔 붓스트랩 함수(3번, 5번)를 사용한다. 

### 사용 방법

각 함수의 사용법은 다음과 같다. 

번호|함수명     | 사용 방법                          | 입력 값(Input)                                        |비고
----|-----------|------------------------------------|-------------------------------------------------------|----------------
1.  |bootlm_coef|bootlm_coef(data)                   | -                                                     |
2.  |cvlm_var   |cvlm_var(data, k, var)              |k: cv folds수, var: 최대 변수 갯수                     |var 최대값은 19
3.  |bootlm_var |bootlm_var(data,R)                  |R: sampling 갯수                                       |R은 300이상충분
4.  |cvreg_lam  |cvregular_lam(data,k,no.lam,al)     |no.lam: lambda갯수, al:0은 능형, 1은 라쏘              |
5.  |bootreg_lam|bootreg_lam(data,no.lam,al, R)      |-                                                      |
6.  |compare_lm |compare_lm(data,var,lambda0,lambda1)|var: 회귀변수갯수, lambda0과 1는 각각 능형,라쏘의lambda|
7.  |oobrf_mtry |oobrf_mtry(data,ntree)              |ntree: bootstrap 횟수                                  |

### 입력값에 대한 추가적인 참고사항

+ cvreg_lam(4번)함수는 0.01에서 10^8 범위에서 오차가 최소인 lambda를 찾는다. 계산에 필요한 시간을 고려하여 일반적으로 100개의 lamda 후보군(상기 입력값의 no.lam)을 사용 한다. 다만 선정된 lambda가 클 경우(1000이상)엔 결과보다 더 오차를 줄이는 lamda가 존재할 수 있다. 따라서 이 경우엔 no.lam도 큰 값(예: 1000)을 사용한다.    

+ oobrf_mtry(7번) 함수의 붓스트랩 횟수(ntree)는 보통 300번 이상에서 오차가 수렴된다. 그러나 데이터수 및 변수 갯수에 따라 붓스트랩 횟수가 적을 때 오차가 최소가 될 수 있다. 이 경우를 위해 log(데이터수 x 변수갯수)가 1보다 크면 300이상을 1보다 작으면 300이하를 사용하는 것을 기준으로 하면 유용하다. 그러나 머신러닝 모델링 대부분이 그렇듯이 붓스트랩 횟수 또한 명확한 기준점이 존재하지 않는다. 우선적으로 plot(rf)을 통해 오차가 수렴하는 붓스트랩 횟수를 먼저 확인할 필요가 있다. 앞서 언급한 기준은 참고로 사용한다. 

### 결과값(Output) 및 Summary

각 함수별 결과값은 다음과 같다. 
        
**1. bootlm_coef**

+ ori.coef: lm함수 사용시 회귀 계수
+ boot.coef: boostrap 1,000번시 회귀 계수
+ bias: boot.coef - ori.coef
+ std.error: 표준오차
+ t.value, p.value: t 통계량 및 p-value
+ plot은 boostrap 사용 시의 boxplot과 평균(점선), lm함수 사용시의 계수(빨간 점선)임(절편포함 회귀계수 최대 9개 까지 가능)

**2. cvlm_var**

+ MSE_avg: 각 변수 갯수별 교차검증 MSE의 평균 값 (30번 sampling x folds 수)
+ MSE_sd: 상기 MSE_avg 각 변수 갯수별 표준오차
+ Top3: MSE_avg 가장 작은 3가지 변수와 그 값

**3. bootlm_var**

+ MSE_avg: 각 변수 갯수별 R개의 MSE의 평균 
+ MSE_sd: 상기 MSE_avg의 표준오차
+ Top3: MSE_avg가 가장 작은 3가지 변수와 그 값

**4. cvreg_lam**

+ MSE_avg: 각 lambda 별 교차검증 MSE의 평균값 (30번 Sampling)
+ MSE_se: 상기 MSE_avg 각 lambda별 표준오차
+ Top3lambda: 상위 3개
+ Top1Coef: 최소 MSE_avg를 가지는 lambda에서의 회귀 계수

**5. bootreg_lam**

+ MSE_avg: 각 lambda별 R개 MSE의 평균 
+ MSE_sd: 상기 MSE_avg 각 lambda별 표준오차
+ Top3: MSE_avg가 가장 작은 3가지 변수와 그 값

**6. compare_lm**

+ lm, Ridge, Lasso의 MSE의 평균과 표준편차

**7. oobrf_mtry**

* OOB.Error: 각 mtry에 대응하는 oob.error을 표시
* importance: IncMSE는 주어진 변수가 모델에서 제외될 때 OOB.Error의 평균 감소량
* IncNodePurity는 주어진변수에 의한 분할시 RSS의 평균 감소량
* rf: 최소 OOB를 가지는 mtry 적용시의 randomForest결과

