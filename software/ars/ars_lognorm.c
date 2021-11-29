////////////////////// file: ars_lognorm.c ////////////////////////////////////
#include "ars.c"

void R_sample_post_s (int n[1], double s_rn[n[0]],
                      int p[1], double x[p[0]], double mu[1],
                      double s0[1], double sigma0_s[1],
                      double dars[1])
{
  int i;
  double var_x = 0;
  for (i = 0; i < p[0]; i++)
  {
    var_x += pow (x[i] - mu[0], 2);
  }

  void eval_logpost (double s, double logf[1], double dlogf[1])
  {
    logf[0] = - var_x/exp (2*s)/2 - s * p[0] - pow ((s - s0[0])/sigma0_s[0],2)/2;
    dlogf[0] = var_x /exp (2*s) - p[0] - (s - s0[0])/pow(sigma0_s[0],2);
  }
  sample_ars (n[0], s_rn, eval_logpost, -INFINITY, +INFINITY, 0, dars[0]);
}

