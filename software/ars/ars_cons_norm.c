/////////////////////// file: ars_cons_norm.c ////////////////////////////////
#include "ars.c"

void R_sample_tnorm (int n[1], double rn[n[0]],
     double lb[1], double ub[1], double ini_tpoint[1], double dars[1])
{
  //define function evaluating logf and derivative logf
  void eval_logdnorm (double x, double logf[1], double dlogf[1])
  {
    if (x > ub[0] || x < lb[0])
    // if ub and lb cannot be found explicitely, this checking condition can be
    // replaced by another checking expression, eg. power (x,2) < 1
    {
      logf[0] = -INFINITY;
      dlogf[0] = NAN;
      return;
    }
    
    logf[0] = - pow (x, 2)/2;
    dlogf[0] = - x;
  }
  // call function sample_ars to do adaptive rejection sampling
  // Note that the bounds are set to -Inf and +Inf, so the actual bounds
  // are to be determined by the ARS sampler.
  sample_ars (n[0], rn, eval_logdnorm, -INFINITY, +INFINITY, 
              ini_tpoint[0], dars[0]);
}

