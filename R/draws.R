#' Variable names for one sampler element
#'
#' @description Names the columns of one element of a sampler result. `beta`
#' takes the coefficient names of \code{createRowNames()} with the brms prefix
#' `b_`. Every other element takes the brms index form, `delta[1]`.
#'
#' @param name a string, the element name
#' @param ncol a single number, the count of columns
#' @param coefNames a character vector, the coefficient names
#'
#' @return a character vector of length \code{ncol}
#'
#' @noRd
fusionVarNames <- function(name, ncol, coefNames) {
  if (name == "beta") {
    return(paste0("b_", coefNames))
  }
  if (name == "sigma") {
    return("sigma")
  }
  paste0(name, "[", seq_len(ncol), "]")
}

# The mixture samplers keep these counts for their own bookkeeping. They are
# not draws of a parameter.
fusionDropped <- c("N_jl_matrix", "N_j0_matrix", "prior", "warmup", "seconds")

#' Assemble the draws of every chain
#'
#' @description Builds one \code{draws_df} from a list of sampler results. Each
#' list element is one chain, so the object carries the true chain index and
#' \code{posterior} computes split-Rhat across the chains.
#'
#' The samplers store the error variance under \code{sgma2}. This function takes
#' its square root once and stores it under the brms name \code{sigma}.
#'
#' @param chains a list of sampler results, one for each chain
#' @param coefNames a character vector, the coefficient names
#'
#' @return a \code{draws_df}
#'
#' @noRd
fusionDraws <- function(chains, coefNames) {
  perChain <- lapply(seq_along(chains), function(k) {
    fusionChainDraws(chains[[k]], coefNames, chain = k)
  })
  d <- do.call(rbind, perChain)
  # rbind repeats the draw index of chain 1 in every later chain. `.draw` must
  # be unique across the object, so number the rows again.
  d$.draw <- seq_len(nrow(d))
  d
}

fusionChainDraws <- function(res, coefNames, chain) {
  res <- res[!names(res) %in% fusionDropped]

  # Every sampler draws the variance. Convert once, here, so no sampler loop
  # carries the standard deviation.
  if (!is.null(res$sgma2)) {
    res$sigma <- sqrt(res$sgma2)
    res$sgma2 <- NULL
  }

  cols <- lapply(names(res), function(nm) {
    m <- as.matrix(res[[nm]])
    colnames(m) <- fusionVarNames(nm, ncol(m), coefNames)
    m
  })
  m <- do.call(cbind, cols)

  d <- posterior::as_draws_df(m)
  d$.chain <- as.integer(chain)
  d
}

#' Coefficient draws of a fusion object
#'
#' @description Returns the regression coefficient draws as a matrix. It reads
#' the refit when the object holds one, and the fit otherwise.
#'
#' @param x an object of class \code{fusion}
#'
#' @return a draws by coefficients matrix with dimnames
#'
#' @export
fusionBeta <- function(x) {
  # Return a plain matrix, not a draws_matrix. A draws_matrix keeps its class
  # and its two dimensions on a row slice, so `beta[i, ]` stays a 1 by k
  # matrix. Matrix multiplication in dic() then fails.
  m <- posterior::as_draws_matrix(
    posterior::subset_draws(
      fusionActiveDraws(x),
      variable = "^b_",
      regex = TRUE
    )
  )
  matrix(
    as.numeric(m),
    nrow = nrow(m),
    ncol = ncol(m),
    dimnames = list(NULL, colnames(m))
  )
}

#' Standard deviation draws of a fusion object
#'
#' @description Returns the draws of the error standard deviation. It returns
#' \code{NULL} for \code{family = 'binomial'}, which fits no scale.
#'
#' @param x an object of class \code{fusion}
#'
#' @return a numeric vector, or \code{NULL}
#'
#' @export
fusionSigma <- function(x) {
  d <- fusionActiveDraws(x)
  if (!"sigma" %in% posterior::variables(d)) {
    return(NULL)
  }
  as.numeric(posterior::extract_variable(d, "sigma"))
}

fusionActiveDraws <- function(x) {
  if (!is.null(x$refit_draws)) x$refit_draws else x$draws
}

refitDrawsOnly <- function(res) {
  res[names(res) %in% c("beta", "sgma2")]
}
