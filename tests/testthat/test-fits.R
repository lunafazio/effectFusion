# These tests record current behaviour, including current known bugs.
# Values will be updated later alongside the relevant fixes.

# Top-level names of a fit that performs effect fusion.
fusion_names <- c(
  "draws",
  "draws_warmup",
  "refit_draws",
  "selection",
  "method",
  "label",
  "family",
  "data",
  "model",
  "prior",
  "priorLabel",
  "mcmc",
  "chains",
  "cores",
  "time",
  "refit_settings",
  "modelSelection",
  "save_warmup",
  "numbCoef",
  "call",
  "seed"
)

# The full model performs no fusion, so its`refit_draws` and `selection` are
# NULL, but both names are present.
full_names <- fusion_names

finmix_warning <- "Finite mixture prior treats ordinal predictors as nominal."


test_that("ss_gaussian has the expected structure", {
  skip_on_cran()
  fit <- baselineFit("ss_gaussian")

  expect_s3_class(fit, "fusion")
  expect_named(fit, fusion_names)
  expect_null(attr(fit, "baseline_warnings"))

  expect_equal(dim(fitBeta(fit)), c(2000, 41))
  expect_length(drawsOf(fit$draws, "^sigma$"), 2000)

  expect_equal(dim(fusionBeta(fit)), c(1000, 41))
  expect_length(drawsOf(fit$refit_draws, "^sigma$"), 1000)
  expect_named(fit$selection, c("model", "X_dummy_fused", "modelSelection"))
})

test_that("ss_gaussian reproduces the baseline values", {
  skip_on_cran()
  fit <- baselineFit("ss_gaussian")

  expect_equal(fit$numbCoef, 8)
  expect_equal(dic(fit), 1420.337730, tolerance = 1e-6)

  expect_equal(
    mean(drawsOf(fit$draws, "^sigma$")^2),
    0.9861894826,
    tolerance = 1e-8
  )
  expect_equal(
    unname(colMeans(fitBeta(fit))[1:3]),
    c(0.9857784603, 0.0628610384, 1.0556540852),
    tolerance = 1e-8
  )
  expect_equal(sum(colMeans(fusionBeta(fit)) != 0), 17)
})


test_that("mix_gaussian has the expected structure", {
  skip_on_cran()
  fit <- baselineFit("mix_gaussian")

  expect_s3_class(fit, "fusion")
  expect_named(fit, fusion_names)
  expect_equal(attr(fit, "baseline_warnings"), finmix_warning)

  expect_equal(dim(fitBeta(fit)), c(2000, 41))
  expect_length(drawsOf(fit$draws, "^sigma$"), 2000)

  expect_equal(dim(fusionBeta(fit)), c(1000, 41))
  expect_length(drawsOf(fit$refit_draws, "^sigma$"), 1000)
  expect_named(fit$selection, c("model", "X_dummy_fused", "modelSelection"))
})

test_that("mix_gaussian reproduces the baseline values", {
  skip_on_cran()
  fit <- baselineFit("mix_gaussian")

  expect_equal(fit$numbCoef, 9)
  expect_equal(dic(fit), 1421.185059, tolerance = 1e-6)

  expect_equal(
    mean(drawsOf(fit$draws, "^sigma$")^2),
    0.9872764470,
    tolerance = 1e-8
  )
  expect_equal(
    unname(colMeans(fitBeta(fit))[1:3]),
    c(1.0496199016, 0.1570407059, 1.1578000832),
    tolerance = 1e-8
  )
  expect_equal(sum(colMeans(fusionBeta(fit)) != 0), 22)
})


test_that("full_gaussian has the expected structure", {
  skip_on_cran()
  fit <- baselineFit("full_gaussian")

  expect_s3_class(fit, "fusion")
  expect_named(fit, full_names)
  expect_null(attr(fit, "baseline_warnings"))

  expect_equal(dim(fitBeta(fit)), c(2000, 41))
  expect_length(drawsOf(fit$draws, "^sigma$"), 2000)

  expect_null(fit$refit_draws)
  expect_null(fit$selection)
})

test_that("full_gaussian reproduces the baseline values", {
  skip_on_cran()
  fit <- baselineFit("full_gaussian")

  expect_equal(fit$numbCoef, 41)
  expect_equal(dic(fit), 1467.715366, tolerance = 1e-6)

  expect_equal(
    mean(drawsOf(fit$draws, "^sigma$")^2),
    1.0148437579,
    tolerance = 1e-8
  )
  expect_equal(
    unname(colMeans(fitBeta(fit))[1:3]),
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

  expect_equal(dim(fitBeta(fit)), c(2000, 41))
  expect_false("sigma" %in% posterior::variables(fit$draws))

  expect_equal(dim(fusionBeta(fit)), c(1000, 41))
  expect_false("sigma" %in% posterior::variables(fit$refit_draws))
  expect_named(fit$selection, c("model", "X_dummy_fused", "modelSelection"))
})

test_that("ss_binomial reproduces the baseline values", {
  skip_on_cran()
  fit <- baselineFit("ss_binomial")

  expect_equal(fit$numbCoef, 10)
  expect_equal(dic(fit), 969.454765, tolerance = 1e-6)

  expect_equal(
    unname(colMeans(fitBeta(fit))[1:3]),
    c(1.4564448201, -0.0086595662, 1.0056367795),
    tolerance = 1e-8
  )
  expect_equal(sum(colMeans(fusionBeta(fit)) != 0), 18)
})


test_that("mix_binomial has the expected structure", {
  skip_on_cran()
  fit <- baselineFit("mix_binomial")

  expect_s3_class(fit, "fusion")
  expect_named(fit, fusion_names)
  expect_equal(attr(fit, "baseline_warnings"), finmix_warning)

  expect_equal(dim(fitBeta(fit)), c(2000, 41))
  expect_false("sigma" %in% posterior::variables(fit$draws))

  expect_equal(dim(fusionBeta(fit)), c(1000, 41))
  expect_false("sigma" %in% posterior::variables(fit$refit_draws))
  expect_named(fit$selection, c("model", "X_dummy_fused", "modelSelection"))
})

test_that("mix_binomial reproduces the baseline values", {
  skip_on_cran()
  fit <- baselineFit("mix_binomial")

  expect_equal(fit$numbCoef, 15)
  expect_equal(dic(fit), 972.406575, tolerance = 1e-6)

  expect_equal(
    unname(colMeans(fitBeta(fit))[1:3]),
    c(1.4458333057, -0.0033091292, 1.4152759844),
    tolerance = 1e-8
  )
  expect_equal(sum(colMeans(fusionBeta(fit)) != 0), 30)
})
