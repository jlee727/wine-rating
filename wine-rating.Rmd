---
title: "Predicting the Quality of Wines"
author: "Jae-Ho Lee"
output:
  pdf_document: default
  html_document: default
---

```{r setup, include = FALSE}
knitr::opts_chunk$set(echo = FALSE, fig.align = "center", 
                      cache = TRUE, autodep = TRUE)
```

```{r, include = FALSE}
# load packages
library("tidyverse")
library("caret")
library("rsample")
library("kableExtra")
# install.packages("devtools")
# devtools::install_github("coatless/ucidata")
```

***

# Abstract

> Statistical learning techniques were utilized in predicting the quality of wines given their various properties and attributes. A data set that represents more of the lower-end and higher-end of wine quality should be included to yield a more effective model.

***

# Introduction

Wine has a reputation for being a beverage of wide range and depth of taste, and such public perception of the beverage allows it to distinguish itself from other alcoholic beverages. While this image of the beverage may arouse pride in wine-buffs, it may also serve as deterrent for those interested in entering the world of wine. The rise of interest in wine led to a demand for the numeric rating of the quality of wine, which was popularized in ithe U.S. by Robert Parker in the 1970s [^1]. Wine ratings  lower the barrier to wine tasting help amateur wine-tasters more easily discover "good wine." 

The rating of wine is usually undergone by aggregating the rating of one or more wine critiques. The following analysis performs statistical learning techniques on various physiochemical attributes of wines in order to predict the quality of wines. While the random forest model best performed in predicting wine quality, additional measures in the analysis could be made for improvement.

***

# Methods

## Data

The `wine`[^2] data set was accessed through the `ucidata` package. It contains  6497 observations with 12 variables. The `quality` of the wine will be used as the response. Predictors include `color` (1599 red, 4898 white) and objective measurements of physicochemical properties of the wines such as `fixed acidity`, `citric acid`, `pH`, and `alcohol`. 

```{r, message = FALSE}
# view data documentation in R
# ?ucidata::wine
```

```{r, load-data}
# "load" data
wine = as_tibble(ucidata::wine) %>% 
  mutate(quality_cat = as.factor(quality)) %>% 
  select(-quality)
```

```{r, test-train-split}
split = initial_split(wine, 0.8)
wine_tst = testing(split)
wine_trn = training(split)
```

## Models

5-fold cross-validation was used as the validation measure for the trained models.

```{r, train-control}
cv = trainControl(method = "cv", number = 5)
```

```{r}
set.seed(42)
```

1. Random Forest 

```{r, random-forest, echo = TRUE, warning = FALSE}
rf_mod = train(quality_cat ~ . , wine_trn,
                 method = "ranger", 
                 metric = "Accuracy",
                 trControl = cv)
```

```{r}
set.seed(42)
```

2. Naive Bayes
```{r, naive-bayes, echo = TRUE, warning = FALSE}
nb_mod = train(quality_cat ~ . , wine_trn,
                  method = "nb", 
                  metric = "Accuracy",
                  trControl = cv)
```

```{r}
set.seed(42)
```

3. Support Vector Machine
```{r, svm, echo = TRUE, warning = FALSE}
svm_mod = train(quality_cat ~ . , wine_trn,
                method = "lssvmRadial", 
                metric = "Accuracy",
                trControl = cv,
                verbose = FALSE)
```

```{r}
set.seed(42)
```

4. Multinomial Regression

```{r, multinomial, echo = TRUE, warning = FALSE}
multinom_mod = train(quality_cat ~ . , wine_trn,
                method = "multinom", 
                metric = "Accuracy",
                trControl = cv,
                trace = FALSE)
```

***

# Results

Accuracy was measured in order to assess the effectiveness of the models.

```{r, accuracy-table}
mods = list(rf_mod, nb_mod, svm_mod, multinom_mod) 

accs = mods %>% 
  map_dbl(~ max(.x$results$Accuracy, na.rm = TRUE))
  
tibble(
  Model = c("Random Forest", "Naive Bayes", "Support Vector Machine", "Multinomial Regression"),
  Accuracy = accs
) %>% 
  kable(caption = '5-Fold Cross-Validation', digits = 4) %>% 
  kable_styling("striped", full_width = FALSE)
  
```

***

# Discussion

```{r, test-model}
pred_tst = predict(rf_mod, wine_tst)

acc_tst = mean(pred_tst == wine_tst$quality_cat)

tibble("Test Accuracy" = acc_tst) %>% 
  kable(caption = '**Random Forest** Accuracy', digits = 4) %>% 
  kable_styling("striped", full_width = FALSE)
```

During testing, the random forest model was able to correctly classify the quality of the wines roughly 70.44% of the time. While this result is not bad, we can observe from teh confusion matrix below that the number of lower values (3 and 4) and higher values (8 and 9) are widely under-represented in the data set. Sampling for imbalance in data would yield a better performing model. Additionally, consumers with little knowledge of wine may be content with simply knowing of a wine is "good" or "bad." Manipulating the `quality` value to represent two (good/bad) or three (low/medium/high) values may lead to more accurate models that would be sufficient for the needs of beginner wine-tasters.

```{r}
addmargins(table(predict(rf_mod, wine_tst), wine_tst$quality_cat)) %>% 
  kable(caption = 'Test Confusion Matrix') %>% 
  kable_styling("striped", full_width = FALSE)
```

***

# Appendix

## Data Dictionary

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

## Exploratory Data Anlysis

```{r, fig.width = 10, fig.height = 8, message = FALSE, warning= FALSE}
plot1 = wine_trn %>%
  ggplot(aes(x = color, fill = factor(quality_cat, levels = c(9:3)))) +
  geom_bar() +
  theme_bw() +
  labs(y = "Count", x = "Color", title = "Figure 1: Wine by Color", fill = "quality")

plot2 = wine_trn %>% 
  ggplot(aes(x = color, y = alcohol, fill = color)) + 
  geom_boxplot() + 
  theme_bw() + 
  scale_fill_manual(values = c("maroon", "ivory")) + 
  labs(title = "Figure 3: Alcohol Content by Color", y = "Alcohol (%)", x = "Color", fill = "Color")

plot3 = plot1 +
  facet_wrap(~ quality_cat) +
  labs(title = "Figure 2: Wine by Quality")

plot4 = wine_trn %>% 
  ggplot(aes(x = alcohol, y = quality_cat)) + 
  geom_smooth() + 
  geom_point() +
  theme_bw() + 
  labs(title = "Figure 4: Quality by Alcohol Content", x = "Alcohol (%)", y = "quality")


gridExtra::grid.arrange(plot1, plot2, plot3, plot4, ncol = 2) 
```

[^1]: [Wine Rating](https://en.wikipedia.org/wiki/Wine_rating)
[^2]: [Wine Quality Data Set](https://archive.ics.uci.edu/ml/datasets/Wine+Quality)
