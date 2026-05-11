# About the Files in this Directory


- The R code and datasets in this directory are released for reproducing
  the results shown in this paper:

  Feng, C., Li, L., Sadeghpour, A., 2020. A comparison of residual
  diagnosis tools for diagnosing regression models for count data. BMC
  Medical Research Methodology 20, 175.
  https://doi.org/10.1186/s12874-020-01055-2 (OA).

- We have merged these code into the R package Zresidual:

  Wu, T. and Li, L., 2026. `Zresidual`: Computing and Diagnosing
  Gaussian-like Residuals.
  \[[Github](https://tiw150.github.io/Zresidual/index.html)\]. Version
  0.1-0 on Github (2026).

  The Zresidual package implements diagnostic residuals based on the
  predictive distribution of each observation. By utilizing the full
  probabilistic information of the model, the package generates
  residuals that are approximately normally distributed, enabling
  further standard diagnostics for Pearson’s residuals for OLS. Use the
  following package instead:
