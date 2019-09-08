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

head(ModelData)

## Exploratoy Data Analysis 
library(ggplot2)
library(grid)
library(gridExtra)

Tittle <- textGrob("Game Result Frequency by Variable", gp = gpar(fontsize = 13, fontface = 'bold'))

plot0 <- ggplot(ModelData, aes(x = result, fill = result, label = result)) +
labs(x = "Result", y = "Frequency") + geom_bar(position = "dodge") +
scale_y_continuous(breaks = seq(0, 1400,200)) + theme_grey(base_size = 12)

plot1 <- ggplot(ModelData, aes(x = side, fill = result, label = result)) +
labs(x = "Map Side", y = "Frequency") + geom_bar(position = "dodge") +
scale_y_continuous(breaks = seq(0, 1400,200),limits = c(0, 1200)) + theme_grey(base_size = 12)

plot2 <- ggplot(ModelData, aes(x = factor(elementalsd, level = c("[-6,-4]","[-3,3]","[4,6]")), fill = result, label = result)) +
labs(x = "Elemental Dragons Difference", y = "Frequency") + geom_bar(position = "dodge") +
scale_y_continuous(breaks = seq(0, 1400,200),limits = c(0, 1200)) + theme_grey(base_size = 12)

plot3 <- ggplot(ModelData, aes(x = factor(elderd, level =
c("-2","-1","0","1","2")), fill = result, label = result)) +
labs(x = "Elder Dragons Difference", y = "Frequency") + geom_bar(position = "dodge") +
scale_y_continuous(breaks = seq(0, 1400,200),limits = c(0, 1200)) + theme_grey(base_size = 12)

plot4 <- ggplot(ModelData, aes(x = factor(barond, level = 
c("[-4,-2]","-1","0","1","[2,4]")), fill = result, label = result)) +
labs(x = "Baron Nashors Difference", y = "Frequency") + geom_bar(position = "dodge") +
scale_y_continuous(breaks = seq(0, 1400,200),limits = c(0, 1200)) + theme_grey(base_size = 12)

plot5 <- qplot(result, gspd, data = ModelData, 
xlab = "Result", ylab = "GSPD") + 
geom_boxplot(aes(fill = result)) + theme(axis.text = element_text(face="bold")) +
scale_y_continuous(breaks = seq(-0.5,0.5,0.1)) + theme_grey(base_size = 12) +
geom_hline(yintercept=0)

plot6 <- qplot(result, wardratio, data = ModelData, 
xlab = "Result", ylab = "Wards Placed/Wards Killed by Opp") +
geom_boxplot(aes(fill = result)) + theme_grey(base_size = 12) 

grid.arrange(Tittle, plot0, plot1, plot2, plot3, plot4, plot5, plot6, ncol=2)


## Data Partitioning for Prediction  <br/>

#Partitioning
library(caret)        
set.seed(12345) 

split <- createDataPartition(ModelData$result, p = 0.75, list = FALSE)

ModelTrain <- ModelData[split, ]
ModelTest <- ModelData[-split, ]

## Logistic Regression 
### 1 - Setting the Baselines  <br/>  

# Re Leveling Categorical Variables as the models' intercept
ModelTrain$side <- relevel(ModelTrain$side, ref = "Blue")
ModelTrain$elementalsd <- relevel(ModelTrain$elementalsd, ref = "[-3,3]")
ModelTrain$elderd <- relevel(ModelTrain$elderd, ref = "0")
ModelTrain$barond <- relevel(ModelTrain$barond, ref = "0")

### 2 - Model Fit:  <br/> 

# Base Model Fit
logistic <- glm(result ~ side + elementalsd + elderd + barond + gspd + wardratio,
data = ModelTrain, family ="binomial")
  
### 3 - Model Analysis:  <br/> 
summary(logistic)


## Goodness of fit  <br/> 
### 1 - Stepwise Procedure:  <br/> 
library(MASS)
AIC.step <- stepAIC(logistic, scope = list(upper = logistic$formula, lower = ~1), direction = "backward")

# Reduced Model Fit
logistic2 <- glm(result ~ side + elementalsd + elderd + barond + gspd, data = ModelTrain, family ="binomial")  
summary(logistic2)

### 2 - Likelihood Ratio Test  <br/>

# Testing with Anova
anova(logistic, logistic2, test ="Chisq")
 
# Testing with lrtest function
library(lmtest)
lrtest(logistic, logistic2)


### 3 - McFadden's Pseudo R-squared <br/> 

library(pscl)    
pR2(logistic)[4]

with(logistic, pchisq(null.deviance - deviance, df.null - df.residual, lower.tail = F))

## Tests for Individual Predictors  <br/> 
### 1 - Wald Test:  <br/> 

library(survey)
regTermTest(logistic, "side")
regTermTest(logistic, "elementalsd")
regTermTest(logistic, "elderd")
regTermTest(logistic, "barond")
regTermTest(logistic, "wardratio")
regTermTest(logistic, "gspd")

### 2 - Variable Importance:  <br/> 
varImp(logistic)

data.frame(varImp(logistic))

##Validation of Predicted Values:  <br/> 
### 1 - ROC Analysis:  <br/> 

# Store the predicted values for training dataset in "Pred_Train" variable.
Pred_Train <- predict(logistic, ModelTrain, type="response")     

# Load ROCR library
library(ROCR)

# Define the ROCRPred and ROCRPerf variables
ROCRPred <- prediction(Pred_Train, ModelTrain$result) 
ROCRPref <- performance(ROCRPred, "tpr", "fpr")

#Plot the graph
plot(ROCRPref, colorize=TRUE, print.cutoffs.at=seq(0.1, by=0.1))

# Area under the curve
library(pROC)
ROC1 <- roc(as.factor(ifelse(ModelTrain$result == "Victory", 1, 0)), Pred_Train)
auc(ROC1)

### 2 - Threshold Analysis:  <br/> 

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

kable(data.frame(Threshold_0.3 = CM_Test_0.3,Threshold_0.5 = CM_Test_0.5, Threshold_0.7 = CM_Test_0.7)) %>%
kable_styling(bootstrap_options = "striped", full_width = F, position = "center")

### 3 - Classification Rate:  <br/> 

# Threshold
CM_Test <- confusionMatrix(as.factor(Model.test.predt(0.5)), Model.test.observed)
AC_Test <- CM_Test$overall[1]
CM_Test

# **Confusion Matrix**

library(vcd)
mosaic(CM_Test$table, shade = T, colorize = T, 
gp = gpar(fill = matrix(c("#00BFC4", "#F8766D", "#F8766D", "#00BFC4"), 2, 2)))


### 4 - Model Performance <br/> 

# Model's accuracy - Training dataset Vs using the Test dataset.
CM_Train <- table(ActualValue=ModelTrain$result, PredictedValue=Pred_Train > 0.5)
AC_Train <- sum(diag(CM_Train)/sum(CM_Train))

kable(data.frame(Accuracy.in.train = AC_Train, Accuracy.in.test = AC_Test)) %>%
    kable_styling(bootstrap_options = "striped", full_width = F, position = "center")

## Predicted Probablilities  <br/> 

# Predicted Probabilities
predicted.data <- data.frame(
    probability.of.win=logistic$fitted.values,
    result=ModelTrain$result)

predicted.data <- predicted.data[
    order(predicted.data$probability.of.win, decreasing=FALSE),]
predicted.data$rank <- 1:nrow(predicted.data)

library(cowplot)
ggplot(data=predicted.data, aes(x=rank, y=probability.of.win)) +
    geom_point(aes(color=result), alpha=1, shape=4, stroke=2) +
    xlab("Index") +
    ylab("Probability") +
    ggtitle("Probability of Winning VS Actual Win Result Status") +
    theme(plot.title = element_text(hjust = 0.5)) + geom_hline(yintercept=0.5)

## K-Fold Cross-Validation:  <br/>

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


# **Comparison between logistic model accuracies:**  <br/>

data.frame(Logistic.without.CV = AC_Test, Logistic.with.CV = AC_Test_CV)

## Decision Trees Model  <br/>

# Decision Trees Model
DT_Model <- train(result ~ side + elementalsd + elderd + barond + gspd + wardratio, data=ModelTrain, method="rpart", trControl=fitControl)



#  Plot 
library(rpart)
library(rpart.plot)
library(rattle)
fancyRpartPlot(DT_Model$finalModel)



# Testing the model
DT_Predict <- predict(DT_Model,newdata=ModelTest)
CM_DT_Test <- confusionMatrix(ModelTest$result,DT_Predict)
AC_DT_Test <- CM_DT_Test$overall[1]

# Display confusion matrix and model accuracy
CM_DT_Test


## Random Forests <br/>

# Random Forests Model
RF_Model <- train(result ~ side + elementalsd + elderd + barond + gspd + wardratio, data=ModelTrain, method="rf", trControl=fitControl, verbose=FALSE)
# Plot
plot(RF_Model,main="RF Model Accuracy by number of predictors")

# Testing the model
RF_Predict <- predict(RF_Model,newdata=ModelTest)
CM_RF_Test <- confusionMatrix(ModelTest$result,RF_Predict)
AC_RF_Test <- CM_RF_Test$overall[1]

# Display confusion matrix and model accuracy
CM_RF_Test


## Comparing the 3 models  <br/>


data.frame(Logistic.Model = AC_Test_CV, DecisionTrees.Model = AC_DT_Test, RandomForest.Model = AC_RF_Test)


## Conclusion  <br/>








