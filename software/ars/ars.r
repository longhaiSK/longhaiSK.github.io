
# NOTE: in this program, I call a piece of linear function as 'hull', and
# the piecewise linear function above dlog upperhulls, and
# the piecewise linear function below dlogf lowerhulls

sample_ars
    (n, # sampling output
     eval_logf,     # function for evaluate logf and dlogf
     # lower and upper bounds of logf, and initial tangent point
     lb = - Inf, ub = Inf, ini_tpoint, dars = 0)
{
  ##************************* User Settings *******************************##
  #set maximum number of pieces of linear hulls
  max_nhull = 1000;
  #set smallest difference of derivatives that can be thought of as the same
  #so that we don't need to insert one more hull
  tol_dlogf_is0 = 1E-10, tol_ddlogf_is0 = 1E-10;
  stepout = 10; # size of stepout in initializing linear hulls
  ############### end of user settings ###########/

  # global working vectors used to represent linear hulls
  # an element corresponding to a tangent point
  tpoints [max_nhull], # tangent points
  lws [max_nhull], # log integrals of exp hulls
  lowerbounds[max_nhull], upperbounds[max_nhull], #bounds of hulls
  #values of logf and dlogf at tangent points
  logfvs[max_nhull], dlogfvs[max_nhull],
  #slopes of left and right squeezings
  slopes_leftsq[max_nhull],slopes_ritesq[max_nhull];
  #indice of left and right hulls
  lefthulls [max_nhull], ritehulls [max_nhull],
  no_hulls; # total number of hulls

  #construct the first hull
  tpoints [1] = ini_tpoint; #the tangent point
  eval_logf (tpoints[1], &logfvs[1], &dlogfvs[1]);
  if (!is.finite (logfvs[1]))
  {
    sprintf ("Error in adaptive rejection sampling:\n");
    sprintf ("the first tangent podoesn't have positive probability.\n");
    stop ()
  }
  lowerbounds [1] = fmax2(lb, -Inf); # lower bound of the hull
  upperbounds [1] = fmin2(ub, +Inf); # upper bound of the hull
  lefthulls [1] = -1; # index of left hull
  ritehulls [1] = max_nhull; #index of right hull
  slopes_leftsq [1] = Inf; # slope of left squeezing arc
  slopes_ritesq [1] = -Inf; # slope of right sequeezing arc
  #compute log weights, updating lw[1]
  lws[1] = Inf;
  no_hulls = 1;

  # this function updates the envolop and squeezing functions.
  # newx --- new poto be inserted
  # h --- index of the hull where newx is from
  # logfv, dlogfv --- values of logf and dlogv at newx
  update_hulls (h, newx, logfv, dlogfv)
  {
    lh, rh, nh;

    if (no_hulls == max_nhull) return;# reaching the limit of working vector

    #specify left and right hulls of new hull
    if (newx > tpoints[h]) # to insert to the right of hull h
    {
      lh = h; rh = ritehulls[h];
      # if logfv is -infinity, only update the rightest hull rightbound and lw
      if (rh == max_nhull & logfv == - Inf)
      {
        if (upperbounds[h] != newx)
        {
          upperbounds [h] = newx;
          logint_elin (
            &logfvs[h], &dlogfvs[h],
            &tpoints[h], &lowerbounds[h],
            &upperbounds[h], &lws[h], &tol_dlogf_is0);
        }
        return;
      }
    }
    else # to insert to the left of hull h
    {
      lh = lefthulls[h]; rh = h;
      # if logfv is -infinity, only update the leftest hull leftbound and lw
      if (lh == -1 & logfv == - Inf)
      {
        if (lowerbounds [h] != newx)
        {
          lowerbounds [h] = newx;
          logint_elin (
            &logfvs[h], &dlogfvs[h],
            &tpoints[h], &lowerbounds[h],
            &upperbounds[h], &lws[h], &tol_dlogf_is0);
        }
        return;
      }
    }

    #insert a new hull
    nh = no_hulls;
    no_hulls ++;
    tpoints[nh] = newx;
    logfvs[nh] = logfv;
    dlogfvs[nh] = dlogfv;
    lefthulls[nh] = lh;
    ritehulls[nh] = rh;

    if (lh == -1) # nh will be the new leftest hull
    {
      lowerbounds [nh] = lowerbounds [h];
      slopes_leftsq [nh] = + Inf;
    }
    else
    {
      lowerbounds[nh] = interc (&tpoints[lh], &tpoints[nh],
        &logfvs[lh], &logfvs[nh], &dlogfvs[lh], &dlogfvs[nh],
        &tol_ddlogf_is0); # lowerbound
      slopes_leftsq [nh] = (logfvs[nh] - logfvs[lh]) /
                           (tpoints[nh] - tpoints[lh]);
    }
    if (rh == max_nhull)
    {
      upperbounds[nh] = upperbounds[h]; # upperbound
      slopes_ritesq[nh] = -Inf;
    }
    else
    {
      upperbounds[nh] = interc (&tpoints[nh], &tpoints[rh],
        &logfvs[nh], &logfvs[rh], &dlogfvs[nh], &dlogfvs[rh],
        &tol_ddlogf_is0); # upperbound
     slopes_ritesq [nh] = (logfvs[nh] - logfvs[rh]) /
                          (tpoints[nh] - tpoints[rh]);
    }

    logint_elin (
          &logfvs[nh], &dlogfvs[nh],
          &tpoints[nh], &lowerbounds[nh],
          &upperbounds[nh], &lws[nh], &tol_dlogf_is0);

    #update left hull of new null
    if (lh != -1)
    {
      upperbounds[lh] = lowerbounds[nh];
      ritehulls[lh] = nh;
      slopes_ritesq[lh] = slopes_leftsq [nh];
      logint_elin (
          &logfvs[lh], &dlogfvs[lh],
          &tpoints[lh], &lowerbounds[lh],
          &upperbounds[lh], &lws[lh], &tol_dlogf_is0);
    }

    #update right hull of newh if it exists
    if (rh != max_nhull)
    {
        lowerbounds[rh] = upperbounds[nh];
        lefthulls[rh] = nh;
        slopes_leftsq[rh] = slopes_ritesq [nh];

        logint_elin (
          &logfvs[rh], &dlogfvs[rh],
          &tpoints[rh], &lowerbounds[rh],
          &upperbounds[rh], &lws[rh], &tol_dlogf_is0);
    }
  }

  newx, newlogf, newdlogf; # a new tangent poto be inserted
  h; # index of the hull where newx is from
  newh; # index of new inserted hull

  # if lb is finite, bound the first hull at left
  # or insert a hull tangent at lb if logf at lb is finite too
  if (is.finite (lb))
  {
    h = 0;
    newx = lb;
    eval_logf (newx, &newlogf, &newdlogf);
    update_hulls (h, newx, newlogf, newdlogf);
  }
  #expanding at the left until reaching a bound or integral to finite
  else
  {

    h = 0;
    newx = tpoints[1] - stepout;
    do
    {
      if (no_hulls == max_nhull)
      {
        sprintf ("Error in Rejection Sampling:\n");
        sprintf ("'max_nhull' is set too small, or your log-PDF NOT concave\n");
        stop ()
      }
      eval_logf (newx, &newlogf, &newdlogf);
      update_hulls (h, newx, newlogf, newdlogf);
      # finding a new leftbound quite expanding
      if (newlogf == - Inf) break;
      newx -= stepout;
      h = no_hulls - 1;
    }
    while (newdlogf < tol_dlogf_is0);
  }

  # if ub is finite, bound the first hull at the right
  # or insert a hull tangent at ub if logf at ub is finite too
  if (is.finite (ub))
  {
    h = 0;
    newx = ub;
    eval_logf (newx, &newlogf, &newdlogf);
    update_hulls (h, newx, newlogf, newdlogf);
  }
  else # expanding at the right until reaching a bound or integral to finite
  {
    h = 0;
    newx = tpoints[1] + stepout;
    do
    {
      if (no_hulls == max_nhull)
      {
        sprintf ("Error in Rejection Sampling:\n");
        sprintf ("'max_nhull' is set too small, or your log-PDF NOT concave\n");
        stop ()
      }

      eval_logf (newx, &newlogf, &newdlogf);
      update_hulls (h, newx, newlogf, newdlogf);
      if (!is.finite (newlogf)) break;
      newx += stepout;
      h = no_hulls - 1;
    }
    while (newdlogf > - tol_dlogf_is0);

  }

  eval_upperhull (h, newx)
  {
    return ((newx - tpoints[h]) * dlogfvs[h] + logfvs[h]);
  }

  eval_lowerhull (h, newx)
  {
     if (newx >= tpoints[h])
     {
       return ((newx - tpoints[h]) * slopes_ritesq[h] + logfvs[h]);
     }
     else
     {
       return ((newx - tpoints[h]) * slopes_leftsq[h] + logfvs[h]);
     }
  }

  #**************** Doing adaptive rejection sampling ********************#
  # define parameters used while sampling
  one = 1, no_rejs = 0, i, rejected;
  double
  upperhullv, # value of upper hull at newx
  lowerhullv, # value of lower (squeezing) hull at newx
  u, # a random number used to determine whether to accept
  logacceptv; #if logacceptv is smaller than logf, newx  accepted ;

  for (i = 0; i < n; i++)
  {
    rejected = 1;
    while (rejected)
    {
      #draw a new poand a unif random number
      sample_disc (&one, &h, &no_hulls, lws);
      sample_elin (&one, &newx, &lowerbounds[h], &upperbounds[h],
                   &dlogfvs[h], &tol_dlogf_is0);
      upperhullv = eval_upperhull (h, newx);
      GetRNGstate (); u = unif_rand (); PutRNGstate ();
      logacceptv = upperhullv + log (u);
      lowerhullv = eval_lowerhull (h, newx);
      #check acceptance with squeezing function
      if (logacceptv <= lowerhullv)
      {
        rn [i] = newx;
        rejected = 0;
      }
      else
      {
        # check acceptance with logf
        # eval logf at newx and insert a new hull
        eval_logf (newx, &newlogf, &newdlogf);
        update_hulls (h, newx, newlogf, newdlogf);
        if (logacceptv <= newlogf)
        {
          rn [i] = newx;
          rejected = 0;
        }
        else no_rejs ++;
      }
    }
 }

 rate_rej;
 if (dars == 1)
 {
  rate_rej = (no_rejs + 0.0) / (no_rejs + n + 0.0); # return rejection rate
  sprintf ("no of hulls = %d, rejection rate = %4.2f\n", no_hulls, rate_rej);
 }
}

# find maximum value in vector a with length n
fmaxm (n, a[n])
{
  ma;
  i;
  ma = a [1];
  if (n > 1)
  {
    for (i = 1; i < n; i++)
    {
      ma = fmax2 (a[i], ma);
    }

  }
  return (ma);
}

# n --- number of random numbers
# k --- number of discrete values
# lw --- log of probabilities
# rn --- vector of random numbers returned
sample_disc (n[1], rn[n[1]], k[1], lw[k[1]])
{
  cw[k[1]], u, max_lw;
  i, j;

  # constructing probabilities from log probabilities
  max_lw = fmaxm (k[1], lw);
  cw[1] = exp(lw[1] - max_lw);
  for (i = 1; i < k[1]; i++) cw [i] = cw [i-1] + exp(lw [i] - max_lw);

  for (j = 0; j < n[1]; j++)
  {
    GetRNGstate ();
    u = unif_rand() * cw[k[1] - 1];
    PutRNGstate ();
    # convert u into a discrete value
    for (i = 0; i < k[1]; i++)
    {
      if (u <= cw[i])
      {
        rn[j] = i;
        break;
      }
    }
  }
}

# this function samples from: exp (a[1]*x) I (x in [lb, upper[1]])
# n is number of random numbers required, rn will store random numbers
sample_elin
   (n[1], rn[n[1]], lower[1], upper[1],
    dlogf[1], tol_dlogf_is0[1])
{
  # set smallest value for derivative that can be thought of as 0
   y, dx;
  j, type_lin, isfault = 0;

  # checking linear function type and fault
  if (fabs (dlogf[1]) <= tol_dlogf_is0 [1])
  {
     if (! ( is.finite (lower[1]) & is.finite (upper[1])) )
     {
       isfault = 1;
     }
     else
     {
       type_lin = 0;
     }
  }

  if (dlogf[1] >  tol_dlogf_is0 [1])
  {
    if (!is.finite (upper[1]))
    {
      isfault = 1;
    }
    else
    {
      type_lin = 1;
    }
  }

  if (dlogf[1] < -tol_dlogf_is0 [1])
  {
    if(!is.finite (lower[1]))
    {
      isfault = 1;
    }
    else
    {
      type_lin = -1;
    }
  }

  if (isfault)
  {
    sprintf ( "Error: in  'sample_elin':\n");
    sprintf ( "the exp linear function integrates to Inf\n");
    sprintf ( "(dlogf = %4.2f, lowerbound = %4.2f, upperbound = %4.2f)\n",
             dlogf[1], lower[1], upper[1]);
    stop ()
  }

  dx = upper[1] - lower[1];

  for (j = 0; j < n[1]; j++)
  {
    GetRNGstate ();
    y = runif (0,1);
    PutRNGstate ();

    #converting uniform random number
    if (type_lin == 0 ) # slope is 0
      rn[j] = lower[1] + y * dx;

    if (type_lin == 1) # slope is postive
      rn[j] = upper[1] +
         log ( (1 - y) * exp (- dlogf[1] * dx) + y) / dlogf[1];

    if (type_lin == -1) #slope is negative
      rn[j] = lower[1] +
         log ( 1 - y + y * exp (dlogf[1] * dx) ) / dlogf[1];
  }
}

# this function evaluates the log of integral of exp linear hull
# logf --- value of linear hull at t
# dlogf --- value of derive of linear hull
# t --- tangent powhere logf is calculated
# lower and upper --- lower and upper bounds of linear hull
# lw --- saved returned log integral
logint_elin
  (logf[1],dlogf[1],t[1],
   lower[1],upper[1], lw[1],
   tol_dlogf_is0[1])
{
   dx, abs_dlogf;
  sgn_dlogf;

  dx = upper [1] - lower [1];
  abs_dlogf = fabs (dlogf[1]);


  if (abs_dlogf <= tol_dlogf_is0 [1]) # slope is 0
  {
    lw[1] = logf[1] + log (dx);
    return;
  }

  if (dlogf[1] > tol_dlogf_is0 [1]) sgn_dlogf = 1; else sgn_dlogf = -1;

  if (sgn_dlogf == 1) # slope is positive
  {
    lw[1] = logf[1] + dlogf[1] * (upper[1] - t[1]) - log (abs_dlogf)  +
            log (1 - exp (- abs_dlogf * dx) );
    return;
  }

  if (sgn_dlogf == -1) #slope is negative
  {
    lw[1] = logf[1] + dlogf[1] * (lower[1] - t[1]) - log (abs_dlogf)  +
            log (1 - exp (- abs_dlogf * dx) );
    return;
  }
}

# this function finds interception points between t1 and t2
interc (
  t1[1], t2[1],
  logf1[1], logf2[1], dlogf1[1], dlogf2[1],
  tol_ddlogf_is0[1] )
{
  if (fabs (dlogf1[1]-dlogf2[1]) > tol_ddlogf_is0 [1])
  {
    return (
      (logf2[1] - logf1[1] - dlogf2[1] * t2[1] + dlogf1[1] * t1[1]) /
      (dlogf1[1] - dlogf2[1])
    );
  }
  else
  {
    return ((t1[1] + t2[1])/2.0);
  }

}
