# load packages
library("tidyverse")
library("caret")
library("rsample")
library("kableExtra")


############ data #############

# load data
wine = as_tibble(ucidata::wine) %>% 
  mutate(quality_cat = as.factor(quality)) %>% 
  select(-quality)

# test-train-split
split = initial_split(wine, 0.8)
wine_tst = testing(split)
wine_trn = training(split)


############ train models #############

# cross-validate 5 times for each model
cv = trainControl(method = "cv", number = 5)


# Random Forest 
set.seed(42)
rf_mod = train(quality_cat ~ . , wine_trn,
               method = "ranger", 
               metric = "Accuracy",
               trControl = cv)

# Naive Bayes
set.seed(42)
nb_mod = train(quality_cat ~ . , wine_trn,
               method = "nb", 
               metric = "Accuracy",
               trControl = cv)

# SVM
set.seed(42)
svm_mod = train(quality_cat ~ . , wine_trn,
                method = "lssvmRadial", 
                metric = "Accuracy",
                trControl = cv,
                verbose = FALSE)

# Multinomial Regression
set.seed(42)
multinom_mod = train(quality_cat ~ . , wine_trn,
                     method = "multinom", 
                     metric = "Accuracy",
                     trControl = cv,
                     trace = FALSE)


############ results #############

# trained models
mods = list(rf_mod, nb_mod, svm_mod, multinom_mod) 

# extract training accuracies
accs = mods %>% 
  map_dbl(~ max(.x$results$Accuracy, na.rm = TRUE))

# build training accuracy table
tibble(
  Model = c("Random Forest", "Naive Bayes", "Support Vector Machine", "Multinomial Regression"),
  Accuracy = accs
) %>% 
  kable(caption = '5-Fold Cross-Validation', digits = 4) %>% 
  kable_styling("striped", full_width = FALSE)


############ discussion #############

# predict with best performing model (random forest model)
pred_tst = predict(rf_mod, wine_tst)

# extract accuracy of test model
acc_tst = mean(pred_tst == wine_tst$quality_cat)

# test accuracy table
tibble("Test Accuracy" = acc_tst) %>% 
  kable(caption = '**Random Forest** Accuracy', digits = 4) %>% 
  kable_styling("striped", full_width = FALSE)

# build test confusion matrix
addmargins(table(predict(rf_mod, wine_tst), wine_tst$quality_cat)) %>% 
  kable(caption = 'Test Confusion Matrix') %>% 
  kable_styling("striped", full_width = FALSE)

