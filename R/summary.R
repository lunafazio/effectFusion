#' Posterior summary of one parameter set
#'
#' @description Builds one summary table. Takes the estimate, the error, the
#' interval and the convergence diagnostics of \code{posterior}.
#'
#' @param d a \code{draws} object
#' @param pars a character vector, the variables to summarise
#' @param prob a single number, the interval mass
#' @param hpd a single logical, \code{TRUE} for a highest posterior density
#' interval and \code{FALSE} for an equal-tailed interval
#' @param robust a single logical, \code{TRUE} for the median and the median
#' absolute deviation and \code{FALSE} for the mean and the standard deviation
#'
#' @return a data frame, one row for each variable
#'
#' @noRd
summaryTable <- function(d, pars, prob, hpd, robust) {
  d <- posterior::subset_draws(d, variable = pars)
  m <- posterior::as_draws_matrix(d)

  centre <- if (robust) stats::median else mean
  spread <- if (robust) stats::mad else stats::sd

  alpha <- 1 - prob
  if (hpd) {
    interval <- t(apply(m, 2, hpdMCMC, alpha = alpha))
  } else {
    interval <- t(apply(
      m,
      2,
      stats::quantile,
      probs = c(alpha / 2, 1 - alpha / 2)
    ))
  }

  diag <- posterior::summarise_draws(
    d,
    posterior::default_convergence_measures()
  )

  tab <- data.frame(
    variable = pars,
    Estimate = apply(m, 2, centre),
    Est.Error = apply(m, 2, spread),
    lower = interval[, 1],
    upper = interval[, 2],
    Rhat = diag$rhat,
    Bulk_ESS = diag$ess_bulk,
    Tail_ESS = diag$ess_tail,
    row.names = NULL,
    check.names = FALSE
  )

  label <- if (hpd) "HPD" else "CI"
  pct <- format(100 * prob, trim = TRUE)
  names(tab)[4:5] <- paste0(c("l-", "u-"), pct, "% ", label)
  tab
}

#' Describe the prior of a fusion object
#'
#' @description Writes the prior name and its hyper-parameters as one string.
#'
#' @param x an object of class \code{fusion}
#'
#' @return a single string
#'
#' @noRd
priorLabel <- function(x) {
  if (is.null(x$method)) {
    return("flat, uninformative")
  }
  if (identical(x$method, "SpikeSlab")) {
    if (is.null(x$prior$tau2_fix)) {
      return(paste0(
        "spike and slab (r = ",
        x$prior$r,
        ", g0 = ",
        x$prior$g0,
        ", G0 = ",
        x$prior$G0,
        ")"
      ))
    }
    return(paste0(
      "spike and slab (r = ",
      x$prior$r,
      ", tau2_fix = ",
      toString(x$prior$tau2_fix),
      ")"
    ))
  }
  paste0("finite mixture (e0 = ", x$prior$e0, ", p = ", x$prior$p, ")")
}

#' Name the data of a fusion object
#'
#' @description Reads the name of the data from the call. A call that passes
#' \code{sim1$X} names the data \code{sim1}, exactly as brms does. A call that
#' passes a bare data frame names that data frame.
#'
#' @param call_X the \code{X} element of the matched call
#'
#' @return a single string
#'
#' @noRd
dataName <- function(call_X) {
  # `sim1$X` and `sim1[["X"]]` both name the object `sim1`.
  while (is.call(call_X) && as.character(call_X[[1]]) %in% c("$", "[[")) {
    call_X <- call_X[[2]]
  }
  paste(deparse(call_X), collapse = "")
}

#' @title Summary of object of class \code{fusion}
#'
#' @description Summarises the model, the prior, the selected fusion and the
#' posterior of the regression effects.
#'
#' @param object an object of class \code{fusion}
#' @param prob a single number between 0 and 1 (default 0.95), the mass of the
#' reported interval
#' @param hpd if \code{TRUE} (default) the interval is a highest posterior
#' density interval. If \code{FALSE} it is an equal-tailed interval.
#' @param robust if \code{TRUE} (default \code{FALSE}) the estimate is the
#' median and the error is the median absolute deviation. If \code{FALSE} they
#' are the mean and the standard deviation.
#' @param ... further arguments passed to or from other methods (not used)
#'
#' @details The model selected with function \code{effectFusion} is refitted with
#' a flat uninformative prior to get estimates for the regression coefficients.
#' The summary reports that refit. Fused categories share one estimate and one
#' interval.
#'
#' If a full model is fitted (\code{method} in \code{effectFusion} is NULL) or no
#' final model selection is performed (argument \code{modelSelection} in
#' \code{effectFusion} is NULL), the estimates are model averaged results.
#'
#' A coefficient that the selected fusion model fixes is constant over the draws.
#' \code{Rhat} and the effective sample sizes are undefined for it. The print
#' method writes \code{.} for each.
#'
#' @return an object of class \code{summary.fusion}, which is a list with the
#' elements \code{family}, \code{data_name}, \code{nobs},
#' \code{prior_label}, \code{chains}, \code{mcmc}, \code{ndraws},
#' \code{fusion}, \code{coefficients}, \code{scale} and \code{call}.
#'
#' @author Daniela Pauger, Magdalena Leitner <effectfusion.jku@gmail.com>
#'
#' @seealso \code{\link{effectFusion}}
#'
#' @method summary fusion
#' @export
#'
#' @examples
#' ## see example for effectFusion
summary.fusion <- function(
  object,
  prob = 0.95,
  hpd = TRUE,
  robust = FALSE,
  ...
) {
  stopifnot(is(object, "fusion"))
  stopifnot(length(prob) == 1, prob > 0, prob < 1)

  x <- object
  d <- fusionActiveDraws(x)
  vars <- posterior::variables(d)
  coefPars <- grep("^b_", vars, value = TRUE)

  # The summary reports the draws that it tabulates. A selected model tabulates
  # the refit, which runs one chain in this process. Every other fit tabulates
  # its own draws, which run x$chains chains.
  refitted <- !is.null(x$refit_draws)
  mcmc <- if (refitted) x$refit_settings else x$mcmc
  # Read the chain count from the draws, not from x$chains. A full model
  # ignores `chains` and always draws one chain.
  chains <- posterior::nchains(d)

  fusion <- if (is.null(x$modelSelection)) {
    NULL
  } else {
    # The inclusion probabilities are bimodal. The sampler drives most of them
    # to 0 or to 1, so min, median and max describe the spike at each end and
    # not the fit. Count the differences that the sampler left undecided.
    prob_stats <- if (is.null(x$selection$incl_prob)) {
      NULL
    } else {
      p <- x$selection$incl_prob
      c(
        n = length(p),
        decided = sum(p <= 0.05 | p >= 0.95),
        undecided = sum(p > 0.05 & p < 0.95)
      )
    }
    list(
      numbCoef = x$numbCoef,
      ncoef = length(coefPars),
      levels = fusedLevels(x),
      prob = prob_stats
    )
  }

  out <- list(
    family = x$family,
    data_name = dataName(x$call$X),
    nobs = length(x$data$y),
    prior_label = priorLabel(x),
    chains = chains,
    mcmc = mcmc,
    ndraws = posterior::ndraws(d),
    fusion = fusion,
    coefficients = summaryTable(d, coefPars, prob, hpd, robust),
    scale = if ("sigma" %in% vars) {
      summaryTable(d, "sigma", prob, hpd, robust)
    } else {
      NULL
    },
    call = x$call
  )

  # The coefficient names carry the brms `b_` prefix in the draws. The table
  # reads as a list of covariates, so drop it.
  out$coefficients$variable <- sub("^b_", "", out$coefficients$variable)

  class(out) <- "summary.fusion"
  out
}
