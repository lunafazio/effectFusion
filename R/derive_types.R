#' Derive the type of each predictor
#'
#' @description Reads the type of each predictor from its column. The user
#' therefore does not pass \code{types}.
#'
#' An ordered factor is ordinal. An unordered factor is nominal. A character
#' column is nominal. Every other column is continuous.
#'
#' A logical column is continuous. It enters the model as one 0/1 column, with
#' \code{TRUE} as 1. Convert it to a factor to fuse its two levels instead.
#'
#' Warning: a factor must not declare a level that the data does not use. An
#' unused level gives an all-zero dummy column and a rank-deficient design.
#' The function raises an error and names each such factor. Call
#' \code{droplevels()} on the data to remove the unused levels.
#'
#' @param data a data frame of predictors
#'
#' @return a character vector with one element for each column. Each element is
#' \code{"c"}, \code{"o"} or \code{"n"}.
#'
#' @noRd
deriveTypes <- function(data) {
  stopifnot(is.data.frame(data))

  checkUnusedLevels(data)

  vapply(data, deriveOneType, character(1), USE.NAMES = TRUE)
}

#' Reject a factor that declares a level the data does not use
#'
#' @param data a data frame of predictors
#'
#' @return \code{NULL}, invisibly. The function is called for the error.
#'
#' @noRd
checkUnusedLevels <- function(data) {
  unused <- vapply(data, hasUnusedLevels, logical(1))

  if (any(unused)) {
    stop(
      "Unused factor levels are not supported yet. ",
      "Each of these predictors declares a level that the data does not use: ",
      paste(names(data)[unused], collapse = ", "),
      ". Call droplevels() on the data.",
      call. = FALSE
    )
  }

  invisible(NULL)
}

hasUnusedLevels <- function(column) {
  if (!is.factor(column)) {
    return(FALSE)
  }

  any(tabulate(as.integer(column), nlevels(column)) == 0)
}

deriveOneType <- function(column) {
  if (is.ordered(column)) {
    return("o")
  }
  if (is.factor(column) || is.character(column)) {
    return("n")
  }
  "c"
}
