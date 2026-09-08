#' Simulated data set 3
#'
#' The simulated data set \code{sim3} considers a setting with 2000 observations from a logistic
#' regression model. The number and types of predictors, the regression effects and the level probabilites
#' of the predictors are the same as for \code{sim1}. The number of observations was increased as the uncertainty
#' is usually higher for logistic regression compared to linear regression with normal response.
#'
#' @docType data
#' @usage data(sim3)
#' @format A data frame with 2000 rows and 9 columns:
#' \describe{
#'  \item{\code{y}}{binary response variable}
#'  \item{\code{var1} to \code{var8}}{8 categorical predictors. \code{var1} to
#'  \code{var4} are ordinal and are stored as ordered factors. \code{var5} to
#'  \code{var8} are nominal and are stored as unordered factors}
#' }
#'
#' The coefficients used for data generation are in the \code{beta} attribute.
#' The type of each covariate is in the \code{types} attribute, 'o' for ordinal
#' and 'n' for nominal.
#'
#'
#' @seealso \code{\link{effectFusion}, \link{sim1}}
#' @name sim3
#' @keywords datasets
NULL
