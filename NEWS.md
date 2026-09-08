# effectFusion 2.0.0

This release adopts new argument names and output formats based on `brms`.
It breaks every script that calls `effectFusion()`. The list below gives the
replacement for each removed argument.

## Breaking changes

* `mcmc` and `mcmcRefit` are removed. The MCMC settings are now flat arguments.

  | old | new |
  |---|---|
  | `mcmc = list(M = 20000)` | `iter = 25000` |
  | `mcmc = list(burnin = 5000)` | `warmup = 5000` |
  | `mcmc = list(startsel = 1000)` | `startsel = 1000` |
  | `mcmcRefit = list(M_refit = 3000)` | `refit = list(iter = 4000)` |
  | `mcmcRefit = list(burnin_refit = 1000)` | `refit = list(warmup = 1000)` |

* `iter` counts the warmup, `M` did not. A call that drew `M` samples after
  a burn-in of `burnin` now needs `iter = M + burnin`. The old default pair
  `M = 20000` and `burnin = 5000` is now `iter = 25000` and `warmup = 5000`.

* `$fit` and `$refit` are removed. The draws are now in `$draws` and
  `$refit_draws`, both in `posterior` format. Use `posterior::subset_draws()`
  or `$draws` directly where you used `$fit`.

* `returnBurnin` is renamed to `save_warmup`. The warmup draws are now in
  `$draws_warmup`, not in `$fit_burnin`.

* The error standard deviation is now `sigma`, and it replaces `sgma2`. `sigma`
  holds the standard deviation. `sgma2` held the variance. Take the square of
  `sigma` to recover the old value.

* Automatic thinning is removed: a sparse finite mixture model with more than
  1000 effect differences and more than 15000 iterations previously returned
  a silently thinned fit. Now, `thin` must be passed manually.

## New features

* `chains` runs several chains, and defaults to 4. `cores` runs them in separate
  processes, and defaults to `getOption("mc.cores", 1)`. Each chain draws from
  its own substream, so the draws are reproducible under either setting.

* `seed` seeds the sampler. The fit stores the seed, including the one the
  package draws when you pass none.

* The samplers report progress in the Stan format. `refresh` sets the interval
  and `refresh = 0` prints nothing. The fit stores the elapsed time of each
  chain.

* `$draws` is a `draws_df`. `posterior` and `bayesplot` read it directly.

* `summary()` now returns an object and contains Rhat and effective sample
  size. `print()` behavior of fits is to show the summary object.

## Bug fixes

* The sparse finite mixture samplers wrote `sgma2` at a different index from
  `beta` when they thinned. The two could therefore come from different
  iterations. The thinning is removed, and one index now serves every parameter.

* `model()` no longer fails on a fit that performed no model selection.
