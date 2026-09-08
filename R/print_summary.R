#' Format the fused levels of one covariate
#'
#' @description Writes one group as \code{{cat1,cat2}}. Writes the groups of
#' one covariate as \code{{cat1}, {cat2,cat3}}.
#'
#' @param groups a list of character vectors, the groups of one covariate
#'
#' @return a single string
#'
#' @noRd
formatFusedLevels <- function(groups) {
  paste(
    vapply(
      groups,
      function(g) paste0("{", paste(g, collapse = ","), "}"),
      character(1)
    ),
    collapse = ", "
  )
}

#' Format one posterior summary table
#'
#' @description Rounds every column to two digits. Writes \code{.} for each
#' \code{NA}, which marks a coefficient that the fusion model fixes.
#'
#' @param tab a data frame, one row for each parameter
#'
#' @return a character matrix, with row names and column names
#'
#' @noRd
formatSummaryTable <- function(tab) {
  pars <- tab$variable
  tab <- tab[names(tab) != "variable"]

  # The two effective sample sizes are counts. Every other column is on the
  # scale of the parameter, so it takes two digits.
  counts <- c("Bulk_ESS", "Tail_ESS")

  out <- vapply(
    names(tab),
    function(nm) {
      col <- tab[[nm]]
      txt <- if (nm %in% counts) {
        format(round(col), trim = TRUE)
      } else {
        format(round(col, 2), nsmall = 2, trim = TRUE)
      }
      txt[is.na(col)] <- "."
      txt
    },
    character(nrow(tab))
  )

  out <- matrix(out, nrow = length(pars), dimnames = list(pars, names(tab)))
  out
}

#' Print a summary of an object of class \code{fusion}
#'
#' @description Prints the model, the prior, the draw counts, the selected
#' fusion and the posterior summary tables.
#'
#' @param x an object of class \code{summary.fusion}
#' @param ... further arguments passed to or from other methods (not used)
#'
#' @return \code{x}, invisibly
#'
#' @author Daniela Pauger, Magdalena Leitner <effectfusion.jku@gmail.com>
#'
#' @seealso \code{\link{effectFusion}}, \code{\link{summary.fusion}}
#' @method print summary.fusion
#' @export
#'
#' @examples
#' ## see example for effectFusion
print.summary.fusion <- function(x, ...) {
  stopifnot(is(x, "summary.fusion"))

  cat(" Family: ", x$family, "\n", sep = "")
  cat(
    "   Data: ",
    x$data_name,
    " (Number of observations: ",
    x$nobs,
    ")\n",
    sep = ""
  )
  cat("  Prior: ", x$prior_label, "\n", sep = "")
  cat(
    "  Draws: ",
    x$chains,
    if (x$chains == 1) {
      " chain, each with iter = "
    } else {
      " chains, each with iter = "
    },
    x$mcmc$iter,
    "; warmup = ",
    x$mcmc$warmup,
    "; thin = ",
    x$mcmc$thin,
    "\n",
    sep = ""
  )
  cat("         total post-warmup draws = ", x$ndraws, "\n", sep = "")

  if (!is.null(x$fusion)) {
    cat("\nEffect fusion:\n")
    cat(
      "  Model dimension:      ",
      x$fusion$numbCoef,
      " of ",
      x$fusion$ncoef,
      " coefficients\n",
      sep = ""
    )
    cat("  Fused levels:\n")
    for (i in seq_along(x$fusion$levels)) {
      cat(
        "    ",
        names(x$fusion$levels)[i],
        ": ",
        formatFusedLevels(x$fusion$levels[[i]]),
        "\n",
        sep = ""
      )
    }
    if (!is.null(x$fusion$prob)) {
      cat(
        "  Fusion certainty:     ",
        x$fusion$prob[["undecided"]],
        " of ",
        x$fusion$prob[["n"]],
        " level differences undecided",
        "\n",
        sep = ""
      )
    }
  }

  cat("\nRegression Coefficients:\n")
  print(formatSummaryTable(x$coefficients), quote = FALSE, right = TRUE)

  if (!is.null(x$scale)) {
    cat("\nFurther Distributional Parameters:\n")
    print(formatSummaryTable(x$scale), quote = FALSE, right = TRUE)
  }

  cat("\nCall:\n")
  print(x$call)

  if (anyNA(x$coefficients$Rhat)) {
    cat(
      "\nCoefficients marked '.' are fixed by the selected fusion model.\n"
    )
    cat("Rhat and ESS are undefined for them.\n")
  }

  invisible(x)
}
