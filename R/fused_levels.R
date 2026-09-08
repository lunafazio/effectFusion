#' Fused level groups of a fusion object
#'
#' @description Returns the selected fusion for each categorical covariate.
#' The result is data, so \code{model()} and \code{print.summary.fusion} share
#' one implementation.
#'
#' Each list element is one covariate. Each element holds one character vector
#' for each level group after fusion. Fused levels appear in one vector.
#'
#' @param x an object of class \code{fusion}
#'
#' @return a named list of lists of character vectors, or \code{NULL} when the
#' object performed no model selection
#'
#' @noRd
fusedLevels <- function(x) {
  stopifnot(is(x, "fusion"))

  if (is.null(x$modelSelection)) {
    return(NULL)
  }

  varCat <- x$model$n_ord + x$model$n_nom
  sel_mod <- x$selection$model
  ind <- c(0, cumsum(c(rep(1, x$model$n_cont), x$model$diff))) + 1
  cat <- x$model$categories

  out <- vector("list", varCat)

  for (i in seq_len(varCat)) {
    k <- i + x$model$n_cont
    if (x$data$types[k] == "o") {
      S <- getSOrdinal(sel_mod[ind[k]:(ind[k + 1] - 1)])
    }
    if (x$data$types[k] == "n") {
      S <- getSNominal(cat[i], sel_mod[ind[k]:(ind[k + 1] - 1)])
    }

    show_model <- list()
    if (sum(rowSums(S) == 0) > 0) {
      show_model[[1]] <- c(0, which(rowSums(S) == 0))
    } else {
      show_model[[1]] <- 0
    }

    if (length(show_model[[1]]) != cat[i]) {
      if (sum(S[, 1]) == 0) {
        for (j in 2:ncol(S)) {
          show_model[[j]] <- which(S[, j] == 1)
        }
      } else {
        for (j in seq_len(ncol(S))) {
          show_model[[j + 1]] <- which(S[, j] == 1)
        }
      }
    }

    show_model <- lapply(show_model, function(z) z + 1)
    out[[i]] <- lapply(show_model, function(z) x$data$levelnames[[i]][z])
  }

  names(out) <- names(x$data$levelnames)[seq_len(varCat)]
  out
}
