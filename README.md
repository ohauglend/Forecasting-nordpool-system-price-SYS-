# Forecasting-nordpool-system-price-SYS-
Examines if the Nord Pool system price (SYS) can be forecasted using VAR and dynamic regression. Moreover, it looks into the effects a possible structural break in the market has on the models’ abilities to produce reliable forecasts. 

The paper finds there to be
a unit root with drift present in the data, this
stochastic trend is dealt with by using the first
difference of the box cox transformed data. A
structural break in July 2020 is then found and
properly addressed, by including a dummy
variable in the subsequent forecasts. The
paper finds VAR to outperform dynamic
regression on the data before the break but
finds dynamic regression to better capture the
properties of the time series after the break.
Both models use the price of natural gas in
Europe as an exogenous variable. The choice
of natural gas was made based on a literature
review of the drivers of the system price, it
also turns out that the price of natural gas
granger-causes the system price. The paper
presents forecast using both models.

In order to check if the structure of the
underlying data generating process of the
time series changes at any time = t we
perform a Quandt likelihood ratio (QLR) test
(Quandt, 1960) on the data. By doing so, we
apply the Chow test (Chow, 1960) for
potential break dates within a chosen range,
and then examining the largest F-statistic
against a breakpoint value. A trimming value
of 10% from the start and 1% from the end
has been selected. This is done to ensure an
adequate number of observations in each of
the subsamples, while not filtering out the
period suspected to be most likely of
containing a break.
The figure shows a significant structural break
at observation 258 or July 2020. This is in line
with previous findings, where the irregular of
the raw data is increasing after some time
2020. Furthermore, the stationary timeseries
resembles white noise until a point in the
same year, where it looks like the variance is
increasing afterwards. 

<img align="center" img width="400" height="400" alt="image" src="https://user-images.githubusercontent.com/64472833/176753389-86e2516f-14f1-4f86-8a57-40e51f0d83c8.png">

If one were to speculate in potential reasons
for the break, it would be underlying draw in
the COVID-19 pandemic. In a 2021 paper,
(Halbrügge et al., 2021) found a significant
change in electricity consumption, generation,
prices, and trade in the German and other
European electricity systems during the
COVID-19 pandemic. It is also not surprising
that the break is identified some time (two
months) after Europe started experiencing the
effects of the pandemic, as the full effect of
changes in the market usually do not occur
instantly.

The paper uses a dynamic regression
(Wooldridge, 1990) and a vector
autoregressive (VAR) (Sims, 1972) model on
the data. These models have been selected as
they are more robust to structural breaks.
Both models use exogenous regressors and
for this paper data of the price of natural gas
in the European market obtained from iea is
used. The natural gas price in Europe is
chosen due to the fact that it has shown to
influence the system price in other literature
(Määttä & Johansson, 2011). Further, the
relationship between the prices are easily
interpretable, as natural gas is a substitute for
electricity in many cases, and visa versa,
meaning that when the price of gas goes
down/up, so will the price of electricity. The
price of natural gas in Europe is shown, in this
paper, to granger-cause the SYS, without the
relationship exibithing reverse causality. In
other words, the past values of the natural
gas price is useful in predicting the curent
value of the SYS, but not the other way
around. This is also an underlying assumption
important for using the variable as an external
regressor in VAR.
The paper does not use multiple regressors on
either model. Although this is a naïve
approach, there are multiple other factors
such as weather, temperature, the level of
nuclear- and wind power produced in Europe,
that effects the SYS, the approach is taken due
to wanting to keep the models simple. There
is also an argument that simple models, with
one exogenous regressor will set a lower base
line for how complex a model needs to be to
be able to produce a reliable forecast of the
system price after the break.

The following section will compare the
performance (on the test set) of the two
models, by first using a visual inspection and
then performance metrics. In more detail, the
scale dependent RMSE (mean squared error)
and MAE (mean absolute error) will be used,
as well as the non-scale dependent MAPE
(mean percentage error) and MASE (mean
absolute scaled error). In addition, tests for
serial autocorrelation ((multivariate) LjungBox/PT. asymptotic test), heteroskedasticity
amongst model residuals (arch test and
Breusch-Pagan test), normal distribution
amongst residuals (uni- and multivariate
Jarque-Bera tests and multivariate skewness
and kurtosis tests), and a test for structural
breaks in the residuals (OLS-CUSUM) will be
presented.

VAR model:

Before using the model to forecast on the test
set the VARselect is used to find the optimal
lag for the regression equation. The lag
selected by this paper was 43, seeing as this
minimized the Bayesian information criterion
(BIC)/Schwarz criterion.
When looking at the plotted estimation
against the test set, shown by Figure 7, it is
clear that the model is not able to capture the
evolution of the series after the structural
break. The prediction starts of by following
the test set closely, before failing to capture
the development some time before the break.
As we have seen in previous sections, the time
series also exhibited (lesser) instabilities just
before the break, so the prediction gap is not
surprising. Although the model fails to capture
the drop in early 2020, the test set is still
within the 95% confidence interval of the
forecast. This is not the case for the
development after the break. The model
initially captures the price-recovery from
earlier, but it fails to address the following
price surge that is present in 2021. This peak
also goes outside the confidence interval.
Overall, it looks like the model is somewhat
conservative on the fluctuations on the data
before the break. It fluctuates less than a
“normal” 2,5-year period in the time series
would, which is an indication that it does not
do as good job fitting the pre-break data. The
conservativeness can, however, be partially
explained by the confusion the model is likely
experiencing just before the breaking point.

<img align="center" img width="400" height="400" alt="image" src="https://user-images.githubusercontent.com/64472833/176753993-fe983579-8195-4326-b88f-61be5d1da013.png">

Table 3 shows an overview of the
performance metrics for the VAR model.

<img align="center" img width="300" height="300" alt="image" src="https://user-images.githubusercontent.com/64472833/176754105-d08ea08b-91bb-4b54-a347-63cc7a40797b.png">

Since the RMSE and MAE are scale
dependent, these will be commented on
when comparing the performance metrics of
the dynamic regression mode, as the same
test set have been used. A MAPE score of 1.22
is an indication that our model does not fit the
test set well, as the one point ahead forecast
is of by 122% on average (Swanson, 2015).
The MASE tells the same story, a metric of
2.23 shows that the model performs worse
(has a lower MAE) than the naïve forecast in
sample.
When looking at the tests, the model presents
no serial autocorrelation in the residuals. The
arch test reveals that the residuals are
homoscedastic, however they are not
normally distributed with both skewedness
and kurtosis values diverging from the normal
distribution. Finally, the OLS-CUSUM test
revealed no structural breaks in the residuals.
The VAR model does a reasonable job of
predicting the test set before the break,
however it fails to capture the evolution in the
time series after the break. It would not
produce reliable forecasts of the system price.

Dynamic regression

Before we can use this model to predict the
test set, we need a regression model with
ARIMA errors, for this we use the auto.ARIMA
function. The model selected by the
auto.ARIMA function is a regression with
ARIMA(1,1,2) errors. When predicting the test
set the paper uses the true values of the
natural gas price at time of the test set rather
than a forecast. This is done for simplicity
reasons, but also in order to not let the
model’s performance be influenced by this
estimate. If the model is to be used to
forecast beyond the horizon of the test set, an
estimation of the exogenous regressor would
be needed.
When looking at the plotted estimation of the
model against the test set, as shown by Figure
8, it is clear that neither the dynamic
regression does a good job of capturing the
properties of the time series after the break.
It is, however, clear that the model captures
more of the price surge in 2021/22 than the
VAR model did. The dynamic regression
model is less complex, it is a lot smoother
than both the VAR and the real data. From the
visual inspection, the VAR gives a more
realistic feel of the data.

<img align="center" img width="400" height="400" alt="image" src="https://user-images.githubusercontent.com/64472833/176754276-b4477165-7e43-4b98-8969-8bd96d6f22a1.png">

Table 4 shows an overview of the
performance metrics for the dynamic
regression model.

<img align="center" img width="300" height="300" alt="image" src="https://user-images.githubusercontent.com/64472833/176754322-61ca0d5c-be41-4701-870d-853e3046c4e1.png">

Looking at the metrics, they favour the
dynamic regression model, as all values
except for the MAPE are lower. Even still, this
model does not fit the test set well, the one
point ahead forecast is of by 144%, and it
performs worse than the naïve forecast in
sample, as shown by the MASE score.
Looking at the tests, the model exhibits no
autocorrelation in the residuals. Further, the
Breusch-Pagan test shows that the residuals
are homoscedastic. The Jarque-Bera test
reveals that the residuals are not normally
distributed, they have a high kurtosis (8.6),
and are somewhat skewed to the right (0.95).
Finally, the CUSUM test showed that there are
no structural breaks in the residuals.
Overall, the dynamic regression does a better
job of modelling the test set, which is largely
due to a better performance after the break.
Something that is shown by both the visual
inspection and the test statistics. Neither the
dynamic regression model will produce
reliable forecasts for the system price after
the break.

![image](https://user-images.githubusercontent.com/64472833/176754526-fe080fda-552b-4cd1-97e2-22e3aab845f8.png)

![image](https://user-images.githubusercontent.com/64472833/176754533-5c1e354a-5de2-4f56-add7-165c94f20c16.png)

The above forecasts of two years have been
generated using the models estimated for the
training data, and with a dummy variable set
to 1 after the break. For the dynamic
regression the mean price of natural gas has
been used as the exogenous regressor. We
can see that the dynamic regression estimates
a lower price than the VAR. Since this paper
has shown that the models cannot produce
reliable forecasts after the break, the
forecasted data will not be discussed any
further.

In this paper we have seen that a structural
break occurred in the system price of
Nordpool in May 2020. A hypothesis is made
that the cause of this break is related to the
impact of the COVID-19 pandemic. The paper
has shown that by using the level of natural
gas prices in Europe as an exogenous
regressor, neither VAR nor dynamic
regression can produce reliable forecasts of
the system price after the break. The VAR
model predicted the test set better before the
break, hower the dynamic regression captures
more of the evolution after the break. Overall
the dynamic regression best predicted the
test set, outperforming the VAR model on
RMSE, MAE and MASE. Neither model
produced good predictions for the test set, as
shown by the poor values of the MAPE and
MASE.
Neither the VAR nor the dynamic regression
model shown autocorrelation or
heteroscedacicity in the residuals. The
residuals of the models were not normally
distributed, and did not contain any structural
breaks.
The implications of this study is clear, several
forecasting tools that previously could be
used to produce reliable forecasts of the
system price no longer holds the same
credibility. This paper shows that the
structural break in July 2020 

Limitations and future work

The main limitation of this study is that only
the level of natural gas prices has been used
as an exogenous regressor in both models.
This is a limitation as the models do not take
other factors such as weather, temperature,
and the level of windpower and nuclear
power produced in Europe into account.
Although this paper acts as a lower base line,
showing that the models could not produce
reliable forecasts with only using the one
external regresssor, future exploration is
needed. In particular, including one or several
of the above mentioned factors in the models
is a recommended starting point. 








