///////////////// file: ars_post_ichi.c /////////////////////////////////////
# include "ars.c"

void R_sample_post_ichi (int n[1], int p[1],
     double sigma2 [p[0]], double alpha1[1], double rn_s[n[0]],
     double alpha0[1], double w0[1], double dars[1] )
{
  int i;
  double alpha_p, lambda_p = 0, lambda0;
  for(i = 0; i < p[0]; i++)
  {
    lambda_p += 1/sigma2[i];
  }

  lambda_p *= alpha1[0] / 2.0;
  alpha_p = (p[0] * alpha1[0] - alpha0[0]) / 2.0;
  lambda0 = alpha0[0] * w0[0] / 2.0;

  if (alpha_p < 1.0)
  {
    printf ("Error in 'R_sample_post_ichi:\n'");
    printf ("Posterior alpha is less than 1, not log-concave\n");
    exit (1);
  }
  void eval_logpost_ichi (double s, double logf[1], double dlogf[1])
  {
    double exps, iexps;
    exps = exp (s);
    iexps = 1/exps;
    logf[0] = alpha_p * s - lambda_p * exp (s) - lambda0 * iexps;
    dlogf[0] = alpha_p - lambda_p * exps + lambda0 * iexps;
  }

  sample_ars (n[0], rn_s, eval_logpost_ichi, -INFINITY, INFINITY, 0, dars[0]);

}

