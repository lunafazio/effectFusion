#' Simulated data set 2
#'
#' The simulated data set \code{sim2} illustrates a setting with 4000 observations from a linear
#' regression model. The model has four independent predictors with either 10 or 100 categories and
#' uniform prior class probabilities. The first covariate with 10 categories has three levels with no
#' effects, three levels with effects of size 0.5 and the remaining three levels have effects of size one.
#' The second covariate with 10 categories has 8 levels with no effects and only one level with an effect
#' of size one. The final covariate with 10 categories has only levels without any effect on the
#' outcome. Analogue to the first one, the covariate with 100 categories has 33 levels with
#' no effects, 33 levels with effects of size 0.5 and 33 levels with effects of size 1.
#'
#' @docType data
#' @usage data(sim2)
#' @format A data frame with 4000 rows and 5 columns:
#' \describe{
#'  \item{\code{y}}{normal response variable}
#'  \item{\code{var1} to \code{var4}}{4 nominal predictors, stored as unordered
#'  factors}
#' }
#'
#' The coefficients used for data generation are in the \code{beta} attribute.
#' The type of each covariate is in the \code{types} attribute, 'n' for nominal.
#'
#'
#' @seealso \code{\link{effectFusion}}
#' @name sim2
#' @keywords datasets
NULL
