# The MCMC settings are flat arguments. These tests cover the values that
# effectFusion() accepts and what `thin` and `save_warmup` do to the draws.

argFit <- function(...) {
  data("sim1", package = "effectFusion", envir = environment())
  effectFusion(
    sim1$y,
    sim1$X,
    sim1$types,
    method = "SpikeSlab",
    ...
  )
}


test_that("the settings reject invalid values", {
  expect_error(argFit(iter = 100, warmup = 100), "greater than 'warmup'")
  expect_error(argFit(iter = 100, warmup = -1), "must not be negative")
  expect_error(argFit(iter = 100, warmup = 10, thin = 0), "at least 1")
  expect_error(argFit(iter = 100, warmup = 10, thin = 1000), "leaves no draws")
  expect_error(
    argFit(iter = 500, warmup = 100, startsel = 200),
    "start within the warmup phase"
  )
})

test_that("the refit list rejects invalid values", {
  base <- list(iter = 300, warmup = 50, startsel = 25, chains = 1, silent = 1)
  refitFit <- function(refit) {
    do.call(argFit, c(base, list(refit = refit)))
  }

  expect_error(refitFit(list(M_refit = 100)), "Invalid refit parameters")
  expect_error(
    refitFit(list(iter = 50, warmup = 50)),
    "greater than 'refit\\$warmup'"
  )
  expect_error(refitFit(list(iter = 100, warmup = -1)), "must not be negative")
  expect_error(refitFit(list(iter = 100, warmup = 10, thin = 0)), "at least 1")
})


test_that("thin selects every thin-th draw", {
  skip_on_cran()
  base <- list(
    iter = 600,
    warmup = 100,
    startsel = 50,
    refit = list(iter = 150, warmup = 50, thin = 1),
    chains = 1,
    silent = 1,
    seed = 2024
  )

  one <- suppressWarnings(do.call(argFit, base))
  five <- suppressWarnings(do.call(argFit, c(base, list(thin = 5))))

  expect_equal(nrow(one$fit$beta), 500)
  expect_equal(nrow(five$fit$beta), 100)
  expect_identical(one$fit$beta[seq(5, 500, by = 5), ], five$fit$beta)
  expect_identical(one$fit$sgma2[seq(5, 500, by = 5)], five$fit$sgma2)
})

test_that("save_warmup returns the warmup unthinned", {
  skip_on_cran()
  fit <- suppressWarnings(argFit(
    iter = 600,
    warmup = 100,
    thin = 5,
    startsel = 50,
    save_warmup = TRUE,
    refit = list(iter = 150, warmup = 50, thin = 1),
    chains = 1,
    silent = 1,
    seed = 2024
  ))

  expect_equal(nrow(fit$fit_warmup$beta), 100)
  expect_equal(nrow(fit$fit$beta), 100)
})

test_that("the full model uses its own defaults", {
  skip_on_cran()
  data("sim1", package = "effectFusion", envir = environment())
  fit <- effectFusion(
    sim1$y,
    sim1$X,
    sim1$types,
    method = NULL,
    chains = 1,
    silent = 1
  )

  expect_equal(fit$mcmc$iter, 4000)
  expect_equal(fit$mcmc$warmup, 1000)
  expect_equal(nrow(fit$fit$beta), 3000)
  expect_null(fit$method)
})
