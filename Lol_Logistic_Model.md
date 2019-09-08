---
title: "Predicting Wins in League of Legends"
author: "Diego Angulo Quintana"
date: "August 30, 2019"
output: 
  html_document: 
    keep_md: true
    toc: yes
    toc_float: true
    code_folding: hide
---



<div class="figure">
<img src="Lol_Logistic_Model_Cover.jpg" alt="Seoul 2014 - League of Legends World Championship Finals - Samsung White VS Star Horn Royal Club" width="100%" height="45%" />
<p class="caption">Seoul 2014 - League of Legends World Championship Finals - Samsung White VS Star Horn Royal Club</p>
</div>
## Background
League of Legends (abbreviated LoL) is a multiplayer online battle arena video game developed and published by Riot Games for Microsoft Windows and macOS. The goal in the game is usually to destroy the opposing team's "Nexus", a structure that lies at the heart of a base protected by defensive structures.

League of Legends has an active and widespread competitive scene. In North America and Europe, Riot Games organizes the League Championship Series (LCS), located in Los Angeles and the League of Legends European Championship (LEC), located in Berlin respectively. Similar regional competitions exist in China (LPL), South Korea (LCK), Taiwan/Hong Kong/Macau (LMS), and various other regions. These regional competitions culminate with the annual World Championship.

##Executive Summary##
In this report, I fitted a classification model that predicts the winning probability for a team, based on data from different professional regional League of Legends leagues from around the world in 2019.

**You can check the final model in a Shiny App** [HERE](https://diegoangulo.shinyapps.io/Lol_Win_Prob/).

## About the Data 
The data was extracted from [Oracle's Elixir League of Legends Esports Statistics](http://oracleselixir.com/). It comprises game results from de CBLoL, LCK, LCS, LEC, LMS and MSI in 2019. 

The data has 2734 observations on 5 factor variables and 2 numeric variables. <br/> 

 - result: The game result.  <br/>
 - side: Map side (Blue or Red). <br/> 
 - elementalsd: Difference in Elemental Dragons against the opposing team. <br/> 
 - barond: Difference in Baron Nashors against the opposing team. <br/> 
 - wardratio: All kinds of Wards placed / All kinds of wards killed by oponent. <br/> 
 - gspd: The Gold Spent Percentage Difference. 

**Data Authors:** <br/>
Tim "Magic" Sevenhuysen of OraclesElixir.com. <br/> 

Special thanks to the above mentioned for allowing their data free of charge to be used by analysts, commentators, and fans.

**Important:** <br/>
Some of the variables were not in the original dataset. **To know more about how I cleaned and arranged the raw data, and how I built some of the variables in the list, check out my R code** [HERE](https://github.com/Diego-Angulo/Predicting-Wins-in-League-of-Legends/blob/master/Getting%20And%20Cleaning%20the%20Data%20(R%20code).R).



## Data Loading 

```r
# Setting Working Directory
setwd("~/Diego/Analytics/LoL Analytics/Logistic Model")

# Loading Libraries
library(dplyr)
library(readxl)

# Loading the .xlsx dataset into RStudio.
ModelData <- read_excel(path = "~/Diego/Analytics/LoL Analytics/Logistic Model/Extra Files/ModelData.xlsx",
                    col_types = c(rep("guess", 5), rep("numeric", 2)), sheet = 1, col_names = TRUE)

# Giving Format To Factor Variables
ModelData$result <- as.factor(ModelData$result)
ModelData$side <- as.factor(ModelData$side)
ModelData$elementalsd <- as.factor(ModelData$elementalsd)
ModelData$elderd <- as.factor(ModelData$elderd)
ModelData$barond <- as.factor(ModelData$barond)
```

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> result </th>
   <th style="text-align:left;"> side </th>
   <th style="text-align:left;"> elementalsd </th>
   <th style="text-align:left;"> elderd </th>
   <th style="text-align:left;"> barond </th>
   <th style="text-align:right;"> wardratio </th>
   <th style="text-align:right;"> gspd </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Defeat </td>
   <td style="text-align:left;"> Blue </td>
   <td style="text-align:left;"> [-3,3] </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:left;"> -1 </td>
   <td style="text-align:right;"> 2.28 </td>
   <td style="text-align:right;"> -0.027 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Victory </td>
   <td style="text-align:left;"> Red </td>
   <td style="text-align:left;"> [-3,3] </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 2.47 </td>
   <td style="text-align:right;"> 0.027 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Victory </td>
   <td style="text-align:left;"> Blue </td>
   <td style="text-align:left;"> [-6,-4] </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:left;"> [2,4] </td>
   <td style="text-align:right;"> 2.15 </td>
   <td style="text-align:right;"> 0.046 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Defeat </td>
   <td style="text-align:left;"> Red </td>
   <td style="text-align:left;"> [4,6] </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:left;"> [-4,-2] </td>
   <td style="text-align:right;"> 2.05 </td>
   <td style="text-align:right;"> -0.046 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Defeat </td>
   <td style="text-align:left;"> Blue </td>
   <td style="text-align:left;"> [-3,3] </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:left;"> -1 </td>
   <td style="text-align:right;"> 2.62 </td>
   <td style="text-align:right;"> 0.034 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Victory </td>
   <td style="text-align:left;"> Red </td>
   <td style="text-align:left;"> [-3,3] </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 2.29 </td>
   <td style="text-align:right;"> -0.034 </td>
  </tr>
</tbody>
</table>

## Exploratoy Data Analysis 
We can start looking at how the observations are distributed by `result` (game result) VS each variable, to make sure that they are all represented by a number of games. Because of this, `barond` (Baron Nashors difference) and `elementalsd` (Elemental Dragons Difference) have grouped levels to gain consistency and statistical significance.

Variables.  <br/> 

   - **Results:** There are 1367 victories and 1367 defeats in our dataset. <br/> 
   - **Map Side:** The blue side of the map has been the most victorious side in the game historically. By looking at our Frequency VS Map Side chart, we can tell that this fact is present in the dataset. <br/> 
   - **Elemental Dragons & Nashors:**  It is very common to kill several Elemental Dragons and at least one Baron Nashor during one game. The greater difference in Elemental Dragons and Baron Nashors against the opposing team, the more chance of winning the team will have, and vice versa. The biggest differences reports the lower frequencies as it's very difficult in professional gamming to get such advantage against other teams. <br/> 
   - **Elder Dragons:** Elder dragons are a harder objective to obtain compared to Elemental Dragons and Baron Nashors. As they are not only powerful, but also spawn only two times in game. That explains the high frequency in the "0" level. <br/> 
   - **Gold Spent Percentage Difference:** It is obvious that chances on winning the game increase if the gold spent difference against the opposing team increases. This means that if the `gspd` is positive, the team has got more achieved objectives, or has scored more kills/assistances during the game, or both. <br/>
   - **Wardratio:** As previously defined, wardratio is the rate between all kinds of wards placed, and all kinds of wards killed by the opposing team. In other words, the number of wards placed by each ward killed by the opponent. As wards provide extra vision in the map, this helps teams to gain some advantages over the other. So, the team that has more vision in game, should have better chances on winning. However, it is not just about the amount of wards placed that helps, but also the quality of the spot where each ward is placed. And according to the chart of this variable, it appears to be a considerable difference between victories and defeats.  
<img src="Lol_Logistic_Model_files/figure-html/unnamed-chunk-3-1.png" style="display: block; margin: auto;" />

## Data Partitioning for Prediction  <br/>
We are preparing the data for prediction by splitting `ModelData` into 75% as `ModelTrain`, and 25% as `ModelTest`. This splitting will serve to test the models accuracy.

To predict the outcome, we will use three different methods based on `ModelTrain` dataset:
 - Logistic Regression
 - Random Forests
 - Decision Trees

Then, they will be applied to the `ModelTest` dataset to compare accuracies. The best model will be used to predict the winning team.


```r
#Partitioning
library(caret)        
set.seed(12345) 

split <- createDataPartition(ModelData$result, p = 0.75, list = FALSE)

ModelTrain <- ModelData[split, ]
ModelTest <- ModelData[-split, ]
```
## Logistic Regression 
### 1 - Setting the Baselines  <br/>  
 - Before fiting any model, we first need to set the reference (baseline) category for all the factor variables to make the model easier to interpret. <br/> 
 - As for the **side of the map** variable (`side`), we set the "Blue" side as our intercept for this regressor. <br/> 
 - The rest of the variables refer to the difference in number of **Elemental Dragons (`elementalsd`), Elder Dragons (`elederd`) and Barons Nashors (`barond`)** against the opposing team.  <br/> 
 - The middle levels for this variables ( "[-3,3]", "0" and "0") are set as the intercept for each regressor. This is due to the way the game works, If the difference is 0 or is a number within the middle level of the variable, the chances of winning are neutral. This makes the coefficients of the model easier to interpret, being positive numbers as higher chances on winning, and negative as lower chances on winning.

```r
# Re Leveling Categorical Variables as the models' intercept
ModelTrain$side <- relevel(ModelTrain$side, ref = "Blue")
ModelTrain$elementalsd <- relevel(ModelTrain$elementalsd, ref = "[-3,3]")
ModelTrain$elderd <- relevel(ModelTrain$elderd, ref = "0")
ModelTrain$barond <- relevel(ModelTrain$barond, ref = "0")
```
### 2 - Model Fit:  <br/> 
Let's start by trying to predict a victory in League of Legends using all the variables available. We are storing the output in a variable called `logistic`.

```r
# Base Model Fit
logistic <- glm(result ~ side + elementalsd + elderd + barond + gspd + wardratio,
                data = ModelTrain, family ="binomial")
```
### 3 - Model Analysis:  <br/> 
 - **Deviance Residuals:** The summary of the deviance residuals looks good since they are close to being centered on 0 and are roughly symmetrical.<br/> 
 - **p-values:** All the variables and levels are bellow 0.05. Which means that its log(odds) and log(odds ratios) are statistically significant. <br/> 
 - **Fisher Scoring iterations:** It took 7 iterations for the model to converge on the maximun likelihood estimates for the coeficients.
 - **Some coefficient analysis examples:**
    - **Map Side:** holding the rest of the variables at a fixed value, the log(odds ratio) of the odds of winning a League of Legends game playing in the red side of the map (`sideRed` = 1), over the odds of winning a game playing in the blue side of the map (`sideRed` = 0) is exp(-0.5088) = 0.6. In terms of percent change, we can say that the odds for sideRed are 40% lower than the odds for blue side.
    - **Elemental Dragons:** holding the rest of the variables at a fixed value, the log(odds ratio) of the odds of winning a League of Legends game, having a +4 to +6 difference in Elemental Dragons (`elementalsd[4,6]` = 1) over the odds of winning a game having a 0 difference, is exp(1.2784) = 3.59. In terms of percent change, we can say that the odds for a 4 to 6 difference in Elemental Dragons are 259% higher than the odds for 0 difference.   
    - **Elder Dragons:** holding the rest of the variables at a fixed value, the log(odds ratio) of the odds of winning a League of Legends game, having a -2 difference in Elder Dragons (`elderd-2 = 1`) over the odds of winning a game having a 0 difference, is exp(-2.4659) = 0.08. In terms of percent change, we can say that the odds for a -2 difference in Elder Dragons are 92% lower than the odds for 0 difference. 
    - **Baron Nashors:** holding the rest of the variables at a fixed value, the log(odds ratio) of the odds of winning a League of Legends game, having a +1 difference in Baron Nashors (`barond1` = 1) over the odds of winning a game having a 0 difference, is exp(1.3898) = 4.01. In terms of percent change, we can say that the odds for a +1 difference in Baron Nashors are 301% higher than the odds for 0 difference.
    - **Wardratio:** holding the rest of the variables at a fixed value, we will see 84% increase in the odds of winning a game for a one-unit increase in Wardratio (`wardratio`)  since exp(0.6136) = 1.847069.   
    - **Gold Spent Percentage Difference:** holding the rest of the variables at a fixed value, we will see a huge increase in the odds of winning a game for a hypothetically one-unit increase in Gold Spent Percentage Difference (`gspd`),  since exp(18.1315) = 74887684. However, is not accurate to use one-unit increase as refference since approximately 70% of the observations in the dataset are in between the range of -0.14 and 0.14.      

```r
summary(logistic)
```

```
## 
## Call:
## glm(formula = result ~ side + elementalsd + elderd + barond + 
##     gspd + wardratio, family = "binomial", data = ModelTrain)
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -3.6029  -0.2390  -0.0007   0.2125   3.6448  
## 
## Coefficients:
##                    Estimate Std. Error z value Pr(>|z|)    
## (Intercept)         -1.2099     0.5992  -2.019  0.04349 *  
## sideRed             -0.5088     0.1859  -2.738  0.00619 ** 
## elementalsd[-6,-4]  -1.1366     0.4193  -2.711  0.00671 ** 
## elementalsd[4,6]     1.2784     0.4152   3.079  0.00208 ** 
## elderd-1            -0.6950     0.3078  -2.258  0.02395 *  
## elderd-2            -2.4659     1.1220  -2.198  0.02797 *  
## elderd1              0.6177     0.3063   2.016  0.04375 *  
## elderd2              4.0823     1.4726   2.772  0.00557 ** 
## barond-1            -1.3529     0.2474  -5.468 4.56e-08 ***
## barond[-4,-2]       -1.7851     0.3321  -5.375 7.64e-08 ***
## barond[2,4]          1.8999     0.3518   5.401 6.64e-08 ***
## barond1              1.3898     0.2508   5.541 3.01e-08 ***
## gspd                18.1315     1.4250  12.724  < 2e-16 ***
## wardratio            0.6136     0.2309   2.658  0.00787 ** 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 2844.68  on 2051  degrees of freedom
## Residual deviance:  826.78  on 2038  degrees of freedom
## AIC: 854.78
## 
## Number of Fisher Scoring iterations: 7
```

## Goodness of fit  <br/> 
### 1 - Stepwise Procedure:  <br/> 
The Stepwise Backward Elimination with Akaike information criterion (AIC),  does not provide proof of a model in the sense of testing a null hypothesis. That is, AIC cannot say anything about the quality of the model in an absolute sense. If all the candidate models fit poorly, AIC will not give signal of it. What this criterion does, is to penalize models with many parameters against the most parsimonious models.

```r
library(MASS)
AIC.step <- stepAIC(logistic, scope = list(upper = logistic$formula, lower = ~1), direction = "backward")
```

```
## Start:  AIC=854.78
## result ~ side + elementalsd + elderd + barond + gspd + wardratio
## 
##               Df Deviance     AIC
## <none>             826.78  854.78
## - wardratio    1   833.98  859.98
## - side         1   834.35  860.35
## - elementalsd  2   847.11  871.11
## - elderd       4   857.57  877.57
## - barond       4  1038.22 1058.22
## - gspd         1  1080.49 1106.49
```
The **Backward Elimination** procedure is suggesting in the first step to not remove any variables from the model. However, `wardratio` is considered to be removed in the second step. Since this variable did not show a strong trend in the exploratoy data analysis, we are fitting a new model with the other regressors to evaluate its significance. We are storing the output in a variable called `logistic2`.

```r
# Reduced Model Fit
logistic2 <- glm(result ~ side + elementalsd + elderd + barond + gspd, data = ModelTrain, family ="binomial")  
summary(logistic2)
```

```
## 
## Call:
## glm(formula = result ~ side + elementalsd + elderd + barond + 
##     gspd, family = "binomial", data = ModelTrain)
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -3.6498  -0.2321  -0.0004   0.2174   3.6908  
## 
## Coefficients:
##                    Estimate Std. Error z value Pr(>|z|)    
## (Intercept)          0.2955     0.1994   1.482  0.13842    
## sideRed             -0.5458     0.1844  -2.960  0.00308 ** 
## elementalsd[-6,-4]  -1.2120     0.4158  -2.915  0.00356 ** 
## elementalsd[4,6]     1.2686     0.4122   3.078  0.00209 ** 
## elderd-1            -0.7888     0.3054  -2.583  0.00981 ** 
## elderd-2            -2.7014     1.1025  -2.450  0.01428 *  
## elderd1              0.5379     0.3034   1.773  0.07628 .  
## elderd2              4.0470     1.5150   2.671  0.00756 ** 
## barond-1            -1.3807     0.2452  -5.631 1.79e-08 ***
## barond[-4,-2]       -1.7777     0.3314  -5.364 8.12e-08 ***
## barond[2,4]          1.9186     0.3509   5.468 4.55e-08 ***
## barond1              1.3794     0.2494   5.532 3.17e-08 ***
## gspd                18.9022     1.4073  13.432  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 2844.68  on 2051  degrees of freedom
## Residual deviance:  833.98  on 2039  degrees of freedom
## AIC: 859.98
## 
## Number of Fisher Scoring iterations: 7
```
### 2 - Likelihood Ratio Test  <br/>
We are comparing the likelihood of the data under the full model, against the likelihood of the data under a model with fewer predictors. It is necessary to test whether the observed difference between the two models is statistically significant. <br/>
Given that H0 holds that the reduced model is true, a p-value for the overall model fit statistic that is less than
0.05 would compel us to reject the null hypothesis. It would provide evidence against the reduced model (`logistic2`) in favor of the current model. (`logistic`).

```r
# Testing with Anova
anova(logistic, logistic2, test ="Chisq")
```

```
## Analysis of Deviance Table
## 
## Model 1: result ~ side + elementalsd + elderd + barond + gspd + wardratio
## Model 2: result ~ side + elementalsd + elderd + barond + gspd
##   Resid. Df Resid. Dev Df Deviance Pr(>Chi)   
## 1      2038     826.78                        
## 2      2039     833.98 -1  -7.1989 0.007295 **
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```
In this case, both **lrtest** and **anova test** are favoring the current model (`logistic`). So we will continue our analysis with this model. 

```r
# Testing with lrtest function
library(lmtest)
lrtest(logistic, logistic2)
```

```
## Likelihood ratio test
## 
## Model 1: result ~ side + elementalsd + elderd + barond + gspd + wardratio
## Model 2: result ~ side + elementalsd + elderd + barond + gspd
##   #Df  LogLik Df  Chisq Pr(>Chisq)   
## 1  14 -413.39                        
## 2  13 -416.99 -1 7.1989   0.007295 **
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

### 3 - McFadden's Pseudo R-squared <br/> 
This is the overall predictive power of the model. Unlike linear regression with ordinary least squares estimation, there is no R2 statistic which explains the proportion of variance in the dependent variable that is explained by the predictors. However, there are a number of pseudo R2 metrics that could be of value. Most notable is McFadden's R2. <br/> 
In this case, the measure reports 70.93% predictive power, which is good.


```r
library(pscl)    
pR2(logistic)[4]
```

```
##  McFadden 
## 0.7093593
```
**P-Value:** The Pseudo R-squared needs to calculate an overall p-value with the Chi-square distribution. Because it's so small, our confidence level for the Pseudo R-squared is very high. Which means that this model is statistically significant.

```r
with(logistic, pchisq(null.deviance - deviance, df.null - df.residual, lower.tail = F))
```

```
## [1] 0
```

## Tests for Individual Predictors  <br/> 
### 1 - Wald Test:  <br/> 
This test is commonly used to determine the significance of odds-ratios in logistic regression. The Wald Test take advantage of the fact that log(odds-ratios) (just like log(odds)), are normally distributed. The idea is to test the hypothesis that the coefficient of an independent variable in the model is significantly different from zero. <br/> 
If the test fails to reject the null hypothesis, this suggests that removing the variable from the model will not substantially harm the fit of that model.

```r
library(survey)
regTermTest(logistic, "side")
```

```
## Wald test for side
##  in glm(formula = result ~ side + elementalsd + elderd + barond + 
##     gspd + wardratio, family = "binomial", data = ModelTrain)
## F =  7.495472  on  1  and  2038  df: p= 0.0062392
```

```r
regTermTest(logistic, "elementalsd")
```

```
## Wald test for elementalsd
##  in glm(formula = result ~ side + elementalsd + elderd + barond + 
##     gspd + wardratio, family = "binomial", data = ModelTrain)
## F =  8.804368  on  2  and  2038  df: p= 0.00015586
```

```r
regTermTest(logistic, "elderd")
```

```
## Wald test for elderd
##  in glm(formula = result ~ side + elementalsd + elderd + barond + 
##     gspd + wardratio, family = "binomial", data = ModelTrain)
## F =  5.778124  on  4  and  2038  df: p= 0.00012699
```

```r
regTermTest(logistic, "barond")
```

```
## Wald test for barond
##  in glm(formula = result ~ side + elementalsd + elderd + barond + 
##     gspd + wardratio, family = "binomial", data = ModelTrain)
## F =  44.73319  on  4  and  2038  df: p= < 2.22e-16
```

```r
regTermTest(logistic, "wardratio")
```

```
## Wald test for wardratio
##  in glm(formula = result ~ side + elementalsd + elderd + barond + 
##     gspd + wardratio, family = "binomial", data = ModelTrain)
## F =  7.063494  on  1  and  2038  df: p= 0.0079285
```

```r
regTermTest(logistic, "gspd")
```

```
## Wald test for gspd
##  in glm(formula = result ~ side + elementalsd + elderd + barond + 
##     gspd + wardratio, family = "binomial", data = ModelTrain)
## F =  161.8944  on  1  and  2038  df: p= < 2.22e-16
```

### 2 - Variable Importance:  <br/> 
To assess the relative importance of individual predictors in the model, we can also look at the absolute value of the t-statistic for each model parameter.

```r
varImp(logistic)
```

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> Overall </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> sideRed </td>
   <td style="text-align:right;"> 2.737786 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> elementalsd[-6,-4] </td>
   <td style="text-align:right;"> 2.710659 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> elementalsd[4,6] </td>
   <td style="text-align:right;"> 3.078925 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> elderd-1 </td>
   <td style="text-align:right;"> 2.257989 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> elderd-2 </td>
   <td style="text-align:right;"> 2.197726 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> elderd1 </td>
   <td style="text-align:right;"> 2.016484 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> elderd2 </td>
   <td style="text-align:right;"> 2.772249 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> barond-1 </td>
   <td style="text-align:right;"> 5.467608 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> barond[-4,-2] </td>
   <td style="text-align:right;"> 5.375319 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> barond[2,4] </td>
   <td style="text-align:right;"> 5.400520 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> barond1 </td>
   <td style="text-align:right;"> 5.540678 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> gspd </td>
   <td style="text-align:right;"> 12.723774 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> wardratio </td>
   <td style="text-align:right;"> 2.657723 </td>
  </tr>
</tbody>
</table>

##Validation of Predicted Values:  <br/> 
### 1 - ROC Analysis:  <br/> 
The Receiver Operating Characteristics traces the percentage of true positives accurately predicted by a given logit model, as the prediction probability threshold is lowered from 1 to 0. For a good model, as the threshold is lowered, it should mark more of actual 1's as positives and lesser of actual 0's as 1's. For a good model, the curve should rise steeply, indicating that the TPR (Y-Axis) increases faster than the FPR (X-Axis) as the threshold score decreases. 

```r
# Store the predicted values for training dataset in "Pred_Train" variable.
Pred_Train <- predict(logistic, ModelTrain, type="response")     

# Load ROCR library
library(ROCR)

# Define the ROCRPred and ROCRPerf variables
ROCRPred <- prediction(Pred_Train, ModelTrain$result) 
ROCRPref <- performance(ROCRPred, "tpr", "fpr")
```
<img src="Lol_Logistic_Model_files/figure-html/unnamed-chunk-18-1.png" style="display: block; margin: auto;" />
The greater the area under the ROC curve, the better predictive ability of the model.

```r
# Area under the curve
library(pROC)
ROC1 <- roc(as.factor(ifelse(ModelTrain$result == "Victory", 1, 0)), Pred_Train)
auc(ROC1)
```

```
## Area under the curve: 0.9747
```
### 2 - Threshold Analysis:  <br/> 
Here we compare a selected threshold of 0.5 vs 0.3 and 0.7 values, to see how the model responses to the test dataset.
However, the best threshold is 0.5 because it reports the highest accuracy. <br/> 
As we are talking about predicting a video game result, and not a delicate matter like having a disease or not, there is no need of reducing the threshold to obtain less true positive values in expense of more false positive values. That would also led the model to loose some performance.

```r
# Logistic Model Predictions on test Dataset
Pred_Test <- predict(logistic, ModelTest, type="response")
    
# Testing different thresholds for the Logistic Model
for (k in seq(0.3,0.7, by = 0.2)) {
    
Model.test.observed     <- as.factor(ifelse(ModelTest$result == "Victory", 1, 0))
Model.test.predt <- function(k) ifelse(Pred_Test > k , 1,0) 
    
CM_Test <- confusionMatrix(as.factor(Model.test.predt(k)), Model.test.observed)$overall[1]
    
Temp1 <- paste("CM_Test", k, sep = "_")
assign(Temp1, CM_Test)
}
```

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> Threshold_0.3 </th>
   <th style="text-align:right;"> Threshold_0.5 </th>
   <th style="text-align:right;"> Threshold_0.7 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Accuracy </td>
   <td style="text-align:right;"> 0.9090909 </td>
   <td style="text-align:right;"> 0.9222874 </td>
   <td style="text-align:right;"> 0.9120235 </td>
  </tr>
</tbody>
</table>

### 3 - Classification Rate:  <br/> 
Below we can see the confusion matrix for the model with the **definitive 0.5 threshold**, showing the comparisson between the predicted target variable versus the observed values for each observation.

```r
# Threshold
CM_Test <- confusionMatrix(as.factor(Model.test.predt(0.5)), Model.test.observed)
AC_Test <- CM_Test$overall[1]
CM_Test
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction   0   1
##          0 313  25
##          1  28 316
##                                           
##                Accuracy : 0.9223          
##                  95% CI : (0.8996, 0.9412)
##     No Information Rate : 0.5             
##     P-Value [Acc > NIR] : <2e-16          
##                                           
##                   Kappa : 0.8446          
##                                           
##  Mcnemar's Test P-Value : 0.7835          
##                                           
##             Sensitivity : 0.9179          
##             Specificity : 0.9267          
##          Pos Pred Value : 0.9260          
##          Neg Pred Value : 0.9186          
##              Prevalence : 0.5000          
##          Detection Rate : 0.4589          
##    Detection Prevalence : 0.4956          
##       Balanced Accuracy : 0.9223          
##                                           
##        'Positive' Class : 0               
## 
```
**Confusion Matrix**
<img src="Lol_Logistic_Model_files/figure-html/unnamed-chunk-23-1.png" style="display: block; margin: auto;" />

### 4 - Model Performance <br/> 
Now, we can compare the model's accuracy using the training dataset Vs using the Test dataset. <br/> 
As expected, the accuracy from the model using the test dataset is slightly lower than using the training dataset. This is probably because of the overfiting in the trainning model.

```r
# Model's accuracy - Training dataset Vs using the Test dataset.
CM_Train <- table(ActualValue=ModelTrain$result, PredictedValue=Pred_Train > 0.5)
AC_Train <- sum(diag(CM_Train)/sum(CM_Train))
```

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> Accuracy.in.train </th>
   <th style="text-align:right;"> Accuracy.in.test </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Accuracy </td>
   <td style="text-align:right;"> 0.9269006 </td>
   <td style="text-align:right;"> 0.9222874 </td>
  </tr>
</tbody>
</table>

## Predicted Probablilities  <br/> 
We can draw a graph that shows the predicted probablilities for a team to win a game, along with their actual win result status. Most of the teams that won the game (turquoise), are predicted to have a high probability of winning. And most of the teams that lost the game (salmon), are predicted to have a low winning probability.<br/>
This means that the logistic regression has done a pretty good job. However, we could use cross-validation to get a better idea of how well it might perform with new data.



<img src="Lol_Logistic_Model_files/figure-html/unnamed-chunk-27-1.png" style="display: block; margin: auto;" />

## K-Fold Cross-Validation:  <br/>
With this technique we can evaluate the results of this statistical analysis when the data set has been segmented into a training sample and a test sample, the cross-validation checks whether the results of the analysis are independent of the partition. I.e. validating how well our model would perform with new data.

```r
# Cross Validation Control
fitControl <- trainControl(method = "cv", number = 10, savePredictions = TRUE)
    
# Model Fit
logistic_CV <- train(result ~ side + elementalsd + elderd + barond + gspd + wardratio, data=ModelTrain,
                     method="glm", family="binomial", trControl = fitControl)
    
# Testing Model Fit with the Test Dataset
Pred_Test_CV = predict(logistic_CV, ModelTest, type="prob")[,2]
    
# Creating Confusion Matrix of logistic_CV
Model.test.observed <- as.factor(ifelse(ModelTest$result == "Victory", 1, 0))
Model.test.predt <- function(k) ifelse(Pred_Test_CV > k, 1,0)
    
CM_Test_CV <- confusionMatrix(as.factor(Model.test.predt(0.5)),Model.test.observed)
AC_Test_CV <- CM_Test_CV$overall[1]
CM_Test_CV
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction   0   1
##          0 313  25
##          1  28 316
##                                           
##                Accuracy : 0.9223          
##                  95% CI : (0.8996, 0.9412)
##     No Information Rate : 0.5             
##     P-Value [Acc > NIR] : <2e-16          
##                                           
##                   Kappa : 0.8446          
##                                           
##  Mcnemar's Test P-Value : 0.7835          
##                                           
##             Sensitivity : 0.9179          
##             Specificity : 0.9267          
##          Pos Pred Value : 0.9260          
##          Neg Pred Value : 0.9186          
##              Prevalence : 0.5000          
##          Detection Rate : 0.4589          
##    Detection Prevalence : 0.4956          
##       Balanced Accuracy : 0.9223          
##                                           
##        'Positive' Class : 0               
## 
```

**Comparison between logistic model accuracies:**  <br/>
Setting the threshold at 0.5 in our 10-fold cross-validation model, you can expect a lower accuracy compared to the glm() function's model. When using cross-validation, you expect to have less overfitting, but also a more realistic proxy for the accuracy. However, in this case we can say that both accuracies are approximatly the same.
<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> Logistic.without.CV </th>
   <th style="text-align:right;"> Logistic.with.CV </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Accuracy </td>
   <td style="text-align:right;"> 0.9222874 </td>
   <td style="text-align:right;"> 0.9222874 </td>
  </tr>
</tbody>
</table>

## Decision Trees Model  <br/>

```r
# Decision Trees Model
DT_Model <- train(result ~ side + elementalsd + elderd + barond + gspd + wardratio, data=ModelTrain, method="rpart", trControl=fitControl)
```

![](Lol_Logistic_Model_files/figure-html/unnamed-chunk-31-1.png)<!-- -->


```r
# Testing the model
DT_Predict <- predict(DT_Model,newdata=ModelTest)
CM_DT_Test <- confusionMatrix(ModelTest$result,DT_Predict)
AC_DT_Test <- CM_DT_Test$overall[1]

# Display confusion matrix and model accuracy
CM_DT_Test
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction Defeat Victory
##    Defeat     302      39
##    Victory     42     299
##                                           
##                Accuracy : 0.8812          
##                  95% CI : (0.8546, 0.9046)
##     No Information Rate : 0.5044          
##     P-Value [Acc > NIR] : <2e-16          
##                                           
##                   Kappa : 0.7625          
##                                           
##  Mcnemar's Test P-Value : 0.8241          
##                                           
##             Sensitivity : 0.8779          
##             Specificity : 0.8846          
##          Pos Pred Value : 0.8856          
##          Neg Pred Value : 0.8768          
##              Prevalence : 0.5044          
##          Detection Rate : 0.4428          
##    Detection Prevalence : 0.5000          
##       Balanced Accuracy : 0.8813          
##                                           
##        'Positive' Class : Defeat          
## 
```

## Random Forests <br/>

```r
# Random Forests Model
RF_Model <- train(result ~ side + elementalsd + elderd + barond + gspd + wardratio, data=ModelTrain, method="rf", trControl=fitControl, verbose=FALSE)
# Plot
plot(RF_Model,main="RF Model Accuracy by number of predictors")
```

![](Lol_Logistic_Model_files/figure-html/unnamed-chunk-33-1.png)<!-- -->


```r
# Testing the model
RF_Predict <- predict(RF_Model,newdata=ModelTest)
CM_RF_Test <- confusionMatrix(ModelTest$result,RF_Predict)
AC_RF_Test <- CM_RF_Test$overall[1]

# Display confusion matrix and model accuracy
CM_RF_Test
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction Defeat Victory
##    Defeat     312      29
##    Victory     25     316
##                                         
##                Accuracy : 0.9208        
##                  95% CI : (0.8979, 0.94)
##     No Information Rate : 0.5059        
##     P-Value [Acc > NIR] : <2e-16        
##                                         
##                   Kappa : 0.8416        
##                                         
##  Mcnemar's Test P-Value : 0.6831        
##                                         
##             Sensitivity : 0.9258        
##             Specificity : 0.9159        
##          Pos Pred Value : 0.9150        
##          Neg Pred Value : 0.9267        
##              Prevalence : 0.4941        
##          Detection Rate : 0.4575        
##    Detection Prevalence : 0.5000        
##       Balanced Accuracy : 0.9209        
##                                         
##        'Positive' Class : Defeat        
## 
```

## Comparing the 3 models  <br/>

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> Logistic.Model </th>
   <th style="text-align:right;"> DecisionTrees.Model </th>
   <th style="text-align:right;"> RandomForest.Model </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Accuracy </td>
   <td style="text-align:right;"> 0.9222874 </td>
   <td style="text-align:right;"> 0.8812317 </td>
   <td style="text-align:right;"> 0.9208211 </td>
  </tr>
</tbody>
</table>

## Conclusion  <br/>
By comparing the accuracy rate values of the three models, it is clear that the logistic regression model (`logistic`) is the best one. We will use the logistic model to predict the the winning teams. Allthough, random forests is very close and decision trees has a good percentage too. 









