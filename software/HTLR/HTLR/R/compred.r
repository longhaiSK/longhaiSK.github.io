
probs_attrue_bplr <- function (probs_pred, y)
{
  tp <- rep(0, nrow(probs_pred))
  for(i in 1:nrow(probs_pred)) tp[i] <- probs_pred[i,y[i]]

  tp
}


tabulate_pred <- function (probs_pred, y, caseid = names (y))
{
    if (is.null (caseid)) caseid <- 1:length (y)

    C <- ncol (probs_pred)
    values_pred <- apply (probs_pred, 1, which.max)
    
    table_eval <- data.frame (caseid, y, probs_pred, 1 * (values_pred != y)) 
    colnames (table_eval) <- 
             c("Case ID", "True Label", paste ("Pred. Prob", 1:C), "Wrong?")
    
    table_eval
}


evaluate_pred <- function (table_eval, showplot = TRUE, ...)
{

   
   if (is.character (table_eval)) 
   {
     table_eval <- as.matrix (read.table (table_eval))
   }
   
   C <- ncol (table_eval) - 3
   colnames (table_eval) <- 
             c("Case ID", "True Label", paste ("Pred. Prob", 1:C), "Wrong?")
   
   probs_pred <- table_eval [, 2+(1:C)]
   y <- table_eval[,2]
   probs_at_truelabels <- probs_attrue_bplr (probs_pred, y)
   which.wrong <- which (table_eval[,C+3] == 1)
   n <- nrow (table_eval)
   
   amlp <- - mean (log (probs_at_truelabels))
   no_errors <- sum (table_eval[, C+3])
   er <- no_errors/n
   
   yl <- y; if (C == 2) yl[y==2] <- 3
   
   plotargs <- list (...)
   if (is.null (plotargs$ylab)) 
       plotargs$ylab <- "Predictive Probability at True Label"
   if (is.null (plotargs$xlab)) plotargs$xlab <- "Case Index"
   if (is.null (plotargs$ylim)) plotargs$ylim <- c(0,1)
   if (is.null (plotargs$pch)) plotargs$pch <- yl   
   
   if (showplot)
   {
       plotargs$x <- probs_at_truelabels
       do.call (plot, plotargs)   

       if (C == 2) abline (h = 0.5)
       abline (h = 0.1,lty = 2)

       title (main = sprintf ("AMLP = %5.3f, Error Rate = %4.2f%% (%d/%d)", 
                             amlp, er*100, no_errors, n), 
              cex = 0.8, line = 0.5) 
   
       if (no_errors > 0)
       {              
           for (i in 1:no_errors)
           {
              case <- which.wrong [i]
              text (case, probs_at_truelabels[case], labels = case,
                    srt = 90, adj = - 0.4, cex = 0.9, col = "red")
           }
       }
   }
   list (y = y, probs_pred = probs_pred, 
         probs_at_truelabels = probs_at_truelabels, table_eval = table_eval,  
         amlp = amlp, er = er,  which.wrong = which.wrong )
}

plot_features <- function (X, features, predfile = NULL, ...)
{
    n <- nrow (X)

    if (!is.null (predfile))
    {
        which.wrong <- eval_pred (predfile, showplot = FALSE)$which.wrong
        colcases <- rep (1, n)
        colcases [which.wrong] <- 2
    }
    else 
    {
        which.wrong <- NULL
        colcases <- rep (1,n)
    }
    
    if (length (features) == 2)
    {
        plot (X[,features], col = colcases, xlab = "", ylab = "", ...)
    
        title (xlab = sprintf ("Expression Level of Gene %d", features[1])) 
        title (ylab = sprintf ("Expression Level of Gene %d", features[2])) 
         
        title( main = sprintf("Scatterplot of Genes %d and %d", 
                              features[1],features[2]), line = 0.5)
        for (i in which.wrong)
        {
            text (X[i,features[1]], X[i, features[2]], i, 
            srt =90, adj = 1.5, col = "red",  cex = 0.8)
        }
    }
    
    if (length (features) == 1)
    {
        plot (X[,features],col = colcases, xlab = "", ylab = "", ...)

        title (xlab = "Case Index", line = 2)
        title (ylab = sprintf ("Expression Level of Gene %d", features))
        
        for (i in which.wrong)
        {
            text (i,X[i,features],i,srt=90,adj = -0.4,col="red",cex = 0.8)
        }
    }
    
    if (length (features) == 3)
    {
      scatterplot3d (X[,features[1]], X[,features[2]], X[,features[3]],
      xlab = paste ("Gene", features[1]), 
      ylab = paste ("Gene", features[2]), 
      zlab = paste ("Gene", features[3]), 
      main = sprintf("3D Scatterplot of Genes %d, %d and %d", 
                     features [1], features [2], features [3] ),
      color = colcases,...)
    }
    
}

compare2 <- function (a1, a2, m1, m2, item, filename = item, sign = FALSE, ...)
{
    psfile <- sprintf ("%s.ps", filename)

    postscript (file = psfile, title = psfile,
                paper = "special", width = 5, height = 5, horiz = F)
    par (mar = c(4,4,2,0.5))
    if (!sign)  xlim <- range (a1, a2)
    else {
        xlim <- max (abs(range (a1, a2, na.rm = TRUE, finite = TRUE)))
        xlim <- c(-xlim, +xlim)
    }
    plot (a1, a2,  xlim = xlim, ylim = xlim,
          main = sprintf("%s by %s and %s", item, m1, m2), 
          xlab = m1, ylab = m2, ...)
    abline (a = 0, b = 1, col = "grey")
    if (sign) abline (a = 0, b = -1, col = "grey")
    dev.off()
}


## old not used any more functions
if (FALSE)
{
comp_amlp <- function(probs_pred, y)
{
    mlp <- rep(0, nrow(probs_pred))
    for(i in 1:nrow(probs_pred))
        mlp[i] <- log(probs_pred[i,y[i]])

    - mean(mlp)
}

## Mloss -- a matrix specifying losses, with row for true values, and
## column for predicted values.
comp_loss <- function(probs_pred, y, Mloss = NULL)
{
     G <- ncol (probs_pred)

     if (is.null (Mloss))
     {
        Mloss <- matrix(1,G,G)
        diag(Mloss) <- 0
     }

     loss_pred <- probs_pred %*% Mloss
     y_pred <- apply(loss_pred,1,which.min)

     loss <- 0
     for(i in 1:nrow(probs_pred)) {
         loss <- loss + Mloss[y[i],y_pred[i]]
     }

     loss / length (y)
}

## partition all cases into nfold subsets
## This function partitions a set of observations into subsets of almost
## equal size. The result is used in crossvalidation
mk_folds <- function(y, nfold = 10, random = TRUE)
{
    n <- length (y)
    nos_g <- table (y)
    G <- length (nos_g)
    nfold <- min (nfold, nos_g)

    folds <- rep (0, n)
    
    for (g in 1:G)
    {
        ng <- nos_g [g]
        m <- ceiling (ng/nfold)

        if (random)
        {
            gfolds <- c( replicate (m, sample (1:nfold) ) ) [1:ng]
        }
        else
        {
            gfolds <- rep (1:nfold, m)[1:ng]
        }
        
        folds [y == g] <- gfolds
    }
    
    ## create fold list 
    foldlist <- rep (list (""),nfold)
    for (i in 1:nfold)
    {
        foldlist [[i]] <- which (folds == i)
    }
    
    foldlist
 }

#################### a generic crossvalidation function ####################
## X --- features with rows for cases
## y --- a vector of response values
## nfold --- number of folds in cross validation
##  trpr_fn --- function for training and prediction:
##  the arguments of trpr_fn must include X_tr, y_tr, X_ts
##  the outputs of trpr_fn must include probs_pred
## ... --- other arguments needed by trpr_fn other than X_tr, y_tr, X_ts
cross_vld <- function (
     trpr_fn, folds = NULL, nfold = 10, X, y,randomcv = TRUE, ...)
{
  if (!is.matrix(X)) stop ("'X' must be a matrix with rows for cases")

  n <- nrow(X)
  nos_g <- as.vector (tapply (rep(1,n), INDEX = y, sum))
  if (any(nos_g < 2)) stop ("less than 2 cases in some group in your data")
  G <- length (nos_g)


  if (is.null (folds)) folds <- mk_folds (y, nfold)
  
  nfold <- length (folds)

  array_probs_pred <- NULL
  vector_ts <- NULL

  for (i_fold in 1:nfold)
  {
      cat ( "=============== CV: Fold",i_fold, "===============\n")
      
      ts <- folds [[i_fold]]
      vector_ts <- c (vector_ts, ts)
      tr <- (1:n)[- (ts)]

      array_probs_pred <- abind ( array_probs_pred,
        trpr_fn (
            X_tr = X[tr,, drop = FALSE], y_tr = y[tr],
            X_ts = X[ts,, drop = FALSE], ...)$array_probs_pred,
        along = 1)
  }

  ## make the order of cases in array_probs_pred is the same as X
  array_probs_pred <- array_probs_pred [order (vector_ts),,,drop = FALSE]

  list (folds = folds, array_probs_pred = array_probs_pred)
}

}

