# include "ars.c"

void R_sample_beta (int n[1], double rn[n[0]], double alpha[1], double beta[1],
                    double lb[1], double ub[1], double dars[1])
{
  void eval_logtbeta (double y, double logf[1], double dlogf[1])
  {
    logf[0] = alpha[0] * y - (alpha[0] + beta[0]) * log (1 + exp (y));
    dlogf[0] = alpha[0] - (alpha[0] + beta[0]) / (1 + exp (-y));
  }
  double m;
  m = (lb[0] + ub[0])/2.0;
  sample_ars (n[0], rn, eval_logtbeta,
              log(lb[0]) - log (1-lb[0]),
              log(ub[0]) - log (1-ub[0]),
              log(m) - log (1-m), dars[0]);

  int i;
  for (i = 0; i < n[0]; i++) rn[i] = 1/(1 + exp (-rn[i]));
}

