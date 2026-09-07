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
    sim1$y,
    sim1$X,
    sim1$types,
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
      iter = seedIter,
      warmup = seedWarmup,
      startsel = seedStartsel,
      refit = seedRefit,
      chains = 1,
      seed = seed,
      silent = 1
    ))
  }

  expect_identical(binFit(7)$fit$beta, binFit(7)$fit$beta)
  expect_false(identical(binFit(7)$fit$beta, binFit(8)$fit$beta))
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

  expect_equal(again$fit$beta, fit$fit$beta)
})

test_that("one seed gives identical multichain fits", {
  skip_on_cran()
  a <- seedFit(2024, chains = 2)
  b <- seedFit(2024, chains = 2)

  expect_identical(a$fit$beta, b$fit$beta)
  expect_equal(nrow(a$fit$beta), 2 * (seedIter - seedWarmup))
})
