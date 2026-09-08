# deriveTypes() reads the type of each predictor from its column. The user
# therefore does not pass `types`. These tests cover each column class and the
# shipped data.

test_that("deriveTypes() reads the type from the column class", {
  data <- data.frame(
    ord = ordered(c("a", "b", "c")),
    fac = factor(c("a", "b", "c")),
    chr = c("a", "b", "c"),
    num = c(1.5, 2.5, 3.5),
    int = 1:3,
    lgl = c(TRUE, FALSE, TRUE),
    stringsAsFactors = FALSE
  )

  expect_equal(
    deriveTypes(data),
    c(ord = "o", fac = "n", chr = "n", num = "c", int = "c", lgl = "c")
  )
})


test_that("deriveTypes() keeps the column order", {
  data <- data.frame(
    a = c(1.5, 2.5),
    b = factor(c("x", "y")),
    c = ordered(c("x", "y"))
  )

  expect_equal(deriveTypes(data), c(a = "c", b = "n", c = "o"))
})


test_that("deriveTypes() takes one column", {
  expect_equal(deriveTypes(data.frame(x = factor("a"))), c(x = "n"))
})


test_that("deriveTypes() rejects a factor with an unused level", {
  data <- data.frame(a = factor(c("x", "y"), levels = c("x", "y", "z")))

  expect_error(deriveTypes(data), "not supported yet")
  expect_error(deriveTypes(data), "a\\.")
})


test_that("deriveTypes() rejects an unused level in an ordered factor", {
  data <- data.frame(a = ordered(c("x", "y"), levels = c("x", "y", "z")))

  expect_error(deriveTypes(data), "not supported yet")
})


test_that("deriveTypes() names every predictor with an unused level", {
  data <- data.frame(
    a = factor("x", levels = c("x", "z")),
    b = factor("p", levels = c("p", "q")),
    c = factor("m")
  )

  expect_error(deriveTypes(data), "a, b")
})


test_that("deriveTypes() takes a factor that uses every level", {
  data <- data.frame(a = factor(c("x", "y")), b = ordered(c("p", "q")))

  expect_equal(deriveTypes(data), c(a = "n", b = "o"))
})


test_that("deriveTypes() ignores NA when it counts the levels", {
  used <- data.frame(a = factor(c("x", NA, "y")))
  unused <- data.frame(a = factor(c("x", NA), levels = c("x", "y")))

  expect_equal(deriveTypes(used), c(a = "n"))
  expect_error(deriveTypes(unused), "not supported yet")
})


test_that("deriveTypes() rejects an object that is not a data frame", {
  expect_error(deriveTypes(factor(c("a", "b"))))
  expect_error(deriveTypes(matrix(1:4, 2)))
})


test_that("deriveTypes() reproduces the types of the shipped data", {
  for (name in c("sim1", "sim2", "sim3")) {
    data(list = name, package = "effectFusion", envir = environment())
    simulated <- get(name, envir = environment())

    expect_equal(
      unname(deriveTypes(simulated[-1])),
      attr(simulated, "types"),
      info = name
    )
  }
})


test_that("asFormula() takes a formula unchanged", {
  formula <- y ~ var1 + var2

  expect_identical(asFormula(formula), formula)
})


test_that("asFormula() coerces a single string", {
  converted <- asFormula("y ~ var1")

  expect_s3_class(converted, "formula")
  expect_equal(deparse(converted), "y ~ var1")
  expect_s3_class(asFormula("y ~ ."), "formula")
})


test_that("asFormula() gives the converted formula the environment it takes", {
  env <- new.env()

  expect_identical(environment(asFormula("y ~ var1", env = env)), env)
})


test_that("a string reads the variables that a formula reads", {
  data("sim1", package = "effectFusion", envir = environment())
  settings <- list(
    method = "SpikeSlab",
    iter = 300,
    warmup = 100,
    startsel = 50,
    chains = 1,
    cores = 1,
    seed = 1,
    refresh = 0,
    silent = 1,
    refit = list(iter = 100, warmup = 25, thin = 1)
  )

  # `local` lives in this frame only. A converted formula must still find it.
  local <- sim1$y * 2
  fromString <- do.call(
    effectFusion,
    c(list("local ~ var1 + var5", sim1), settings)
  )
  fromFormula <- do.call(
    effectFusion,
    c(list(local ~ var1 + var5, sim1), settings)
  )

  expect_equal(
    as.data.frame(fromString$draws),
    as.data.frame(fromFormula$draws)
  )
})


test_that("asFormula() rejects a string that does not parse", {
  expect_error(asFormula("hello"), "does not parse")
  expect_error(asFormula("y ~~ +"), "does not parse")
})


test_that("asFormula() rejects an object that is neither", {
  expect_error(asFormula(c("y ~ a", "y ~ b")), "single string")
  expect_error(asFormula(NA_character_), "single string")
  expect_error(asFormula(42), "single string")
  expect_error(asFormula(character(0)), "single string")
})
