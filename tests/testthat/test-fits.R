# These tests record current behaviour, including current known bugs.
# Values will be updated later alongside the relevant fixes.

# Top-level names of a fit that performs effect fusion.
fusion_names <- c(
  "fit",
  "fit_burnin",
  "refit",
  "method",
  "family",
  "data",
  "model",
  "prior",
  "mcmc",
  "chains",
  "cores",
  "mcmcRefit",
  "modelSelection",
  "returnBurnin",
  "numbCoef",
  "call",
  "seed"
)

# The full model performs no fusion. It returns no refit.
full_names <- setdiff(fusion_names, "refit")

finmix_warning <- "Finite mixture prior treats ordinal predictors as nominal."


test_that("ss_gaussian has the expected structure", {
  skip_on_cran()
  fit <- baselineFit("ss_gaussian")

  expect_s3_class(fit, "fusion")
  expect_named(fit, fusion_names)
  expect_null(attr(fit, "baseline_warnings"))

  expect_equal(dim(fit$fit$beta), c(2000, 41))
  expect_length(fit$fit$sgma2, 2000)

  expect_named(fit$refit, c("beta", "sgma2", "X_dummy_fused", "model"))
  expect_equal(dim(fit$refit$beta), c(1000, 41))
  expect_length(fit$refit$sgma2, 1000)
})

test_that("ss_gaussian reproduces the baseline values", {
  skip_on_cran()
  fit <- baselineFit("ss_gaussian")

  expect_equal(fit$numbCoef, 8)
  expect_equal(dic(fit), 1420.337730, tolerance = 1e-6)

  expect_equal(mean(fit$fit$sgma2), 0.9861894826, tolerance = 1e-8)
  expect_equal(
    unname(colMeans(fit$fit$beta)[1:3]),
    c(0.9857784603, 0.0628610384, 1.0556540852),
    tolerance = 1e-8
  )
  expect_equal(sum(colMeans(fit$refit$beta) != 0), 17)
})


test_that("mix_gaussian has the expected structure", {
  skip_on_cran()
  fit <- baselineFit("mix_gaussian")

  expect_s3_class(fit, "fusion")
  expect_named(fit, fusion_names)
  expect_equal(attr(fit, "baseline_warnings"), finmix_warning)

  expect_equal(dim(fit$fit$beta), c(2000, 41))
  expect_length(fit$fit$sgma2, 2000)

  expect_named(fit$refit, c("beta", "sgma2", "X_dummy_fused", "model"))
  expect_equal(dim(fit$refit$beta), c(1000, 41))
  expect_length(fit$refit$sgma2, 1000)
})

test_that("mix_gaussian reproduces the baseline values", {
  skip_on_cran()
  fit <- baselineFit("mix_gaussian")

  expect_equal(fit$numbCoef, 9)
  expect_equal(dic(fit), 1421.185059, tolerance = 1e-6)

  expect_equal(mean(fit$fit$sgma2), 0.9872764470, tolerance = 1e-8)
  expect_equal(
    unname(colMeans(fit$fit$beta)[1:3]),
    c(1.0496199016, 0.1570407059, 1.1578000832),
    tolerance = 1e-8
  )
  expect_equal(sum(colMeans(fit$refit$beta) != 0), 22)
})


test_that("full_gaussian has the expected structure", {
  skip_on_cran()
  fit <- baselineFit("full_gaussian")

  expect_s3_class(fit, "fusion")
  expect_named(fit, full_names)
  expect_null(attr(fit, "baseline_warnings"))

  expect_equal(dim(fit$fit$beta), c(2000, 41))
  expect_length(fit$fit$sgma2, 2000)

  expect_null(fit$refit)
})

test_that("full_gaussian reproduces the baseline values", {
  skip_on_cran()
  fit <- baselineFit("full_gaussian")

  expect_equal(fit$numbCoef, 41)
  expect_equal(dic(fit), 1467.715366, tolerance = 1e-6)

  expect_equal(mean(fit$fit$sgma2), 1.0148437579, tolerance = 1e-8)
  expect_equal(
    unname(colMeans(fit$fit$beta)[1:3]),
    c(0.9985892285, 0.2614711507, 1.2390901042),
    tolerance = 1e-8
  )
})


test_that("ss_binomial has the expected structure", {
  skip_on_cran()
  fit <- baselineFit("ss_binomial")

  expect_s3_class(fit, "fusion")
  expect_named(fit, fusion_names)
  expect_null(attr(fit, "baseline_warnings"))

  expect_equal(dim(fit$fit$beta), c(2000, 41))
  expect_null(fit$fit$sgma2)

  expect_named(fit$refit, c("beta", "X_dummy_fused", "model"))
  expect_equal(dim(fit$refit$beta), c(1000, 41))
  expect_null(fit$refit$sgma2)
})

test_that("ss_binomial reproduces the baseline values", {
  skip_on_cran()
  fit <- baselineFit("ss_binomial")

  expect_equal(fit$numbCoef, 10)
  expect_equal(dic(fit), 969.454765, tolerance = 1e-6)

  expect_equal(
    unname(colMeans(fit$fit$beta)[1:3]),
    c(1.4564448201, -0.0086595662, 1.0056367795),
    tolerance = 1e-8
  )
  expect_equal(sum(colMeans(fit$refit$beta) != 0), 18)
})


test_that("mix_binomial has the expected structure", {
  skip_on_cran()
  fit <- baselineFit("mix_binomial")

  expect_s3_class(fit, "fusion")
  expect_named(fit, fusion_names)
  expect_equal(attr(fit, "baseline_warnings"), finmix_warning)

  expect_equal(dim(fit$fit$beta), c(2000, 41))
  expect_null(fit$fit$sgma2)

  expect_named(fit$refit, c("beta", "X_dummy_fused", "model"))
  expect_equal(dim(fit$refit$beta), c(1000, 41))
  expect_null(fit$refit$sgma2)
})

test_that("mix_binomial reproduces the baseline values", {
  skip_on_cran()
  fit <- baselineFit("mix_binomial")

  expect_equal(fit$numbCoef, 15)
  expect_equal(dic(fit), 972.406575, tolerance = 1e-6)

  expect_equal(
    unname(colMeans(fit$fit$beta)[1:3]),
    c(1.4458333057, -0.0033091292, 1.4152759844),
    tolerance = 1e-8
  )
  expect_equal(sum(colMeans(fit$refit$beta) != 0), 30)
})
