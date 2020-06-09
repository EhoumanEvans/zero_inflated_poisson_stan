#=== packages ===
library(dplyr)
library(rstan)
library(foreach)
library(boot)
library(gamlss.dist)

#=== fit ===
zip_stan_fit <- function(d, obj, model.path="model/zip_model.stan", seed=8787){
  obj.val.name <- obj
  obj.val <- d[obj.val.name][[1]]
  
  # error handling
  if(sum(apply(d,2,is.numeric))!=ncol(d)){
    stop("all values must be numeric.")
  }
  if(!is.integer(obj.val)){
    stop("obj value must be integer.")
  }
  # prep explonatory val.
  ic.exp.val <- d %>% 
    dplyr::select_(paste0("-",obj.val.name)) %>% 
    dplyr::mutate(intercept = 1) %>% 
    dplyr::select(intercept, everything()) %>% 
    as.data.frame()
  # prep for stan
  dat <- list(N=nrow(d), D=ncol(ic.exp.val), Y=obj.val, X=ic.exp.val)
  # run stan
  fit <- stan(file=model.path, data=dat,
              pars=c("b", "q", "lambda"), seed=seed)
  return(fit)
}

#=== predict ===
zip_stan_pred <- function(stan.fit, new.data){
  fit.matrix <- summary(stan.fit)[[1]]
  rownames(fit.matrix)
  index1 <- grep(rownames(fit.matrix), pattern = "^b\\[1")
  index2 <- grep(rownames(fit.matrix), pattern = "^b\\[2")
  
  coef1 <- fit.matrix[index1,"mean"]
  coef2 <- fit.matrix[index2,"mean"]
  
  ic.exp.val.new <- new.data %>% 
    # dplyr::select_(paste0("-",obj.val.name)) %>% 
    dplyr::mutate(intercept = 1) %>% 
    dplyr::select(intercept, everything()) %>% 
    as.matrix()
  
  q_new <- foreach(i = 1:nrow(ic.exp.val.new), .combine="c") %do% {
    inv.logit((ic.exp.val.new %*% coef1)[i])
  }
  
  lambda_new <- ic.exp.val.new %*% coef2 %>% c()
  
  range(q_new)
  range(lambda_new)
  
  y_pred <- foreach(i = 1:nrow(ic.exp.val.new), .combine="c") %do% {
    set.seed(8787)
    rZIP(1, mu=lambda_new[i], sigma=1-q_new[i])
  }
  return(y_pred)
}