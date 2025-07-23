if (F){
log_sum_exp <- function(lx)
{  
  mlx <- max(lx)
  log(sum(exp(lx - mlx))) + mlx
}

log_normcons <- function (lv)
{
    sum (apply (cbind(0,lv), 1, log_sum_exp))
}

## y_tr is coded by 0, ..., K (=C-1)
## X_addint must be a matrix with rows for cases, columns for variables
optim_logit <- function (deltas, X_addint, y_tr, alpha, s, sigmab0, tol = 1e-3)
{

    if (!is.matrix (deltas)) stop ("'deltas' in 'optim_logit' must be a matrix")
    
    nvar <- ncol (X_addint)
    K <- ncol (deltas)
    log_aw <- log (alpha) + s
    
    post_logit_avar <- function (d_uvar, uvar, lv_fix)
    {
       d_uvar <- matrix (d_uvar, length (uvar), K)

       ## compute log likelihood
       loglike <- 0
       lv <- lv_fix + X_addint [, uvar, drop = FALSE] %*% d_uvar
       for (k in 1:K) loglike <- loglike + sum (lv[y_tr==k,k])
       loglike <- loglike - log_normcons (lv)
       
       ## compute log prior
       vardeltas <- comp_vardeltas (d_uvar)
       j_intc <- which (uvar == 1)
       j_vars <- which (uvar != 1)
       
       logprior <- 0
       if (length (j_intc)>0) 
       {
         logprior <- logprior-vardeltas[j_intc]/2/sigmab0
       }
       if (length (j_vars)>0) 
       {
           logprior <- logprior -  (alpha + K ) / 2 * sum (
             apply( cbind(log_aw, log(vardeltas[j_vars])), 1, log_sum_exp ) ) 
       }
       ## return negative log posterior
       - (loglike + logprior)
    }

    lv <- X_addint %*% deltas
    
    update <- TRUE
    while (update)
    {   
        deltas_old <- deltas
        
        for (uvar in 1:nvar)
        {
            d_uvar <- deltas [uvar,,drop = FALSE]
            lv_fix <- lv - X_addint [,uvar,drop = FALSE] %*% d_uvar
            
            out_nlm <- nlm (f = post_logit_avar, p = d_uvar, gradtol = 1e-3,
                            uvar = uvar, lv_fix = lv_fix)
            deltas[uvar, ] <- out_nlm$estimate                       
            d_uvar <- deltas [uvar,,drop = FALSE]
            lv <- lv_fix + X_addint [,uvar,drop = FALSE] %*% d_uvar
        }
        
        update <- any (abs(deltas-deltas_old)/abs(deltas) > tol & 
                       abs(deltas) > tol)
    }
    
    deltas
}

bplr_map <- function (fitbplr, usedmc = 1:1, tol = 1e-3)
{
    alpha <- fitbplr$alpha 
    s <- fitbplr$s
    sigmab0 <- fitbplr$sigmab0
    X_addint <- fitbplr$X
    y_tr <- fitbplr$ybase 
    
    apply (fitbplr$mcdeltas[,,usedmc, drop = FALSE], 3, optim_logit,
    X_addint = X_addint, y_tr = y_tr, s = s, alpha = alpha, sigmab0 = sigmab0,
    tol = tol)
}
}

