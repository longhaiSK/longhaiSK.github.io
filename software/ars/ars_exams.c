#include "ars.c"
// this function samples from truncated normal with ARS
void R_sample_tnorm (int n[1], double rn[n[0]],
     double lb[1], double ub[1], double dars[1])
{
  //define function evaluation logf and derivative logf
  void eval_logdnorm (double x, double logf[1], double dlogf[1])
  {
    if (x > ub[0] || x < lb[0])
    {
      logf[0] = -INFINITY;
      dlogf[0] = NAN;
      return;
    }

    logf[0] = - pow (x, 2)/2;
    dlogf[0] = - x;
  }

  // define initial tangent point
  double ini_tpoint;

  if (isfinite (lb[0]) && isfinite (ub[0]))
    ini_tpoint  = (lb[0] + ub [0])/2.0;
  if (isfinite(lb[0]) && !isfinite (ub[0]))
    ini_tpoint  = lb[0] + 1;
  if (!isfinite(lb[0]) && isfinite(ub[0]))
    ini_tpoint  = ub[0] - 1;
  if (!isfinite(lb[0]) && !isfinite(ub[0]))
    ini_tpoint  = 0;

  //call function sample_ars to do adaptive rejection sampling
  sample_ars (n[0], rn, eval_logdnorm, lb[0], ub[0], ini_tpoint, dars[0]);

}

// this function samples from gamma distribution
void R_sample_gamma (int n[1], double rn[n[0]],
     double alpha [1], double lambda [1], double dars[1])
{
  if (alpha[0] < 1)
  {
    printf ("When alpha < 1, gamma isn't log-concave\n");
    exit (1);
  }

  //define function evaluation logf and derivative logf
  void eval_logdgamma (double x, double logf[1], double dlogf[1])
  {

    if (x <= 0)
    {
      logf[0] = -INFINITY;
      dlogf[0] = NAN;
      return;
    }

    logf[0] = (alpha[0] - 1) * log (x) - lambda [0] * x;
    dlogf[0] = (alpha[0] - 1) / x - lambda [0];
  }

  // define initial tangent point
  double ini_tpoint = alpha[0]/lambda[0];

  //call function sample_ars to do adaptive rejection sampling
  sample_ars (n[0], rn, eval_logdgamma, 0, INFINITY, ini_tpoint, dars[0]);

}

// this function samples from truncated beta
void R_sample_beta (int n[1], double rn[n[0]], double alpha[1],
     double beta[1], double lb[1], double ub[1], double dars[1])
{
  if (alpha[0] < 1 || beta[0] < 1)
  {
    printf ("When alpha < 1 or beta < 1, beta isn't log-concave\n");
    exit (1);
  }

  void eval_logdbeta (double x, double logf[1], double dlogf[1])
  {
    if (x < lb[0] || x > ub[0])
    {
      logf[0] = -INFINITY;
      dlogf[0] = NAN;
      return;
    }

    logf[0] = 0;
    dlogf[0] = 0;

    if (alpha [0] != 1)
    {
      logf[0] += (alpha[0] - 1) * log (x);
      dlogf[0] += (alpha[0] - 1) / x;
    }

    if (beta[0] != 1)
    {
      logf[0] +=  (beta[0] - 1) * log (1-x);
      dlogf[0] += - (beta[0] - 1) / (1-x);
    }
  }

  double ini_tpoint;
  ini_tpoint = (lb[0] + ub[0])/2;
  sample_ars (n[0], rn, eval_logdbeta, lb[0], ub[0], ini_tpoint, dars[0]);
}