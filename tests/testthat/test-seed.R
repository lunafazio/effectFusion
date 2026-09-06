# The 'seed' argument makes a fit reproducible.
# The RNG state of the caller must survive the call.

seedMcmc <- list(M = 300, burnin = 100, startsel = 50)
seedRefit <- list(M_refit = 100, burnin_refit = 50)

seedFit <- function(seed, method = "SpikeSlab") {
  data("sim1", package = "effectFusion", envir = environment())
  suppressWarnings(effectFusion(
    sim1$y,
    sim1$X,
    sim1$types,
    method = method,
    mcmc = seedMcmc,
    mcmcRefit = seedRefit,
    seed = seed
  ))
}


test_that("one seed gives identical fits", {
  skip_on_cran()
  a <- seedFit(2024)
  b <- seedFit(2024)

  expect_identical(a$fit$beta, b$fit$beta)
  expect_identical(a$fit$sgma2, b$fit$sgma2)
  expect_identical(a$refit$beta, b$refit$beta)
})

test_that("two seeds give different fits", {
  skip_on_cran()
  a <- seedFit(2024)
  b <- seedFit(99)

  expect_false(identical(a$fit$beta, b$fit$beta))
})

test_that("one seed gives identical binomial fits", {
  skip_on_cran()
  # The binomial sampler draws in C from the global R stream.
  binFit <- function(seed) {
    data("sim3", package = "effectFusion", envir = environment())
    suppressWarnings(effectFusion(
      sim3$y,
      sim3$X,
      sim3$types,
      method = "SpikeSlab",
      family = "binomial",
      mcmc = seedMcmc,
      mcmcRefit = seedRefit,
      seed = seed
    ))
  }

  expect_identical(binFit(7)$fit$beta, binFit(7)$fit$beta)
  expect_false(identical(binFit(7)$fit$beta, binFit(8)$fit$beta))
})

test_that("the fit stores the seed", {
  skip_on_cran()
  expect_equal(seedFit(2024)$seed, 2024)
})

test_that("an unseeded fit stores a NULL seed", {
  skip_on_cran()
  fit <- seedFit(NULL)

  # `ret$seed <- NULL` would drop the element. The name must still be present.
  expect_true("seed" %in% names(fit))
  expect_null(fit$seed)
})
