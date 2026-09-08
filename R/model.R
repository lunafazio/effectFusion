#' @title Selected model of a \code{fusion} object
#' @description The function displays for categorical covariates the selected model of an
#' object of class \code{fusion} as list.
#'
#' @param x an object of class \code{fusion}
#'
#' @details The selected model for each categorical predictor is displayed as a list of length equal
#' to the number of categories after fusion. Fused categories are shown with their original labelling
#' in one list element.
#' The function is only available if effect fusion (method in \code{effectFusion} is unequal to \code{NULL})
#' and final model selection (argument \code{modelSelection} in \code{effectFusion} is not NULL) is performed.
#'
#' See \code{summary.fusion} for more details.
#'
#' @author Daniela Pauger, Magdalena Leitner <effectfusion.jku@gmail.com>
#' @seealso \code{\link{effectFusion}}
#' @export
#'
#' @examples
#' ## see example for effectFusion
#'

model <- function(x) {
  stopifnot(is(x, "fusion"))

  groups <- fusedLevels(x)

  if (is.null(groups)) {
    cat("No model selection performed")
    return(invisible(NULL))
  }

  for (i in seq_along(groups)) {
    cat("Covariate '", names(groups)[i], "'", sep = "", "\n")
    print(groups[[i]])
  }

  invisible(groups)
}
