#' Capture the current RNG state
#'
#' @description Records the RNG kind and \code{.Random.seed}. A session that has
#' drawn no random number has no \code{.Random.seed}. The result records that
#' case as well.
#'
#' @return a list with elements \code{kind} and \code{seed}
#'
#' @noRd
fusionRngState <- function() {
  hasSeed <- exists(".Random.seed", envir = globalenv(), inherits = FALSE)
  list(
    kind = RNGkind(),
    seed = if (hasSeed) {
      get(".Random.seed", envir = globalenv(), inherits = FALSE)
    } else {
      NULL
    }
  )
}

#' Restore a captured RNG state
#'
#' @description Restores the RNG kind, then \code{.Random.seed}. The order
#' matters. \code{RNGkind()} itself writes a new \code{.Random.seed}.
#'
#' @param state a value from \code{fusionRngState()}
#'
#' @return \code{NULL}, invisibly
#'
#' @noRd
fusionRngRestore <- function(state) {
  RNGkind(
    kind = state$kind[1],
    normal.kind = state$kind[2],
    sample.kind = state$kind[3]
  )
  if (is.null(state$seed)) {
    if (exists(".Random.seed", envir = globalenv(), inherits = FALSE)) {
      rm(".Random.seed", envir = globalenv())
    }
  } else {
    assign(".Random.seed", state$seed, envir = globalenv())
  }
  invisible(NULL)
}

#' Seed the RNG for a reproducible fit
#'
#' @description Sets the RNG kind to \code{"L'Ecuyer-CMRG"} and seeds it.
#'
#' \code{"L'Ecuyer-CMRG"} splits one seed into independent substreams. The
#' parallel chains therefore draw from streams that never overlap.
#'
#' Warning: this function changes the RNG state of the session. Capture the old
#' state with \code{fusionRngState()} first. Restore it with
#' \code{fusionRngRestore()} in an \code{on.exit()} call.
#'
#' @param seed a single number
#'
#' @return \code{NULL}, invisibly
#'
#' @noRd
fusionRngSeed <- function(seed) {
  RNGkind("L'Ecuyer-CMRG")
  set.seed(seed, kind = "L'Ecuyer-CMRG")
  invisible(NULL)
}
