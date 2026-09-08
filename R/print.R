#' @title Print object of class \code{fusion}
#'
#' @description The default print method for a \code{fusion} object.
#'
#' @param x an object of class \code{fusion}
#' @param ... further arguments passed to \code{\link{summary.fusion}}
#'
#' @details Writes the same output as \code{\link{summary.fusion}}: the model,
#' the prior, the draw counts, the covariates, the selected fusion and the
#' posterior summary tables.
#'
#' @return \code{x}, invisibly
#'
#' @author Daniela Pauger, Magdalena Leitner <effectfusion.jku@gmail.com>
#'
#' @seealso \code{\link{effectFusion}}, \code{\link{summary.fusion}}
#' @method print fusion
#' @export
#'
#' @examples
#' ## see example for effectFusion

print.fusion <- function(x, ...) {
  stopifnot(is(x, "fusion"))

  print(summary(x, ...))

  invisible(x)
}
