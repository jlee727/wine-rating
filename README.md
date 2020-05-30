# Predicting Wine Quality: Project Overview

- Produced a report that explores statistical models for predicting the rating of wine based on its physicochemical properties



***


## Code used

**R version 3.6.1**


## Data

The [Wine Quality Data Set](https://archive.ics.uci.edu/ml/datasets/Wine+Quality) data set was accessed through the `ucidata` package. It contains  6497 observations with 12 variables. The `quality` of the wine will be used as the response. Predictors include `color` (1599 red, 4898 white) and objective measurements of physicochemical properties of the wines such as `fixed acidity`, `citric acid`, `pH`, and `alcohol`. 


* `fixed acidity`

* `volatile acidity`

* `citric acid`

* `residual sugar`

* `chlorides`

* `free sulfur dioxide`

* `total sulfur dioxide`

* `density`

* `pH`

* `sulphates`

* `alcohol`

* `quality`

  - Score between `0` and `10` based on sensor reading

* `color`

  - `White` or `Red`
  
  
## Model Building

5-fold cross-validation was used to validate training models.

- Random Forest
- Naive Bayes
- SVM
- Multinomial Regression
