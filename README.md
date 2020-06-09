## General

The Zero-Inflated Poisson model ("ZIP model") regression and prediction function using Stan and R.  
The bayesian model focused on ZIP model enables you to get high precision and explanatoriness of data.

Poisson distribution is applicable to many cases. For example,  
- the number of deaths by horse kicking in the Prussian army (first application)
- birth defects and genetic mutations
- rare diseases (like Leukemia, but not AIDS because it is infectious and so not independent) - especially in legal cases
- car accidents
- traffic flow and ideal gap distance
- number of typing errors on a page
- hairs found in McDonald's hamburgers
- spread of an endangered animal in Africa
- failure of a machine in one month 

(Reference: https://www.intmath.com/counting-probability/13-poisson-probability-distribution.php)

But, I guess you have often seen some datasets including too many zero records (Like the histogram below).
The ZIP model is useful for the datasets.

Sample dataset can be downloaded and there is the description of the dataset on https://stats.idre.ucla.edu/r/dae/zip/.  
(This URL includes conventional long-winded scripts using generalized-linear model ("GLM").)

Histogram of "count" from the sample dataset.
![zip_hist](https://github.ibm.com/codeblue/bayesian-zero-inflated-poisson-regression/blob/images/zip_hist.png)

ZIP model function.

![zip_function](https://github.ibm.com/codeblue/bayesian-zero-inflated-poisson-regression/blob/images/ZIP_function.png)

![model_function](https://github.ibm.com/codeblue/bayesian-zero-inflated-poisson-regression/blob/images/model_function.png)

Meanings of parameters in sample dataset,
```
y: how many fish they caught.  
q: probability of not getting skunked.  
λ: average of how many fish they caught when not getting skunked.  
N: number of all parties.  
n: index of a party.  
X: matrix including intercept(=1) and all explanatory variables.  
b: vector including regression coefficient.  
```

## Pre-requisites
```
install.packages("package-name")
```
R libraries:  
--[for zip_stan_func.R] "dplyr", "rstan", "foreach", "boot", "gamlss.dist"  
--[for example.R] "readr", "Metrics", "caret", "ggplot2"  

You can refer to Stan official website (http://mc-stan.org/users/interfaces/rstan) about installing Stan and rstan.

## How to use it

### Set working directory and load functions
```
setwd("your_path/beyesian-zero-inflated-poisson-regression")
source("functions/zip_stan_func.R")
```
### Functions 
```
zip_stan_fit(d, obj, model.path="model/zip_model.stan", seed=8787)
zip_stan_pred(stan.fit, new.data)
```
### Arguments
```
d: 　　　　　　　　　　　　　　　　　　data.frame. Training data include objective variable.
obj: 　　　　　　　　　　　　　　character. Column name of objective variable.
model.path: character. Path of a .stan file.
seed: 　　　　　　　　　　　　integer. Random seed.
stan.fit: 　　　　stanfit. Output of zip_stan_fit.
new.data: 　　　　data.frame. Test/new data including only explanatory variables.
```

## Final Output

The zip_stan_fit function returns estimated parameters by Stan.  
The zip_stan_pred function returns predicted values of objective variable.  

## Comparison to xgboost and lm

Sample dataset includes 250 records. And, it is devided into train dataset (200 records) and test dataset (50 records).  
The comparison in terms of "Explanatoriness", "Mean Absolute Error" and "process time".  
Explanatoriness means you can get readable relationship between objective variable and explanatory variables (Like regression coefficient).

| | zip_stan_fit | xgboost | lm |
----|----|----|----
| Explanatoriness | available | unavailable | available |
| MAE | 1.44 | 1.32 | 2.86 |
| proc.time | 80.37 sec | 31.22 sec | 0.02 sec |

## Main references
https://github.com/MatsuuraKentaro/RStanBook
(Written in Japanese)

\_at\_ -> @
