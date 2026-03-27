// double sum_double(int len,double A[len])
// {  int i; double out=0;
//    for(i = 0; i < len; i++) out += A[i];
//    return(out);
// }

void comp_adjfactor
  (double cut_dpoi[1], int no_qf[1], int no_lmd[1],
   double qf[], double lmd[], double adjfactor[1] )
{
     double dpoi_low, dpoi_up, adjfactor_lmd[no_lmd[0]], lambda,
            sum_dpois [no_qf[0]]; // sumalldpoi;
     int m, l, l_low, l_up, L_md, L_low, L_up, L_max;

     L_max = no_qf[0] - 1;
     for(l = 0; l <= L_max; l++) sum_dpois [l] = 0;

     for(m = 0; m < no_lmd[0]; m ++)
     {
	lambda = lmd[m];

        //determine lower and upper starting l
	L_md = floor (lambda);
        L_low = imin2 (L_md, L_max);
        L_up = L_low + 1;
        dpoi_low = exp (-lambda+ L_low * log(lambda)- lgammafn (L_low + 1) );
        dpoi_up = dpoi_low * lambda / L_up;

	// summing poisson weight in lower tail
        for (l_low = L_low; l_low >= 0; l_low --)
        {
            if (dpoi_low > cut_dpoi[0])
            {
                sum_dpois[l_low] += dpoi_low;
                dpoi_low /= lambda/l_low;
            }
            else break;
         }

         if (L_up > L_max) continue;
	 // summing poisson weight in upper tail
	 for (l_up = L_up; l_up <= L_max; l_up ++)
         {
            if (dpoi_up > cut_dpoi[0])
            {
                sum_dpois[l_up] += dpoi_up;
                dpoi_up *= lambda/(l_up+1);
            }
            else break;
         }
     }
     adjfactor [0] = 0;
//      sumalldpoi = 0;
     for(l = 0; l <= L_max; l++) {
       adjfactor [0] += qf [l] * sum_dpois[l];
//        sumalldpoi += sum_dpois [l];
     }
     adjfactor [0] /= no_lmd[0];
}

//
// void comp_adjfactor
//   (int no_qf[1], int no_lmd[1], double cut_wpois[1],
//    double qf[no_qf[0]], double lmd[no_lmd[0]], double adjfactor[1])
// {
//      double w_poi[no_qf[0]][no_lmd[0]], adjfactor_F[no_qf[0]] ;
//      int m,l, max_l, min_l;
//      adjfactor_
//
//      for(m = 0; m < no_lmd[0]; m++)
//      {
//          w_poi[0][m] = exp (- lmd[m]);
//          for(l = 1; l < no_qf[0]; l++) {
//              w_poi[l][m] = w_poi[l-1][m] * lmd[m] / l;
//          }
//      }
//
//      for(l = 0; l < no_qf[0]; l++)
//         adjfactor_F [l] = qf [l] * sum_double( no_lmd[0], &w_poi[l][0] );
//
//      adjfactor[0] = sum_double(no_qf[0], &adjfactor_F[0]) / no_lmd[0];
// }
//
