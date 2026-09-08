# The 'seed' argument makes a fit reproducible.
# The RNG state of the caller must survive the call.

seedIter <- 400
seedWarmup <- 100
seedStartsel <- 50
seedRefit <- list(iter = 150, warmup = 50, thin = 1)

# Pin the chain count. These tests check the seed, not the default of
# `chains`. One chain keeps them fast.
seedFit <- function(seed, method = "SpikeSlab", chains = 1) {
  data("sim1", package = "effectFusion", envir = environment())
  suppressWarnings(effectFusion(
    y ~ .,
    sim1,
    method = method,
    iter = seedIter,
    warmup = seedWarmup,
    startsel = seedStartsel,
    refit = seedRefit,
    chains = chains,
    seed = seed,
    silent = 1
  ))
}


test_that("one seed gives identical fits", {
  skip_on_cran()
  a <- seedFit(2024)
  b <- seedFit(2024)

  expect_identical(fitBeta(a), fitBeta(b))
  expect_identical(drawsOf(a$draws, "^sigma$"), drawsOf(b$draws, "^sigma$"))
  expect_identical(fusionBeta(a), fusionBeta(b))
})

test_that("two seeds give different fits", {
  skip_on_cran()
  a <- seedFit(2024)
  b <- seedFit(99)

  expect_false(identical(fitBeta(a), fitBeta(b)))
})

test_that("one seed gives identical binomial fits", {
  skip_on_cran()
  # The binomial sampler draws in C from the global R stream.
  binFit <- function(seed) {
    data("sim3", package = "effectFusion", envir = environment())
    suppressWarnings(effectFusion(
      y ~ .,
      sim3,
      method = "SpikeSlab",
      family = "binomial",
      iter = seedIter,
      warmup = seedWarmup,
      startsel = seedStartsel,
      refit = seedRefit,
      chains = 1,
      seed = seed,
      silent = 1
    ))
  }

  expect_identical(fitBeta(binFit(7)), fitBeta(binFit(7)))
  expect_false(identical(fitBeta(binFit(7)), fitBeta(binFit(8))))
})

test_that("the fit stores the seed", {
  skip_on_cran()
  expect_equal(seedFit(2024)$seed, 2024)
})

test_that("an unseeded fit stores the seed it drew", {
  skip_on_cran()
  fit <- seedFit(NULL)

  expect_true("seed" %in% names(fit))
  expect_true(is.numeric(fit$seed))
  expect_length(fit$seed, 1)
  expect_false(is.na(fit$seed))
})

test_that("a stored seed reproduces an unseeded fit", {
  skip_on_cran()
  fit <- seedFit(NULL)
  again <- seedFit(fit$seed)

  expect_equal(fitBeta(again), fitBeta(fit))
})

test_that("one seed gives identical multichain fits", {
  skip_on_cran()
  a <- seedFit(2024, chains = 2)
  b <- seedFit(2024, chains = 2)

  expect_identical(fitBeta(a), fitBeta(b))
  expect_equal(nrow(fitBeta(a)), 2 * (seedIter - seedWarmup))
})
