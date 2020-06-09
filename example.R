#=== set your working dir ===
setwd("your_path/beyesian-zero-inflated-poisson-regression/")

#=== packages ===
library(dplyr)
library(readr)
library(Metrics)
library(caret)
require(ggplot2)
source("functions/zip_stan_func.R")

#=== example data ===
zinb <- 
  readr::read_csv("https://stats.idre.ucla.edu/stat/data/fish.csv") %>% 
  dplyr::select(count, child, persons, camper)
#=== devide test data and train data
zinb.train <- zinb[1:200,]
zinb.new <- zinb[201:250,] %>% dplyr::select(-count)
answer <- zinb[201:250,] # for calculating MAE
glimpse(zinb)
# We have data on 250 groups that went to a park. 
# Each group was questioned about how many fish they caught (count), 
# how many children were in the group (child), 
# how many people were in the group (persons), 
# and whether or not they brought a camper to the park (camper).
# "count" is the objective variable.
qplot(zinb$count, geom="histogram", binwidth=1) # zero-infrated data

#=== run mcmc ===
fit <- zip_stan_fit(zinb.train, "count")
fit.matrix <- as.matrix(summary(fit)[[1]])
print(fit.matrix[grep(rownames(fit.matrix), pattern = "^b"),])
# regression coefficient
# b[1,x]: for Bernoulli distribution
# b[2,x]: for Poisson distribution
# b[x,1:4]: intercept, child, persons, camper

y_pred <- zip_stan_pred(fit, zinb.new)
mae(answer$count, y_pred) # 1.44



#=======
# comparison to lm function
res.lm <- lm("count ~ .", zinb.train)
summary(res.lm) # Multiple R-squared: 0.1775.
res.predict <- floor(predict.lm(res.lm, zinb.new))
range(res.predict) # includes negative value. count must be positive.
mae(answer$count, res.predict) # 2.86
# applying FORCIBLY normal distribution to data that does NOT follows normal distribution.

#=======
# comparison to xgboost
set.seed(8787)
modelXgboostTree <- train(
  count ~ ., 
  data = zinb.train,
  method = "xgbTree", 
  preProcess = c('center', 'scale'),
  trControl = trainControl(method = "cv"),
  tuneLength = 4
)
predxgBoostTree <- floor(predict(modelXgboostTree, zinb.new))
predxgBoostTree
mae(answer$count, predxgBoostTree) # 1.32
# XGboost is a good method for prediction.
# But, we have NO explanatoriness with using xgboost. 
