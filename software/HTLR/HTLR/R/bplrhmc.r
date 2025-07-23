## y takes values 1,..., C
## initial_state can be NULL, or a gived parameter vector,
## or a previous markov chain results

htlr_fitpred <- function (
    y_tr, X_tr, X_ts = NULL, fsel = 1:ncol(X_tr), stdzx = TRUE,
    sigmab0 = 2000, ptype = "t", alpha = 1, s = -15, eta = 0,  
    iters_h = 1000, iters_rmc = 2000, thin = 50,  
    leap_L = 50, leap_L_h = 5, leap_step = 0.5,  hmc_sgmcut = 0.05,
    looklf = 0,  initial_state = NULL, silence = TRUE,
    predburn = NULL, predthin = 1)
{
	## checking prior types
	if (!any (ptype == c("t", "ghs", "neg"))) 
	{
	  stop ("\"ptype\" NOT in (\"t\", \"ghs\", \"neg\")")
    }
    ## checking arguments
    if (iters_rmc <= 0||iters_h < 0||leap_L <=0 ||leap_L_h <= 0 || thin <= 0)
    {
      stop ("MC iterations and Leapfrog lengths must be nonnegative.")
    }

    if (length (y_tr) != nrow (X_tr) ) stop ("'y' and 'X' mismatch")

    ######################### preprocess data #########################
    ybase <- as.integer(y_tr - 1) 
    ymat <- model.matrix (~factor(y_tr) - 1)[,-1]
    C <- length (unique (ybase))
    ## feature selection
    X <- X_tr [, fsel, drop = FALSE] 
    p <- length (fsel)
    n <- nrow (X)
    ## standardize selected features
    nuj <- rep (0, length (fsel))
    sdj <- rep (1, length (fsel))
    if (stdzx == TRUE) 
    {
      nuj <- apply (X, 2, median)
      sdj <- apply (X, 2, sd)
      X <- sweep (X, 2, nuj, "-")
      X <- sweep (X, 2, sdj, "/")
    }
    ## add intercept
    X_addint <- cbind (1, X) 
    ## stepsize for HMC from data
    DDNloglike <- 1/4 * colSums (X_addint^2)

    ########################## initial Markov chain state ################
    ## starting from a given deltas
    if (!is.list (initial_state) & 
        (is.vector(initial_state) || is.matrix (initial_state)) )
    {
      deltas <- matrix(initial_state, nrow = p + 1)
      logw <- s
    }
    
    ## use the last iteration of markov chain
    if (is.list (initial_state) )
    {
        no_mcspl <- length (initial_state$mclogw)
        deltas <- matrix (initial_state$mcdeltas [,,no_mcspl], nrow = p + 1)
        sigmasbt <- initial_state$mcsigmasbt [, no_mcspl]
        logw <- initial_state$mclogw [no_mcspl]
    }
    ## randomly generating deltas
    if (is.null (initial_state)) 
    {
        deltas <- bcbcsf_deltas (X,y_tr) 
        logw <- s
    }
    if (!exists ("sigmasbt"))
    {
        vardeltas <- comp_vardeltas(deltas) [-1]
        sigmasbt <- c(sigmab0, #vardeltas/C)
        spl_sgm_ig (alpha,C-1,exp(logw), vardeltas) )
    }
    if (nrow (deltas) != p + 1 || ncol (deltas) != C-1)
    stop ("Initial `deltas' Mismatch Data")

    ######################## call C to do Gibbs sampling #################
    ## markov chain storage 

    fithtlr <- .C("htlr_fit", 
        ## data
        p = as.integer (p), K = as.integer (C-1), n = as.integer (n), 
        X = X_addint, ymat = ymat, ybase = ybase,  
        ## prior
        ptype=ptype[1], alpha = alpha, s = s, eta = eta,  sigmab0 = sigmab0, 
        ## sampling
        iters_rmc = as.integer (iters_rmc), thin = as.integer (thin), 
        leap_L = as.integer (leap_L), 
        iters_h = as.integer (iters_h), leap_L_h = as.integer (leap_L_h), 
        leap_step = leap_step, hmc_sgmcut = hmc_sgmcut, 
        DDNloglike = DDNloglike,
        ## fit result
        mcdeltas = array (deltas, dim = c(p + 1, C - 1, iters_rmc + 1)), 
        mclogw =  rep (logw, iters_rmc + 1), 
        mcsigmasbt = matrix (sigmasbt, p+1, iters_rmc + 1),
        mcvardeltas = matrix (0, p+1, iters_rmc + 1), 
        mcloglike = rep (0, iters_rmc + 1), 
        mcuvar = rep (0, iters_rmc + 1),
        mchmcrej = rep (0, iters_rmc + 1),
        ## other control
        silence = as.integer (silence), looklf = as.integer(looklf)) 
    ## adding data preprocessing information
    fithtlr <- c (fithtlr, list( fsel = fsel, nuj = nuj, sdj = sdj, y = y_tr) )
        
    ################## prediction for test cases #########################
    if (!is.null (X_ts))
    {
      predout <- htlr_predict (X_ts = X_ts, fithtlr = fithtlr, 
                               burn = predburn, thin = predthin)
    }
    else predout <- NULL
    
    ############## Hhtlr fitting and prediction results  #################
    return (c (fithtlr, predout) )
}


## function for plotting coefficients
htlr_mccoef <-  function (
        fithtlr, features = 1, class = 2,  usedmc = "all", 
        symlim = FALSE, drawq = c(0,1), truedeltas = NULL)
{
    mcdims <- dim (fithtlr$mcdeltas)
    p <- mcdims [1] - 1
    K <- mcdims [2]
    no_mcspl <- mcdims[3]
    features <- features [!is.na (features)]
    if (usedmc [1] == "all") usedmc <- 1:no_mcspl
    	
    if (length (features) == 1)
    {
        if (features == 0) j <- 1
        else  j <- which(fithtlr$fsel == features) + 1
        k <- class - 1
        deltas <- fithtlr$mcdeltas[j, k,usedmc, drop = FALSE]
      
        plot (deltas, pch = 20, 
              xlab = "Markov Chain Index (after burning and thinning)", 
              ylab = sprintf ("Coef. Value of Feature %d",  features),
              main = sprintf("MC Coefficients for Feature %d (Class %d)",
                             features, class)
        )
        qdeltas <- quantile (deltas, probs = c(0.025,0.5,0.975))
        abline (h = qdeltas[2], lwd = 2)
        abline (h = qdeltas[1], lty = 2, lwd = 2)
        abline (h = qdeltas[3], lty = 2, lwd = 2)
        
        if (!is.null (truedeltas))
        {   
            abline (h = truedeltas [j,k], lwd = 2, col = "red")
        }
    }
    else
    {
        j <- 1:2
        if (features[1] == 0) j[1] <- 1 else
        j[1] <- which (fithtlr$fsel == features[1]) + 1
        if (features[2] == 0) j[2] <- 1 else        
        j[2] <- which (fithtlr$fsel == features[2]) + 1
        k <- class - 1
        deltas <- fithtlr$mcdeltas[j, k,usedmc, drop = TRUE]
      
        if (symlim)
        {
            lim <- quantile (deltas, probs = drawq)
            xlim <- lim 
            ylim <- lim
        }
        else
        {
            xlim <- quantile (deltas[1,], probs = drawq)
            ylim <- quantile (deltas[2,], probs = drawq)
        }
        
        plot (t(deltas), 
              xlab = sprintf ("feature %d",  features[1]),
              ylab = sprintf ("feature %d",  features[2]),
              xlim = xlim,
              ylim = ylim,
              type = "l", col = "grey", 
              main = sprintf("MC Coef. for Features %d and %d (Class %d)",
              features[1], features[2], class) )
        points (t(deltas), pch = 20) 
    }
    out <- deltas
}



htlr_mdcoef <- function (fithtlr, usedmc = "all", features = "all")
{
    mcdims <- dim (fithtlr$mcdeltas)
    p <- mcdims [1] - 1
    K <- mcdims [2]
    no_mcspl <- mcdims[3]

    if (usedmc [1] == "all")  usedmc <- 1: no_mcspl
        
    
    if (is.null(features) || length (features) == 0) ix.f <- c()
    else if (features [1] == "all")  ix.f <- 1:p
    else        
    {
        ix.f <- get_ix (features, fithtlr$fsel)
    }
    
    mcdeltas <- fithtlr$mcdeltas[c(1,ix.f + 1),, usedmc, drop = FALSE]

    mddeltas <- apply (mcdeltas, MARGIN = c(1,2), FUN = median)
    
}


htlr_fss <- function 
    (fithtlr, threshold = 0.1, mfreq = 0.05, sfreq = 0.01, print = TRUE)
{
    mcsdb <- sqrt(fithtlr$mcvardeltas[-1,,drop = F])
    mcsdb_max <- apply (mcsdb, 2, max)
    mcsdb_norm <- sweep (mcsdb, 2, mcsdb_max, "/")
    
    is_used <- 1 * (mcsdb_norm >= threshold)
    
    ## selecting features using marginal probabilities
    mprobs <- apply (is_used, 1, mean)
    fset_mf <- which (mprobs >= mfreq)
    
    if (length (fset_mf) == 0) stop ("mfreq may be too big; no features used")
    
    is_used_mf <- is_used [fset_mf,,drop = F]
    mciters <- ncol (mcsdb)
    iclust <- rep (1, mciters)
    
    ## find feature subsets
    clusts <- is_used_mf[,1,drop = FALSE]
    nclust <- 1
    nos_clust <- 1
    for (imc in 2:mciters)
    {
        new_cls <- TRUE
        for (i in 1:nclust)
        {
            if ( all (is_used_mf[,imc] == clusts[,i]) )
            {
                new_cls <- FALSE
                iclust [imc] <- i
                nos_clust [i] <- nos_clust [i] + 1
                break
            }
        }
        
        if (new_cls == TRUE) ## found a new cluster
        {
            nclust <- nclust + 1
            iclust [imc] <- nclust
            nos_clust[nclust] <- 1
            clusts <- cbind (clusts, is_used_mf[,imc])
        }
        
    } 
    
    ## re-order clusters by subset frequencies
    rank_clust <- rank (-nos_clust, ties.method = "first" )
    iclust  <- rank_clust[iclust]
    clust_order <- order (rank_clust)
    clusts <- clusts[, clust_order, drop = FALSE]
    nos_clust <- nos_clust [clust_order]
    freqs <- nos_clust/mciters
    cfreqs <- cumsum (freqs)
    
    ## select subsets by subset frequencies
	nsubsets <- length(which(freqs >= sfreq))
    freqs <- freqs [1:nsubsets]
    cfreq <- cfreqs [nsubsets]
    
    ## summarize feature subsets
    fsubsets <- rep (list (""), nsubsets)
    mcids <- rep (list (""), nsubsets)
    coefs <- rep (list (""), nsubsets)
    coefs_sel <- rep (list (""), nsubsets)   
    sdbs <- rep (list (""), nsubsets)
    ftab <- data.frame (matrix (0, nsubsets, 3))
    colnames (ftab) <-  c("fsubsets", "freqs", "coefs(w/int)")
    listbfsel <- c()
    
    for (i in 1:nsubsets)
    {
        ## indices of variables selected in this subset
        ix_fsubsets <- fset_mf [which (clusts[,i] == 1)]
        
        fsubsets[[i]] <- fithtlr$fsel[ix_fsubsets] ## original feature indices
        listbfsel <- c(listbfsel, fsubsets[[i]]) ## combine features indices
        mcids [[i]] <- which (iclust == i) ## markov chain indices
        ## coefs of all features
        coefs[[i]] <- htlr_mdcoef (fithtlr, usedmc = mcids[[i]])
        ## coefs for selected features        
        coefs_sel [[i]] <- coefs [[i]][c(0,ix_fsubsets) + 1,,drop = FALSE] 
        ## features importance indices 
        sdbs [[i]] <- comp_sdb (coefs [[i]])
        
        
        ## reporting tables
        ftab[i, 1] <- paste(fsubsets[[i]], collapse = ",")
        ftab[i, 2] <- round(freqs[i],2)
        ftab[i, 3] <- paste (round(coefs_sel[[i]],2), collapse = ",")
    }
    
    listbfsel <- sort(unique (listbfsel))
    nbfsel <- length (listbfsel)
    ## find weighted sdbs
    mat_sdbs <- matrix(unlist (sdbs), ncol = nsubsets)
    wsdbs <- rowSums(sweep (mat_sdbs, 2, freqs, "*") )
    ## find max sdbs         
    msdbs <- apply(mat_sdbs, 1, max)

    if (print)
    {
        print (ftab)
        cat (sprintf(
        "\n%d subsets with freq >= %.2f found from %.0f%% MC Iters\n",
         nsubsets, sfreq, cfreq * 100))
        cat (sprintf("%d features used in the %d subsets are:\n",
             nbfsel, nsubsets))
        cat(paste (listbfsel, collapse = ","), "\n")
    }
    
    out <- list (
            fsel = fithtlr$fsel, bfsel = listbfsel,
            mcids = mcids, fsubsets = fsubsets, coefs = coefs, 
            coefs_sel = coefs_sel, freqs = freqs,
            sdbs = sdbs, wsdbs = wsdbs, msdbs = msdbs, 
            ftab = ftab, cfreq = cfreq,  nbfsel = nbfsel)
}

plot_fscore <- function (fscores, fsel=1:length (fscores),show_ix = 0.01, ...)
{
    afscores <- abs (fscores)
    mfscore <- max (afscores)
    
    plotargs <- list (...)
    
    p <- length (fscores) 

    if (is.null (plotargs$log))  plotargs$log <- ""
    if (is.null (plotargs$type)) plotargs$type <- "h"
    
    if (is.null (plotargs$ylab) ) plotargs$ylab = "Feature Score"
    if (is.null(plotargs$xlab))plotargs$xlab <-"Variable Index" 
    if (is.null (plotargs$cex.axis))  plotargs$cex.axis <- 0.8
    
    # plot fscores   
    do.call (plot, c(list (x = fscores), plotargs) )
    
    # show shresholds 0.1 and 0.01
    abline (h = mfscore * c(-0.01,0.01), lty = 2, col = "grey")

    abline (h = mfscore * c(-0.1,0.1), lty = 1, col = "grey")
    
    # showtops             
    itops <- order (-afscores)
    
    ntops <- sum (afscores > show_ix * mfscore)
    
    if (ntops >=1) for (i in 1:min(ntops,p))
    {
        text (itops [i], fscores [itops[i]], fsel[itops[i]], 
              col = "red", srt = 0, adj = - 0.2, cex = 0.7)
    }
}


## deltas --- the values of deltas (for example true deltas) used to prediction
## fithtlr --- if this is not a null, will use Markov chain samples of deltas
## to do predictions.
htlr_predict <- function (X_ts, fithtlr = NULL, deltas = NULL,
                          burn = NULL, thin = NULL, usedmc = NULL)
{
    ## chaning X_ts as needed
    if (is.vector (X_ts)) X_ts <- matrix (X_ts, 1,)
    no_ts <- nrow (X_ts)

    if (is.null (deltas) & !is.null (fithtlr))
    {
        mcdims <- dim (fithtlr$mcdeltas)
        p <- mcdims [1] - 1
        K <- mcdims [2]
        no_mcspl <- mcdims[3]

        ## index of mc iters used for inference
        if (is.null(usedmc))
        {
		  if (is.null (burn)) burn <- floor (no_mcspl * 0.2)
		  if (is.null (thin)) thin <- 1
		  usedmc <- seq (burn + 1, no_mcspl, by = thin)
        }
       
        no_used <- length (usedmc)

        ## read deltas for prediction
        longdeltas <- matrix (fithtlr$mcdeltas[,,usedmc], nrow = p + 1)

        ## selecting features and standardizing
        fsel <- fithtlr$fsel
        X_ts <- X_ts [, fsel, drop = FALSE]
        nuj <- fithtlr$nuj
        sdj <- fithtlr$sdj
        X_ts <- sweep (X_ts, 2, nuj, "-")
        X_ts <- sweep (X_ts, 2, sdj, "/")
    }
    else
    {   
        if (is.vector (deltas)) 
        deltas <- matrix (deltas, , length (deltas))
        K <- ncol (deltas)
        p <- nrow (deltas) - 1
        longdeltas <- deltas
        no_used <- 1
    }

    ## add intercept to all cases
    X_addint_ts <- cbind (1, X_ts)

    longlv <- X_addint_ts %*% longdeltas
    arraylv <- array (longlv, dim = c(no_ts, K, no_used))
    logsumlv <- apply (arraylv, 3, comp_lsl)
    array_normlv <- sweep (arraylv, c(1,3), logsumlv)
    array_predprobs <- exp (array_normlv)
    probs_pred <- apply (array_predprobs, c(1,2), mean)

    predprobs_c1 <- pmax(0, 1 - apply (probs_pred, 1, sum) )
    probs_pred <- cbind (predprobs_c1, probs_pred)
    values_pred <-  apply (probs_pred, 1, which.max)

    list (probs_pred = probs_pred, values_pred = values_pred)
}


## a function for retrieve fithtlr objs saved in a RData file
reload_fithtlr <- function (fithtlrfile)
{
    local
    ({
        fithtlr <- get (load (fithtlrfile))
        return (fithtlr)
    })
}


########################### utility functions ###############################

## compute V (delta)
comp_vardeltas <- function (deltas)
{
    K <- ncol (deltas)
    SUMdeltas <- rowSums (deltas)
    SUMsqdeltas <- rowSums (deltas^2)
    SUMsqdeltas  - SUMdeltas^2 / (K + 1)
}

## compute sd of betas
comp_sdb <- function (deltas, removeint = TRUE, normalize = FALSE)
{
    C <- ncol (deltas) + 1
    if (removeint)
    {
        deltas <- deltas[-1,,drop = F]
    }
    
    vardeltas <- comp_vardeltas (deltas)
    sdb <- sqrt (vardeltas/C)
    
    if (normalize) sdb <- sdb / max(sdb)
    
    sdb
}


comp_lsl <- function (lv)
{
    apply (cbind (0,lv), 1, log_sum_exp)
}

spl_sgm_ig <- function (alpha, K, w, vardeltas)
{
  1 / rgamma (length (vardeltas), (alpha + K)/2) * (alpha * w + vardeltas) / 2
}

get_ix <- function (sub, whole, digits= 0)
{
    p <- length (whole)
    wix <- 1:p
    names (wix) <- as.character (round(whole, digits))
    wix [as.character (round(sub, digits))]
}

######################## some functions not used currently ###################

if (F)
{

htlr_ci <- function (fithtlr, usedmc = NULL)
{
    mcdims <- dim (fithtlr$mcdeltas)
    p <- mcdims [1] - 1
    K <- mcdims [2]
    no_mcspl <- mcdims[3]

    ## index of mc iters used for inference

    mcdeltas <- fithtlr$mcdeltas[,,usedmc, drop = FALSE]
    
    cideltas <- array (0, dim = c(p+1, K, 3))
    for (j in 1:(p+1))
    {
        for (k in 1:K) {
          cideltas [j,k,] <- 
            quantile (mcdeltas[j,k,], probs = c(1-cp, 1, 1 + cp)/2)
        }
    }
    
    cideltas
}

## this function plots confidence intervals
htlr_plotci <- function (fithtlr, usedmc = NULL, 
                         cp = 0.95, truedeltas = NULL,   ...)
{
    
    cideltas <- htlr_coefs (fithtlr, usedmc = usedmc, showci = TRUE, cp = cp)
    K <- dim (cideltas)[2]
    
    for (k in 1:K)
    {
        plotmci (cideltas[,k,], truedeltas = truedeltas[,k], 
                 main = sprintf ("%d%% MC C.I. of Coefs (Class %d)", 
                                 cp * 100, k+1),
                ...)
        
    }
    
    return (cideltas)
}


htlr_outpred <- function (x,y,...)
{
  X_ts <- cbind (x, rep (y, each = length (x)))
  probs_pred <- htlr_predict (X_ts = X_ts, ...)$probs_pred[,2] 
  matrix (probs_pred, nrow = length (x) )
}


norm_coef <- function (deltas)
{
  slope <- sqrt (sum(deltas^2))
  deltas/slope
}

pie_coef <- function (deltas)
{
  slope <- sum(abs(deltas))
  deltas/slope
}

norm_mcdeltas <- function (mcdeltas)
{
  sqnorm <- function (a) sqrt(sum (a^2))
  dim_mcd <- dim (mcdeltas)
    
  slopes <- apply (mcdeltas[-1,,,drop=FALSE], MARGIN = c(2,3), sqnorm)
    
  mcthetas <- sweep (x = mcdeltas, MARGIN = c(2,3), STATS = slopes, FUN = "/")
  
  list (mcthetas = mcthetas, slopes = as.vector(slopes))
}

pie_mcdeltas <- function (mcdeltas)
{
  sumabs <- function (a) sum (abs(a))
  dim_mcd <- dim (mcdeltas)
    
  slopes <- apply (mcdeltas[-1,,,drop=FALSE], MARGIN = c(2,3), sumabs)
    
  mcthetas <- sweep (x = mcdeltas, MARGIN = c(2,3), STATS = slopes, FUN = "/")
  
  list (mcthetas = mcthetas, slopes = as.vector(slopes))
}

plotmci <- function (CI, truedeltas = NULL, ...)
{
    p <- nrow (CI) - 1

    plotargs <- list (...)
    
    if (is.null (plotargs$ylim)) plotargs$ylim <- range (CI)
    if (is.null (plotargs$pch))  plotargs$pch <- 4 
    if (is.null (plotargs$xlab)) 
       plotargs$xlab <- "Feature Index in Training Data"
    if (is.null (plotargs$ylab)) plotargs$ylab <- "Coefficient Value"
    
    do.call (plot, c (list(x= 0:p, y=CI[,2]), plotargs))
    
    abline (h = 0)
    
    for (j in 0:p)
    {
        
        points (c(j,j), CI[j+1,-2], type = "l", lwd = 2)
    }
    
    if (!is.null (truedeltas))
    {
        points (0:p, truedeltas, col = "red", cex = 1.2, pch = 20)
    }

}



htlr_plotsdb <- function (fithtlr, features = "all", usedmc = "all", 
                doplot = TRUE, ntops = 0.1, stat = median, ...)
{
    mcdims <- dim (fithtlr$mcdeltas)
    p <- mcdims [1] - 1
    K <- mcdims [2]
    C <- K + 1
    no_mcspl <- mcdims[3]
    
    features <- features [!is.na (features)]
    if (usedmc [1] == "all") 
    {
        usedmc <- 1:no_mcspl
    }

    if (features[1] == "all" || length (features) > 2)
    {
        deltas <- htlr_mdcoef (fithtlr,usedmc = usedmc)
        sdbs <- comp_sdb (deltas, removeint = T, normalize = F)
        if (doplot) {
            plot_fscore (sdbs, fsel = fithtlr$fsel, ntops = ntops, 
#            method = sprintf ("Hhtlr with %s(df=%3.1f, log(w)=%3.1f)", 
#                     fithtlr$ptype, fithtlr$alpha, 
#                     median (fithtlr$mclogw[usedmc]) ), 
            ...)
        }
    }
    else if (length (features) == 1)
    {
        plotargs <- list (...)
        if (is.null(plotargs$log)) plotargs$log <- ""
        if (is.null(plotargs$pch)) plotargs$pch <- 20
        
        if (features == 0) ixf <- 0 else
        ixf <- which (fithtlr$fsel == features)
        
        sdbs <- sqrt(fithtlr$mcvardeltas[ixf + 1, usedmc]/C)
        
        do.call (plot, 
              c(plotargs,  list (x = sdbs, 
              xlab = "Markov Chain Index (after burning and thinning)", 
              ylab = "SDB",
              main = sprintf ("MC SDBs of Feature %d", features)
              ) )
        ) 
    }
    else if (length (features) == 2)
    {
        plotargs <- list (...)
        if (is.null(plotargs$log)) plotargs$log <- ""
        if (is.null(plotargs$pch)) plotargs$pch <- 20

        ixf <- c(1,2)
        if (features[1] == 0) ixf[1] <- 0 else
        ixf[1] <- which (fithtlr$fsel == features[1])
        
        if (features[2] == 0) ixf[2] <- 0 else
        ixf[2] <- which (fithtlr$fsel == features[2])
        
        sdb1 <- sqrt(fithtlr$mcvardeltas[ ixf [1] + 1, usedmc])/C
        sdb2 <- sqrt(fithtlr$mcvardeltas[ ixf [2] + 1, usedmc])/C
        
        do.call (plot, 
              c (plotargs, list (x = sdb1, y = sdb2, 
              xlab = sprintf ("SDB of Feature %d", features [1]), 
              ylab = sprintf ("SDB of Feature %d", features [2]),
              main = sprintf("MC Samples of SDBs of Features %d and %d",
                     features[1], features[2])
              ))
        )
        
        sdbs <- cbind (sdb1, sdb2)
    }
    
    out <- sdbs
}

htlr_plotleapfrog <- function ()
{
        if (looklf & i_mc %% iters_imc == 0 & i_mc >=0 )
        {
           if (!file.exists ("leapfrogplots")) dir.create ("leapfrogplots")

           postscript (file = sprintf ("leapfrogplots/ch%d.ps", i_sup),
           title = "leapfrogplots-ch", paper = "special",
           width = 8, height = 4, horiz = FALSE)
           par (mar = c(5,4,3,1))
           plot (-olp$nenergy_trj + olp$nenergy_trj[1],
                xlab = "Index of Trajectory", type = "l",
                ylab = "Hamiltonian Value",
                main =
                sprintf (paste( "Hamiltonian Values with the Starting Value",
                "Subtracted\n(P(acceptance)=%.2f)", sep = ""),
                min(1, exp(olp$nenergy_trj[L+1]-olp$nenergy_trj[1]) )
                )
           )
           abline (h = c (-1,1))
           dev.off()

           postscript (file = sprintf ("leapfrogplots/dd%d.ps", i_sup+1),
           title = sprintf("leapfrogplots-dd%d", i_sup + 1), 
           paper = "special",
           width = 8, height = 4, horiz = FALSE)
           par (mar = c(5,4,3,1))
           plot (olp$ddeltas_trj, xlab = "Index of Trajectory",type = "l",
                 ylab = "square distance of Deltas",
                 main = "Square Distance of `Deltas'")
           dev.off ()

           postscript (file = sprintf ("leapfrogplots/ll%d.ps", i_sup),
           title = "leapfrogplots-ll", paper = "special",
           width = 8, height = 4, horiz = FALSE)
           par (mar = c(5,4,3,1))
           plot (olp$loglike_trj, xlab = "Index of Trajectory", type = "l",
                 ylab = "log likelihood",
                 main = "Log likelihood of Training Cases")
           dev.off()
        }
}



}


