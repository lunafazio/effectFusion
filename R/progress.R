#' Build a progress reporter for one chain
#'
#' @description Returns a function. Call the function with the iteration
#' number at the top of each sampler loop. The function writes one line when
#' the iteration is due and an elapsed time block after the last iteration.
#'
#' The format follows Stan:
#'
#' \preformatted{
#' Chain 1: Iteration:     1 / 25000 [  0%]  (Warmup)
#' Chain 1: Iteration:  5001 / 25000 [ 20%]  (Sampling)
#' }
#'
#' The function always writes the first iteration, the last iteration and the
#' first sampling iteration for any non-zero \code{refresh}.
#'
#' @param chain a single number, the index of the chain
#' @param iter a single number, the count of iterations including warmup
#' @param warmup a single number, the count of warmup iterations
#' @param refresh a single number, the iterations between updates. Zero stops
#'   the progress lines.
#' @param silent a single number, one or more stops the elapsed time block.
#'
#' @return a function of one argument, the iteration number
#'
#' @noRd
makeProgress <- function(chain, iter, warmup, refresh, silent = 0) {
  width <- nchar(format(iter, scientific = FALSE))
  start <- Sys.time()
  warmupEnd <- start
  samplingEnd <- start

  elapsed <- function(from, to) as.numeric(difftime(to, from, units = "secs"))

  progress <- function(m) {
    if (m == warmup + 1) {
      warmupEnd <<- Sys.time()
    }

    due <- refresh > 0 &&
      (m == 1 || m == iter || m == warmup + 1 || m %% refresh == 0)

    if (due) {
      message(sprintf(
        "Chain %d: Iteration: %s / %d [%3.0f%%]  (%s)",
        chain,
        formatC(m, width = width, format = "d"),
        iter,
        100 * m / iter,
        if (m <= warmup) "Warmup" else "Sampling"
      ))
    }

    if (m == iter) {
      samplingEnd <<- Sys.time()
      if (silent < 1) {
        reportElapsed(
          chain,
          elapsed(start, warmupEnd),
          elapsed(warmupEnd, samplingEnd)
        )
      }
    }

    invisible(NULL)
  }

  attr(progress, "seconds") <- function() {
    list(
      warmup = elapsed(start, warmupEnd),
      sampling = elapsed(warmupEnd, samplingEnd)
    )
  }

  progress
}

progressSeconds <- function(progress) {
  attr(progress, "seconds")()
}

reportElapsed <- function(chain, warmupSecs, samplingSecs) {
  line <- function(...) message(sprintf("Chain %d: %s", chain, sprintf(...)))

  message(sprintf("Chain %d:", chain))
  line(" Elapsed Time: %.1f seconds (Warm-up)", warmupSecs)
  line("               %.1f seconds (Sampling)", samplingSecs)
  line("               %.1f seconds (Total)", warmupSecs + samplingSecs)

  invisible(NULL)
}
