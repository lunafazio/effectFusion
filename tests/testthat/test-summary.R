# Stage 7 checks print() and summary(). The five baseline fits carry the
# combinations, so these tests reuse them instead of fitting again.

test_that("print() writes the same output as summary()", {
  skip_on_cran()
  fit <- baselineFit("ss_gaussian")

  expect_identical(
    utils::capture.output(print(fit)),
    utils::capture.output(print(summary(fit)))
  )

  # print() passes `...` on to summary().
  expect_true(any(grepl(
    "90% CI",
    utils::capture.output(print(fit, hpd = FALSE, prob = 0.9))
  )))
})

test_that("summary() returns an object and prints nothing", {
  skip_on_cran()
  fit <- baselineFit("ss_gaussian")

  expect_silent(s <- summary(fit))
  expect_s3_class(s, "summary.fusion")
  expect_true(is.list(s))
  expect_named(
    s,
    c(
      "family",
      "data_name",
      "nobs",
      "prior_label",
      "chains",
      "mcmc",
      "ndraws",
      "fusion",
      "coefficients",
      "scale",
      "call"
    )
  )
})

test_that("summary() tabulates every coefficient", {
  skip_on_cran()
  s <- summary(baselineFit("ss_gaussian"))

  expect_equal(nrow(s$coefficients), 41)
  expect_equal(s$fusion$ncoef, 41)
  expect_equal(s$fusion$numbCoef, 8)
  expect_equal(s$nobs, 500)
  expect_equal(s$data_name, "sim1")

  # The refit draws one chain. The summary reports the refit.
  expect_equal(s$chains, 1)
  expect_equal(s$ndraws, 1000)
})

test_that("summary() names the interval after `hpd` and `prob`", {
  skip_on_cran()
  fit <- baselineFit("ss_gaussian")

  expect_named(
    summary(fit)$coefficients,
    c(
      "variable",
      "Estimate",
      "Est.Error",
      "l-95% HPD",
      "u-95% HPD",
      "Rhat",
      "Bulk_ESS",
      "Tail_ESS"
    )
  )
  expect_true("l-95% CI" %in% names(summary(fit, hpd = FALSE)$coefficients))
  expect_true("l-90% HPD" %in% names(summary(fit, prob = 0.9)$coefficients))
})

test_that("summary() rejects an interval mass outside the unit interval", {
  skip_on_cran()
  fit <- baselineFit("ss_gaussian")

  expect_error(summary(fit, prob = 0))
  expect_error(summary(fit, prob = 1))
  expect_error(summary(fit, prob = c(0.5, 0.9)))
})

test_that("a constant coefficient prints '.' and not NA", {
  skip_on_cran()
  s <- summary(baselineFit("ss_gaussian"))

  fixed <- is.na(s$coefficients$Rhat)
  expect_true(any(fixed))

  out <- utils::capture.output(print(s))
  fixed_rows <- grep("^var[0-9]+\\.cat[0-9]+ ", out, value = TRUE)
  fixed_rows <- fixed_rows[grepl("\\.\\s*\\.\\s*\\.\\s*$", fixed_rows)]

  expect_true(length(fixed_rows) > 0)
  expect_false(any(grepl("NA", out)))
  expect_true(any(grepl("fixed by the selected fusion model", out)))
})

test_that("the scale row follows the family", {
  skip_on_cran()

  expect_equal(nrow(summary(baselineFit("ss_gaussian"))$scale), 1)
  expect_equal(summary(baselineFit("ss_gaussian"))$scale$variable, "sigma")
  expect_null(summary(baselineFit("ss_binomial"))$scale)
})

test_that("the fusion block follows the model selection", {
  skip_on_cran()

  # The full model performs no selection, so it reports no fusion block.
  expect_null(summary(baselineFit("full_gaussian"))$fusion)

  # SpikeSlab computes an inclusion probability. FinMix binder does not.
  prob <- summary(baselineFit("ss_gaussian"))$fusion$prob
  expect_named(prob, c("n", "decided", "undecided"))
  expect_equal(prob[["decided"]] + prob[["undecided"]], prob[["n"]])
  expect_null(summary(baselineFit("mix_gaussian"))$fusion$prob)
})

# One test for each combination, because expect_snapshot() names its snapshot
# after the test. A loop over the keys would write every fit to one name.
# print() delegates to summary(), so one snapshot covers both methods.
for (key in baselineKeys) {
  local({
    key <- key
    test_that(paste0("summary() is stable for ", key), {
      skip_on_cran()
      fit <- baselineFit(key)
      expect_snapshot(print(summary(fit)))
    })
  })
}
