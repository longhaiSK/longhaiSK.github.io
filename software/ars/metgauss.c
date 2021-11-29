void metgauss (
  int no_sup, double thin, int p,
  double inix [p], double mc [no_sup][p], double stepsizes [p],
  double rate_rej [1], double (*eval_logf)(double x[p]) )
{
  int imc, isup, j, no_rej;
  double newlogf, newx[p], logf, x[p];

  for (j = 0; j < p; j++) x[j] = initx[j];

  logf = eval_logf (newx);
  no_rej = 0;

  if (!isfinite (logf))
  { printf ("In metgauss Sampling, initial value has 0 probability\n");
    exit (1);
  }

  for (isup = 0; isup < no_sup; isup ++)
  {
    for (j = 0; j < p; j++)
     = rnorm (logw[0], stepsize[0]);
//     printf ("\n current logw = %.2f, proposed logw = %.2f\n", logw[0], logw_prop);
    logf_prop = logpost_logw (logw_prop);

    if (log (runif(0,1)) < logf_prop - logf[0])
    {
      logw[0] = logw_prop;
      logf[0] = logf_prop;
    }
    else
    {
      no_rej ++;
    }
  }

  rr[0] = no_rej/logw_iters[0];
  // logw[0] will be returned to R
}

/*
   log_post_logw <- function (logw)
#         {
#             ldt (vardeltas[-1], p, K, nu, logw) +
#             dnorm (logw, logw0, w_logw0, log = TRUE)
#         }

ldt <- function (vardeltas, p, K, nu, logw)
{
  - (nu + K) / 2 * sum (log (vardeltas + exp (logw) * nu)) + logw * p * nu / 2
}

met_gauss2 <- function (iters = 100, stepsize = 0.5, log_f, ini_value,
              iters_imc = 1,  ...)
{
    state <- ini_value
    no_var <- length (state)
    logf <- log_f (ini_value,...)

    if (!is.finite (logf)) stop ("Initial value has 0 probability")

    one_mc <- function ()
    {
        new_state <- rnorm (no_var, state, stepsize)
        new_logf <- log_f (new_state,...)

        if (log (runif(1)) < new_logf - logf)
        {
            state <<- new_state
            logf <<- new_logf
        }
    }

    one_sup <-  function ()
    {
        replicate (iters_imc, one_mc())
        state
    }

    replicate (iters, one_sup () )
}*/
