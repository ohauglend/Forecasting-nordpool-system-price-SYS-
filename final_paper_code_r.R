

#### Final Paper code ####

## prep ####

# clearing memory
rm(list=ls())

library(fpp3)
#install.packages('fpp2', dependencies = TRUE)
library(fpp2)
library(ggplot2)
library(forecast)
library(seasonalview)
library(seasonal)
library(tsibble)
library(dplyr)
library(urca)
library(vars)
library(tsibble)
library(dplyr)
#install.packages('EnvStats')
library(EnvStats)
library(tidyverse)
library(tseries)
library(forecast)
#install.packages('CPAT')
library(CPAT)
#install.packages('moments')
library(moments) 
library(Metrics)



s <- read.csv("C:/Users/ohaug/OneDrive - CBS - Copenhagen Business School/div cbs/Predictive analytics/Final project/Data/Final_data_sys_eur/final_df_YMD", 
              colClasses=c("character","numeric"),
              sep = ",",
              dec = ".")


s_ts <- s %>% 
  mutate(Month = yearmonth(Month)) %>%
  as_tsibble(index = Month)


s_ts %>%
  ggplot(aes(x=Month, y=SYS)) + geom_line() +
  labs(title = "Figure 1",
       subtitle = "Monthly elspot prices norpool",
       x = "Moths", y ="SYS")+
  theme(axis.text.y = element_text(size = 10),
        axis.text.x = element_text(size = 10),
        axis.title = element_text(size = 14),
        plot.title = element_text(size=22),
        plot.subtitle = element_text(size=15)) 



seats_dcmp <- s_ts%>%
  model(seats = X_13ARIMA_SEATS(SYS ~ seats())) %>%
  components()


autoplot(seats_dcmp) +
  labs(title = "Figure 2",
       subtitle = "Decomposition using SEATS")+
  theme(axis.text.y = element_text(size = 10),
        axis.text.x = element_text(size = 10),
        axis.title = element_text(size = 14),
        plot.title = element_text(size=22),
        plot.subtitle = element_text(size=15)) 


autoplot(acf(s_ts$SYS, lag.max = 64))+
  labs(title = "Figure 3",
       subtitle = "Autocorrelation raw data",
       x = "lags")+
  theme(axis.text.y = element_text(size = 10),
        axis.text.x = element_text(size = 10),
        axis.title = element_text(size = 14),
        plot.title = element_text(size=22),
        plot.subtitle = element_text(size=15)) 


#Calculating lambda using guerrero
lambda <- s_ts%>%
  features(SYS, features = guerrero) %>%
  pull(lambda_guerrero)

#Printing the box_cox value
print(lambda)


s_ts %>%
  ggplot(aes(x=Month, y=SYS)) + geom_line() +
  labs(title = "Figure 4",
       subtitle = "Timeseries box_cox transformed",
       x = "Moths", y ="Transformed SYS")+
  theme(axis.text.y = element_text(size = 10),
        axis.text.x = element_text(size = 10),
        axis.title = element_text(size = 14),
        plot.title = element_text(size=22),
        plot.subtitle = element_text(size=15)) 


myseries %>% autoplot(SYS %>% difference()) +
  labs(title = "Figure 5",
       subtitle = "Timeseries differentiated on lag 1 no box_cox",
       x = "Month", y = "Difference on the transformed SYS")+
  theme(axis.text.y = element_text(size = 6),
        axis.text.x = element_text(size = 9),
        axis.title = element_text(size = 12)) 




#Performing all tests, First non-transformed data

s$Month <- as.Date(s$Month)
myseries <- tsibble(s)

summary(ur.df(myseries$SYS, type = "trend")) 

summary(ur.df(myseries$SYS, type = "drift")) 

summary(ur.df(myseries$SYS, type = "none")) 

#Moving onto kpss
summary(ur.kpss(myseries$SYS, type = "tau")) #trend

summary(ur.kpss(myseries$SYS, type = "mu")) # none 



## Transforming the data using box_cox
s$Month <- as.Date(s$Month)
s$SYS = box_cox(s$SYS, lambda)
myseries <- tsibble(s)


#Performing all tests again
summary(ur.df(myseries$SYS, type = "trend")) 

summary(ur.df(myseries$SYS, type = "drift")) 

summary(ur.df(myseries$SYS, type = "none")) 

#Moving onto kpss
summary(ur.kpss(myseries$SYS, type = "tau")) #trend

summary(ur.kpss(myseries$SYS, type = "mu")) # none 



## Transforming the series by taking the first difference and repeating the tests

summary(ur.df(diff(myseries$SYS), type = "trend")) 

summary(ur.df(diff(myseries$SYS), type = "drift")) 

summary(ur.df(diff(myseries$SYS), type = "none")) 

#Moving onto kpss
summary(ur.kpss(diff(myseries$SYS), type = "tau")) #trend

summary(ur.kpss(diff(myseries$SYS), type = "mu")) # none 


## Structural break tests


qlr <- Fstats(diff(ts(box_cox(myseries$SYS, lambda), start = 1999, frequency = 12)) ~ 1, from = 0.1, to = 0.99) 


test <- sctest(qlr, type = "supF")
test
breakpoints(qlr, alpha = 0.05)
plot(qlr, alpha = 0.05, main = "Figure 6
     Examening structural break(s) of time series", 
     xlab = "Time", ylab = "F statistics")
lines(breakpoints(qlr))
text(2005, 10.5, "5% critical value")

stability(as.ts(qlr$Fstats), type = "OLS-CUSUM")




## predicting the test set using VAR


df7 <- data.frame(myseries$SYS, oil_price$MCOILBRENTEU, row.names = myseries$Month)

#Adding dummy varaible after the break
df7$Dummy <- ifelse(row.names(df) < "2020-07-01", 0,1)

x_train = subset(df7, row.names(df) < "2018-10-01")
x_test = subset(df7, row.names(df) >= "2018-10-01")

VARselect(as.ts(x_train[,1:2]), lag.max=150,
          type="both")[["selection"]]


var7_2 <- VAR(as.ts(x_train[,1:2]), p=43, type="const", ic = "sc")

#Testing for autocorrelation
serial.test(var7_2, lags.pt=50, type="PT.asymptotic")


#Testing for heteroscedasticity if p > 0.05 -> no hetero
arch.test(var7_2, lags.multi = 20, multivariate.only = TRUE)

#Testing for normal distribution of the residuals if p > 0.05 -> normally dist
#running 3 normality tests
normality.test(var7_2, multivariate.only = TRUE)


#Testing for structural breaks in the residuals - test for model stability p > 0.05 -> no break
plot(stability(var7_2, type = "OLS-CUSUM"))


#Predicting the test set
f_7 <- predict(var7_2, n.ahead = 44, xreg = length(cbind(x_test$oil_price.MCOILBRENTEU)), ci = 0.95, dumvar = as.matrix(future_dum))


#Producing metrics
#rmse(data$actual, data$predicted)
rmse(x_test$myseries.SYS, f_7$fcst$myseries.SYS[,1])

#mae(actual, predicted)
mae(x_test$myseries.SYS, f_7$fcst$myseries.SYS[,1])

#mape(actual, predicted)
mape(x_test$myseries.SYS, f_7$fcst$myseries.SYS[,1])

#mase(actual, predicted, step_size = 1)
mase(x_test$myseries.SYS, f_7$fcst$myseries.SYS[,1], step_size = 1)


autoplot(f_7)+autolayer(ts(x_test$myseries.SYS, start = 233, end = 281)) +
  labs(title = "Figure 7",
       subtitle = "Forecasting the test set using VAR",
       x = "Moths")+
  theme(axis.text.y = element_text(size = 10),
        axis.text.x = element_text(size = 10),
        axis.title = element_text(size = 14),
        plot.title = element_text(size=22),
        plot.subtitle = element_text(size=15))+
  geom_vline(xintercept = 254,  linetype = "dashed")+
  geom_text(label = "Time of structural break", aes(x = 200, y = 150))



## predicting the test set using dynamic regression

df4 <- data.frame(myseries$SYS, oil_price$MCOILBRENTEU, row.names = myseries$Month)


df4$Dummy <- ifelse(row.names(df) < "2020-07-01", 0,1)

fx1 <- auto.arima(as.ts(x_train$myseries.SYS), xreg = cbind(as.ts(x_train$oil_price.MCOILBRENTEU)))

fc <- forecast(fx1,  xreg = length(cbind(x_test$oil_price.MCOILBRENTEU)) +1:44, fan = TRUE, level =0.95)

autoplot(fc)  + autolayer(ts(x_test$myseries.SYS, start = 233, end = 277))+
  labs(title = "Figure 8",
       subtitle = "Forecasting the test set using dynamic regression",
       x = "Moths")+
  theme(axis.text.y = element_text(size = 10),
        axis.text.x = element_text(size = 10),
        axis.title = element_text(size = 14),
        plot.title = element_text(size=22),
        plot.subtitle = element_text(size=11.5))+
  geom_vline(xintercept = 254,  linetype = "dashed")+
  geom_text(label = "Time of structural break", aes(x = 180, y = 150)) 



#rmse(data$actual, data$predicted)
rmse(x_test$myseries.SYS, fc$mean)

#mae(actual, predicted)
mae(x_test$myseries.SYS, fc$mean)

#mape(actual, predicted)
mape(x_test$myseries.SYS, fc$mean)

#mase(actual, predicted, step_size = 1)
mase(x_test$myseries.SYS, fc$mean, step_size = 1)



#Ljung_box test - autocorrelation
Box.test(as.ts(fc$mean), lag = 1, type = "Ljung")

#BP test heteroscedasticity
lmtest::bptest(fc$model)

#Normality tests - Jarque Bera, skewness, kurtosis
jarque.bera.test(fc$residuals)
skewness(fc$residuals)
hist(fc$residuals)
kurtosis(fc$residuals)

#Test for structural break
CUSUM.test(fc$residuals)


## Forecasting both models


fx <- auto.arima(as.ts(df4$myseries.SYS), xreg = cbind(as.ts(df4$oil_price.MCOILBRENTEU), as.ts(df4$Dummy)))

fc1 <- forecast(fx, xreg = cbind(rep(mean(x_test$oil_price.MCOILBRENTEU),24), rep(1,24)))

autoplot(fc1)  + 
  labs(title = "Figure 9",
       subtitle = "Forecast using dynamic regression",
       x = "Moths")+
  theme(axis.text.y = element_text(size = 10),
        axis.text.x = element_text(size = 10),
        axis.title = element_text(size = 14),
        plot.title = element_text(size=22),
        plot.subtitle = element_text(size=20))


var6_4 <- VAR(as.ts(df7[,1:2]), p=4, type="const", ic = "sc", exogen = df7$Dummy)

autoplot(forecast(var6_4, h = 24, dumvar = as.matrix(future_dum)))+ 
  labs(title = "Figure 10",
       subtitle = "Forecast using VAR",
       x = "Moths")+
  theme(axis.text.y = element_text(size = 10),
        axis.text.x = element_text(size = 10),
        axis.title = element_text(size = 14),
        plot.title = element_text(size=22),
        plot.subtitle = element_text(size=20))





