#include <math.h>
#include <R.h>
#include <Rmath.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void add1v (double (*f) (double x[1]), double a, double b, double new[1] )
{
  double old;
  old =  (*f) (&a);
  new[0] = old + b;
  printf ("old = %f, new = %f\n", old, new[0]);
}

void mycall (double out[1])
{
  double c, d;
  
  double f1 (double b[1])
  {
    return(log (b[0]+d));
  }

  double f2 (double b[1])
  {
    return(exp (b[0]+d));
  }

  d = 1.0;
  add1v (f1, 1.0, 2.0, out);
  printf("out is %f\n", out[0]);

  d = 2.0;
  add1v (f1, 1.0, 2.0, out);
  printf("out is %f\n", out[0]);

  d = 1.0;
  add1v (f2, 1.0, 2.0, out);
  printf("out is %f\n", out[0]);

  d = 5.0;
  add1v (f2, 1.0, 2.0, out);
  printf("out is %f\n", out[0]);
  
}

void testc (double a[1])
{
  double b;
  
  void add1 (double c[]) { c[0]++;}
  
  b = a[0];
  
  
  add1 (&b);
  
  printf ("b is now %f\n", b);
}