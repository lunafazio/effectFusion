# Pin the chain count. These tests check the progress format, not the
# default of `chains`. A test that needs more chains passes its own.
progressFit <- function(chains = 1, ...) {
  data("sim1", package = "effectFusion", envir = environment())

  effectFusion(
    y ~ .,
    sim1,
    method = "SpikeSlab",
    iter = 250,
    warmup = 50,
    startsel = 25,
    refit = list(iter = 125, warmup = 25, thin = 1),
    chains = chains,
    seed = 2024,
    ...
  )
}

scrubSeconds <- function(lines) {
  sub("[0-9]+\\.[0-9]+ seconds", "<n> seconds", lines)
}

messageLines <- function(expr) {
  utils::capture.output(fit <- force(expr), type = "message")
}


test_that("the progress lines follow the Stan format", {
  skip_on_cran()

  lines <- messageLines(progressFit(refresh = 100))

  expect_snapshot_value(scrubSeconds(lines), style = "json2")
})

test_that("refresh stops the progress lines and keeps the elapsed time", {
  skip_on_cran()

  lines <- messageLines(progressFit(refresh = 0))

  expect_false(any(grepl("Iteration:", lines)))
  expect_true(any(grepl("Elapsed Time:", lines)))
})

test_that("silent stops every line", {
  skip_on_cran()
  expect_silent(fit <- progressFit(silent = 1))
})

test_that("the fit stores the time of each chain", {
  skip_on_cran()

  fit <- progressFit(chains = 2, silent = 1)

  expect_length(fit$time, 2)
  expect_named(fit$time[[1]], c("warmup", "sampling"))
  expect_true(all(vapply(fit$time, function(x) x$warmup >= 0, logical(1))))
})
