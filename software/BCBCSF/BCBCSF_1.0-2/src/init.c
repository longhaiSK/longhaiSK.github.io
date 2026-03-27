#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> 
#include <R_ext/Rdynload.h>

/* These headers tell R that the functions exist in your compiled all.c */
extern void pred_ht(int *n, int *k, int *G, int *no_rmc, double *X_ts, 
                    double *MUJ, double *SDXJ, double *log_freqy, 
                    double *probs_pred);

extern void comp_adjfactor(double *cut_dpoi, int *len_qf, int *len_lmd, 
                           double *qf, double *lmd, double *adjf);

/* Table of C routines to register */
static const R_CMethodDef CEntries[] = {
  {"pred_ht", (DL_FUNC) &pred_ht, 9},
  {"comp_adjfactor", (DL_FUNC) &comp_adjfactor, 6},
  {NULL, NULL, 0}
};

void R_init_BCBCSF(DllInfo *dll)
{
  /* Register the routines */
  R_registerRoutines(dll, CEntries, NULL, NULL, NULL);
  /* Disable searching for symbols in other libraries */
  R_useDynamicSymbols(dll, FALSE);
}
