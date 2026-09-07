# Fits for test-fits.R
# Cached so they can be used in different test sets without refitting

fit_cache <- new.env(parent = emptyenv())

baselineSeed <- 2024

baselineFit <- function(key) {
  if (!is.null(fit_cache[[key]])) {
    return(fit_cache[[key]])
  }
  fit_cache[[key]] <- fitBaseline(key)
  fit_cache[[key]]
}

fitBaseline <- function(key) {
  warnings <- character()

  fit <- withCallingHandlers(
    runBaseline(key),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )

  if (length(warnings) > 0) {
    attr(fit, "baseline_warnings") <- warnings
  }
  fit
}

runBaseline <- function(key) {
  data("sim1", package = "effectFusion", envir = environment())
  data("sim3", package = "effectFusion", envir = environment())

  mcmc_args <- list(M = 2000, burnin = 500, startsel = 200)
  refit_args <- list(M_refit = 1000, burnin_refit = 200)

  set.seed(baselineSeed)

  switch(
    key,
    ss_gaussian = effectFusion(
      sim1$y,
      sim1$X,
      sim1$types,
      method = "SpikeSlab",
      mcmc = mcmc_args,
      mcmcRefit = refit_args,
      silent = 1
    ),
    mix_gaussian = effectFusion(
      sim1$y,
      sim1$X,
      sim1$types,
      method = "FinMix",
      mcmc = mcmc_args,
      mcmcRefit = refit_args,
      silent = 1
    ),
    full_gaussian = effectFusion(
      sim1$y,
      sim1$X,
      sim1$types,
      method = NULL,
      mcmc = list(M = 2000, burnin = 500),
      silent = 1
    ),
    ss_binomial = effectFusion(
      sim3$y,
      sim3$X,
      sim3$types,
      method = "SpikeSlab",
      family = "binomial",
      mcmc = mcmc_args,
      mcmcRefit = refit_args,
      silent = 1
    ),
    mix_binomial = effectFusion(
      sim3$y,
      sim3$X,
      sim3$types,
      method = "FinMix",
      family = "binomial",
      mcmc = mcmc_args,
      mcmcRefit = refit_args,
      silent = 1
    ),
    stop("unknown baseline key: ", key)
  )
}

baselineKeys <- c(
  "ss_gaussian",
  "mix_gaussian",
  "full_gaussian",
  "ss_binomial",
  "mix_binomial"
)
