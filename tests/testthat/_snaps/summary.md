# summary() is stable for ss_gaussian

    Code
      print(summary(fit))
    Output
       Family: gaussian
         Data: sim1 (Number of observations: 500)
        Prior: spike and slab (r = 50000, g0 = 5, G0 = 25)
        Draws: 1 chain, each with iter = 1200; warmup = 200; thin = 1
               total post-warmup draws = 1000
      
      Effect fusion:
        Model dimension:      8 of 41 coefficients
        Fused levels:
          var1: {cat1,cat2}, {cat3,cat4}, {cat5,cat6}, {cat7,cat8}
          var2: {cat1,cat2,cat3,cat4,cat5,cat6,cat7,cat8}
          var3: {cat1,cat2}, {cat3,cat4}
          var4: {cat1,cat2,cat3,cat4}
          var5: {cat1,cat2}, {cat3,cat4,cat5,cat6}, {cat7,cat8}
          var6: {cat1,cat2,cat3,cat4,cat5,cat6,cat7,cat8}
          var7: {cat1,cat2}, {cat3,cat4}
          var8: {cat1,cat2,cat3,cat4}
        Fusion certainty:     11 of 88 level differences undecided
      
      Regression Coefficients:
                  Estimate Est.Error l-95% HPD u-95% HPD Rhat Bulk_ESS Tail_ESS
      (Intercept)     1.04      0.15      0.76      1.34 1.00     1043      983
      var1.cat2       0.00      0.00      0.00      0.00    .        .        .
      var1.cat3       1.01      0.13      0.77      1.26 1.00     1051      900
      var1.cat4       1.01      0.13      0.77      1.26 1.00     1051      900
      var1.cat5       1.86      0.12      1.62      2.06 1.00     1132      980
      var1.cat6       1.86      0.12      1.62      2.06 1.00     1132      980
      var1.cat7       4.00      0.14      3.74      4.29 1.00     1080      982
      var1.cat8       4.00      0.14      3.74      4.29 1.00     1080      982
      var2.cat2       0.00      0.00      0.00      0.00    .        .        .
      var2.cat3       0.00      0.00      0.00      0.00    .        .        .
      var2.cat4       0.00      0.00      0.00      0.00    .        .        .
      var2.cat5       0.00      0.00      0.00      0.00    .        .        .
      var2.cat6       0.00      0.00      0.00      0.00    .        .        .
      var2.cat7       0.00      0.00      0.00      0.00    .        .        .
      var2.cat8       0.00      0.00      0.00      0.00    .        .        .
      var3.cat2       0.00      0.00      0.00      0.00    .        .        .
      var3.cat3      -2.04      0.09     -2.23     -1.88 1.00      877      799
      var3.cat4      -2.04      0.09     -2.23     -1.88 1.00      877      799
      var4.cat2       0.00      0.00      0.00      0.00    .        .        .
      var4.cat3       0.00      0.00      0.00      0.00    .        .        .
      var4.cat4       0.00      0.00      0.00      0.00    .        .        .
      var5.cat2       0.00      0.00      0.00      0.00    .        .        .
      var5.cat3       1.02      0.12      0.81      1.28 1.00      967      937
      var5.cat4       1.02      0.12      0.81      1.28 1.00      967      937
      var5.cat5       1.02      0.12      0.81      1.28 1.00      967      937
      var5.cat6       1.02      0.12      0.81      1.28 1.00      967      937
      var5.cat7      -2.08      0.15     -2.36     -1.79 1.00      978      981
      var5.cat8      -2.08      0.15     -2.36     -1.79 1.00      978      981
      var6.cat2       0.00      0.00      0.00      0.00    .        .        .
      var6.cat3       0.00      0.00      0.00      0.00    .        .        .
      var6.cat4       0.00      0.00      0.00      0.00    .        .        .
      var6.cat5       0.00      0.00      0.00      0.00    .        .        .
      var6.cat6       0.00      0.00      0.00      0.00    .        .        .
      var6.cat7       0.00      0.00      0.00      0.00    .        .        .
      var6.cat8       0.00      0.00      0.00      0.00    .        .        .
      var7.cat2       0.00      0.00      0.00      0.00    .        .        .
      var7.cat3       2.12      0.09      1.95      2.28 1.00      939      909
      var7.cat4       2.12      0.09      1.95      2.28 1.00      939      909
      var8.cat2       0.00      0.00      0.00      0.00    .        .        .
      var8.cat3       0.00      0.00      0.00      0.00    .        .        .
      var8.cat4       0.00      0.00      0.00      0.00    .        .        .
      
      Further Distributional Parameters:
            Estimate Est.Error l-95% HPD u-95% HPD Rhat Bulk_ESS Tail_ESS
      sigma     0.99      0.03      0.92      1.05 1.00      956      937
      
      Call:
      effectFusion(formula = y ~ ., data = sim1, method = "SpikeSlab", 
          iter = mcmc_args$iter, warmup = mcmc_args$warmup, thin = mcmc_args$thin, 
          chains = 1, silent = 1, startsel = mcmc_args$startsel, refit = refit_args)
      
      Coefficients marked '.' are fixed by the selected fusion model.
      Rhat and ESS are undefined for them.

# summary() is stable for mix_gaussian

    Code
      print(summary(fit))
    Output
       Family: gaussian
         Data: sim1 (Number of observations: 500)
        Prior: finite mixture (e0 = 0.01, p = 100)
        Draws: 1 chain, each with iter = 1200; warmup = 200; thin = 1
               total post-warmup draws = 1000
      
      Effect fusion:
        Model dimension:      9 of 41 coefficients
        Fused levels:
          var1: {cat1,cat2}, {cat3,cat4}, {cat5,cat6}, {cat7,cat8}
          var2: {cat1,cat6,cat7}, {cat2,cat3,cat4,cat5,cat8}
          var3: {cat1,cat2}, {cat3,cat4}
          var4: {cat1,cat2,cat3,cat4}
          var5: {cat1,cat2}, {cat3,cat4,cat5,cat6}, {cat7,cat8}
          var6: {cat1,cat2,cat3,cat4,cat5,cat6,cat7,cat8}
          var7: {cat1,cat2}, {cat3,cat4}
          var8: {cat1,cat2,cat3,cat4}
      
      Regression Coefficients:
                  Estimate Est.Error l-95% HPD u-95% HPD Rhat Bulk_ESS Tail_ESS
      (Intercept)     1.10      0.15      0.82      1.42 1.00      997      853
      var1.cat2       0.00      0.00      0.00      0.00    .        .        .
      var1.cat3       1.01      0.13      0.75      1.27 1.00     1029     1023
      var1.cat4       1.01      0.13      0.75      1.27 1.00     1029     1023
      var1.cat5       1.86      0.12      1.63      2.09 1.00      872      820
      var1.cat6       1.86      0.12      1.63      2.09 1.00      872      820
      var1.cat7       4.00      0.14      3.74      4.28 1.00      987      739
      var1.cat8       4.00      0.14      3.74      4.28 1.00      987      739
      var2.cat2      -0.11      0.09     -0.32      0.05 1.00     1012     1022
      var2.cat3      -0.11      0.09     -0.32      0.05 1.00     1012     1022
      var2.cat4      -0.11      0.09     -0.32      0.05 1.00     1012     1022
      var2.cat5      -0.11      0.09     -0.32      0.05 1.00     1012     1022
      var2.cat6       0.00      0.00      0.00      0.00    .        .        .
      var2.cat7       0.00      0.00      0.00      0.00    .        .        .
      var2.cat8      -0.11      0.09     -0.32      0.05 1.00     1012     1022
      var3.cat2       0.00      0.00      0.00      0.00    .        .        .
      var3.cat3      -2.04      0.09     -2.21     -1.88 1.00     1065     1069
      var3.cat4      -2.04      0.09     -2.21     -1.88 1.00     1065     1069
      var4.cat2       0.00      0.00      0.00      0.00    .        .        .
      var4.cat3       0.00      0.00      0.00      0.00    .        .        .
      var4.cat4       0.00      0.00      0.00      0.00    .        .        .
      var5.cat2       0.00      0.00      0.00      0.00    .        .        .
      var5.cat3       1.03      0.12      0.82      1.28 1.00      923      980
      var5.cat4       1.03      0.12      0.82      1.28 1.00      923      980
      var5.cat5       1.03      0.12      0.82      1.28 1.00      923      980
      var5.cat6       1.03      0.12      0.82      1.28 1.00      923      980
      var5.cat7      -2.08      0.14     -2.36     -1.81 1.00      790      767
      var5.cat8      -2.08      0.14     -2.36     -1.81 1.00      790      767
      var6.cat2       0.00      0.00      0.00      0.00    .        .        .
      var6.cat3       0.00      0.00      0.00      0.00    .        .        .
      var6.cat4       0.00      0.00      0.00      0.00    .        .        .
      var6.cat5       0.00      0.00      0.00      0.00    .        .        .
      var6.cat6       0.00      0.00      0.00      0.00    .        .        .
      var6.cat7       0.00      0.00      0.00      0.00    .        .        .
      var6.cat8       0.00      0.00      0.00      0.00    .        .        .
      var7.cat2       0.00      0.00      0.00      0.00    .        .        .
      var7.cat3       2.12      0.10      1.94      2.31 1.00     1012      975
      var7.cat4       2.12      0.10      1.94      2.31 1.00     1012      975
      var8.cat2       0.00      0.00      0.00      0.00    .        .        .
      var8.cat3       0.00      0.00      0.00      0.00    .        .        .
      var8.cat4       0.00      0.00      0.00      0.00    .        .        .
      
      Further Distributional Parameters:
            Estimate Est.Error l-95% HPD u-95% HPD Rhat Bulk_ESS Tail_ESS
      sigma     0.99      0.03      0.93      1.05 1.00      821      741
      
      Call:
      effectFusion(formula = y ~ ., data = sim1, method = "FinMix", 
          iter = mcmc_args$iter, warmup = mcmc_args$warmup, thin = mcmc_args$thin, 
          chains = 1, silent = 1, startsel = mcmc_args$startsel, refit = refit_args)
      
      Coefficients marked '.' are fixed by the selected fusion model.
      Rhat and ESS are undefined for them.

# summary() is stable for full_gaussian

    Code
      print(summary(fit))
    Output
       Family: gaussian
         Data: sim1 (Number of observations: 500)
        Prior: flat, uninformative
        Draws: 1 chain, each with iter = 2500; warmup = 500; thin = 1
               total post-warmup draws = 2000
      
      Regression Coefficients:
                  Estimate Est.Error l-95% HPD u-95% HPD Rhat Bulk_ESS Tail_ESS
      (Intercept)     1.00      0.40      0.26      1.80 1.00     1617     1665
      var1.cat2       0.26      0.20     -0.13      0.64 1.00     1931     2045
      var1.cat3       1.24      0.20      0.84      1.61 1.00     1990     2047
      var1.cat4       1.05      0.20      0.65      1.44 1.00     2089     1963
      var1.cat5       1.91      0.18      1.54      2.26 1.00     1940     1901
      var1.cat6       2.08      0.19      1.74      2.46 1.00     1476     1778
      var1.cat7       4.19      0.20      3.79      4.55 1.00     1980     1765
      var1.cat8       3.92      0.25      3.41      4.40 1.00     2015     1859
      var2.cat2      -0.13      0.22     -0.55      0.28 1.00     1992     1625
      var2.cat3      -0.08      0.20     -0.50      0.30 1.00     2002     1886
      var2.cat4      -0.14      0.22     -0.54      0.30 1.00     1957     1749
      var2.cat5      -0.07      0.18     -0.42      0.29 1.00     2030     1790
      var2.cat6      -0.01      0.19     -0.38      0.39 1.00     2037     1926
      var2.cat7       0.03      0.19     -0.33      0.40 1.00     1914     1848
      var2.cat8      -0.11      0.23     -0.61      0.32 1.00     2144     1776
      var3.cat2      -0.10      0.16     -0.40      0.22 1.00     1801     1841
      var3.cat3      -2.06      0.18     -2.43     -1.72 1.00     1764     2004
      var3.cat4      -2.14      0.17     -2.46     -1.79 1.00     1769     1885
      var4.cat2      -0.03      0.15     -0.31      0.27 1.00     1862     2036
      var4.cat3       0.17      0.18     -0.17      0.52 1.00     1645     1872
      var4.cat4       0.07      0.16     -0.26      0.35 1.00     1678     1760
      var5.cat2       0.04      0.21     -0.40      0.44 1.00     1981     1846
      var5.cat3       1.01      0.19      0.62      1.35 1.00     1867     1847
      var5.cat4       1.04      0.21      0.64      1.46 1.00     2081     1755
      var5.cat5       1.03      0.18      0.68      1.39 1.00     1954     2004
      var5.cat6       1.13      0.20      0.75      1.53 1.00     2164     1985
      var5.cat7      -2.13      0.20     -2.52     -1.76 1.00     1834     1923
      var5.cat8      -1.95      0.25     -2.43     -1.44 1.00     2052     1848
      var6.cat2      -0.15      0.20     -0.57      0.20 1.00     1873     1657
      var6.cat3      -0.22      0.20     -0.62      0.16 1.00     1557     1880
      var6.cat4      -0.09      0.21     -0.51      0.30 1.00     2017     1923
      var6.cat5       0.06      0.18     -0.27      0.41 1.00     1921     2089
      var6.cat6      -0.19      0.19     -0.55      0.19 1.00     1915     2071
      var6.cat7      -0.01      0.19     -0.40      0.35 1.00     1688     1819
      var6.cat8       0.03      0.22     -0.40      0.45 1.00     2009     1999
      var7.cat2       0.00      0.16     -0.32      0.30 1.00     1813     1881
      var7.cat3       2.08      0.17      1.75      2.41 1.00     2133     1892
      var7.cat4       2.17      0.16      1.85      2.48 1.00     1923     1674
      var8.cat2       0.01      0.16     -0.32      0.33 1.00     2098     1848
      var8.cat3       0.01      0.18     -0.31      0.39 1.00     1935     1816
      var8.cat4       0.13      0.17     -0.18      0.48 1.00     2107     1681
      
      Further Distributional Parameters:
            Estimate Est.Error l-95% HPD u-95% HPD Rhat Bulk_ESS Tail_ESS
      sigma     1.01      0.03      0.94      1.07 1.00     1414     1885
      
      Call:
      effectFusion(formula = y ~ ., data = sim1, method = NULL, iter = 2500, 
          warmup = 500, chains = 1, silent = 1)

# summary() is stable for ss_binomial

    Code
      print(summary(fit))
    Output
       Family: binomial
         Data: sim3 (Number of observations: 2000)
        Prior: spike and slab (r = 5e+06, g0 = 5, G0 = 25)
        Draws: 1 chain, each with iter = 1200; warmup = 200; thin = 1
               total post-warmup draws = 1000
      
      Effect fusion:
        Model dimension:      10 of 41 coefficients
        Fused levels:
          var1: {cat1,cat2}, {cat3,cat4}, {cat5,cat6}, {cat7}, {cat8}
          var2: {cat1,cat2,cat3,cat4,cat5,cat6,cat7,cat8}
          var3: {cat1}, {cat2}, {cat3,cat4}
          var4: {cat1,cat2,cat3,cat4}
          var5: {cat1,cat2}, {cat3,cat4,cat5,cat6}, {cat7,cat8}
          var6: {cat1,cat2,cat3,cat4,cat5,cat6,cat7,cat8}
          var7: {cat1,cat2}, {cat3,cat4}
          var8: {cat1,cat2,cat3,cat4}
        Fusion certainty:     14 of 88 level differences undecided
      
      Regression Coefficients:
                  Estimate Est.Error l-95% HPD u-95% HPD Rhat Bulk_ESS Tail_ESS
      (Intercept)     1.65      0.37      1.00      2.41 1.00      276      307
      var1.cat2       0.00      0.00      0.00      0.00    .        .        .
      var1.cat3       0.99      0.21      0.58      1.38 1.01      281      666
      var1.cat4       0.99      0.21      0.58      1.38 1.01      281      666
      var1.cat5       1.93      0.22      1.49      2.36 1.01      187      399
      var1.cat6       1.93      0.22      1.49      2.36 1.01      187      399
      var1.cat7       4.58      0.56      3.55      5.71 1.06       57      105
      var1.cat8       3.40      0.60      2.25      4.53 1.01      153      191
      var2.cat2       0.00      0.00      0.00      0.00    .        .        .
      var2.cat3       0.00      0.00      0.00      0.00    .        .        .
      var2.cat4       0.00      0.00      0.00      0.00    .        .        .
      var2.cat5       0.00      0.00      0.00      0.00    .        .        .
      var2.cat6       0.00      0.00      0.00      0.00    .        .        .
      var2.cat7       0.00      0.00      0.00      0.00    .        .        .
      var2.cat8       0.00      0.00      0.00      0.00    .        .        .
      var3.cat2      -0.36      0.39     -1.25      0.28 1.00      188      402
      var3.cat3      -2.62      0.37     -3.35     -1.94 1.01      182      334
      var3.cat4      -2.62      0.37     -3.35     -1.94 1.01      182      334
      var4.cat2       0.00      0.00      0.00      0.00    .        .        .
      var4.cat3       0.00      0.00      0.00      0.00    .        .        .
      var4.cat4       0.00      0.00      0.00      0.00    .        .        .
      var5.cat2       0.00      0.00      0.00      0.00    .        .        .
      var5.cat3       1.04      0.22      0.61      1.45 1.01      335      520
      var5.cat4       1.04      0.22      0.61      1.45 1.01      335      520
      var5.cat5       1.04      0.22      0.61      1.45 1.01      335      520
      var5.cat6       1.04      0.22      0.61      1.45 1.01      335      520
      var5.cat7      -2.18      0.24     -2.60     -1.66 1.00      342      523
      var5.cat8      -2.18      0.24     -2.60     -1.66 1.00      342      523
      var6.cat2       0.00      0.00      0.00      0.00    .        .        .
      var6.cat3       0.00      0.00      0.00      0.00    .        .        .
      var6.cat4       0.00      0.00      0.00      0.00    .        .        .
      var6.cat5       0.00      0.00      0.00      0.00    .        .        .
      var6.cat6       0.00      0.00      0.00      0.00    .        .        .
      var6.cat7       0.00      0.00      0.00      0.00    .        .        .
      var6.cat8       0.00      0.00      0.00      0.00    .        .        .
      var7.cat2       0.00      0.00      0.00      0.00    .        .        .
      var7.cat3       2.06      0.19      1.69      2.42 1.00      222      344
      var7.cat4       2.06      0.19      1.69      2.42 1.00      222      344
      var8.cat2       0.00      0.00      0.00      0.00    .        .        .
      var8.cat3       0.00      0.00      0.00      0.00    .        .        .
      var8.cat4       0.00      0.00      0.00      0.00    .        .        .
      
      Call:
      effectFusion(formula = y ~ ., data = sim3, method = "SpikeSlab", 
          family = "binomial", iter = mcmc_args$iter, warmup = mcmc_args$warmup, 
          thin = mcmc_args$thin, chains = 1, silent = 1, startsel = mcmc_args$startsel, 
          refit = refit_args)
      
      Coefficients marked '.' are fixed by the selected fusion model.
      Rhat and ESS are undefined for them.

# summary() is stable for mix_binomial

    Code
      print(summary(fit))
    Output
       Family: binomial
         Data: sim3 (Number of observations: 2000)
        Prior: finite mixture (e0 = 0.01, p = 1000)
        Draws: 1 chain, each with iter = 1200; warmup = 200; thin = 1
               total post-warmup draws = 1000
      
      Effect fusion:
        Model dimension:      15 of 41 coefficients
        Fused levels:
          var1: {cat1,cat2}, {cat3,cat4}, {cat5,cat6}, {cat7,cat8}
          var2: {cat1,cat3,cat8}, {cat2,cat4,cat5,cat6}, {cat7}
          var3: {cat1,cat2}, {cat3,cat4}
          var4: {cat1}, {cat2,cat3,cat4}
          var5: {cat1,cat2}, {cat3,cat4,cat5,cat6}, {cat7,cat8}
          var6: {cat1,cat2,cat3,cat5,cat6,cat7}, {cat4}, {cat8}
          var7: {cat1,cat2}, {cat3,cat4}
          var8: {cat1}, {cat2,cat3}, {cat4}
      
      Regression Coefficients:
                  Estimate Est.Error l-95% HPD u-95% HPD Rhat Bulk_ESS Tail_ESS
      (Intercept)     1.25      0.45      0.43      2.20 1.01      286      538
      var1.cat2       0.00      0.00      0.00      0.00    .        .        .
      var1.cat3       1.05      0.22      0.67      1.49 1.00      367      727
      var1.cat4       1.05      0.22      0.67      1.49 1.00      367      727
      var1.cat5       1.98      0.23      1.47      2.41 1.00      174      274
      var1.cat6       1.98      0.23      1.47      2.41 1.00      174      274
      var1.cat7       4.21      0.40      3.44      4.98 1.00      120      350
      var1.cat8       4.21      0.40      3.44      4.98 1.00      120      350
      var2.cat2       0.24      0.18     -0.08      0.63 1.01      294      545
      var2.cat3       0.00      0.00      0.00      0.00    .        .        .
      var2.cat4       0.24      0.18     -0.08      0.63 1.01      294      545
      var2.cat5       0.24      0.18     -0.08      0.63 1.01      294      545
      var2.cat6       0.24      0.18     -0.08      0.63 1.01      294      545
      var2.cat7       0.64      0.31      0.05      1.25 1.02      195      480
      var2.cat8       0.00      0.00      0.00      0.00    .        .        .
      var3.cat2       0.00      0.00      0.00      0.00    .        .        .
      var3.cat3      -2.41      0.20     -2.78     -2.01 1.00      170      366
      var3.cat4      -2.41      0.20     -2.78     -2.01 1.00      170      366
      var4.cat2      -0.28      0.29     -0.86      0.29 1.00      342      553
      var4.cat3      -0.28      0.29     -0.86      0.29 1.00      342      553
      var4.cat4      -0.28      0.29     -0.86      0.29 1.00      342      553
      var5.cat2       0.00      0.00      0.00      0.00    .        .        .
      var5.cat3       1.13      0.22      0.71      1.56 1.01      268      400
      var5.cat4       1.13      0.22      0.71      1.56 1.01      268      400
      var5.cat5       1.13      0.22      0.71      1.56 1.01      268      400
      var5.cat6       1.13      0.22      0.71      1.56 1.01      268      400
      var5.cat7      -2.14      0.23     -2.59     -1.72 1.00      321      627
      var5.cat8      -2.14      0.23     -2.59     -1.72 1.00      321      627
      var6.cat2       0.00      0.00      0.00      0.00    .        .        .
      var6.cat3       0.00      0.00      0.00      0.00    .        .        .
      var6.cat4       0.33      0.28     -0.22      0.87 1.01      218      541
      var6.cat5       0.00      0.00      0.00      0.00    .        .        .
      var6.cat6       0.00      0.00      0.00      0.00    .        .        .
      var6.cat7       0.00      0.00      0.00      0.00    .        .        .
      var6.cat8      -0.53      0.39     -1.21      0.27 1.01      253      482
      var7.cat2       0.00      0.00      0.00      0.00    .        .        .
      var7.cat3       2.11      0.20      1.71      2.50 1.03      117      301
      var7.cat4       2.11      0.20      1.71      2.50 1.03      117      301
      var8.cat2       0.14      0.27     -0.35      0.68 1.00      338      475
      var8.cat3       0.14      0.27     -0.35      0.68 1.00      338      475
      var8.cat4       0.04      0.29     -0.52      0.58 1.00      327      516
      
      Call:
      effectFusion(formula = y ~ ., data = sim3, method = "FinMix", 
          family = "binomial", iter = mcmc_args$iter, warmup = mcmc_args$warmup, 
          thin = mcmc_args$thin, chains = 1, silent = 1, startsel = mcmc_args$startsel, 
          refit = refit_args)
      
      Coefficients marked '.' are fixed by the selected fusion model.
      Rhat and ESS are undefined for them.

