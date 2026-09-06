#' Run the MCMC chains
#'
#' @description Runs \code{chains} independent chains of one sampler. Each chain
#' runs in its own process when \code{cores} is greater than one.
#'
#' Chain \emph{k} draws from the \emph{k}-th \code{"L'Ecuyer-CMRG"} substream
#' of \code{seed}. Every chain adopts its own stream before it draws so results
#' match whether in parallel (mirai) or serially (lapply).
#'
#' @param sampler a function that draws samples
#' @param args a list of arguments for \code{sampler}
#' @param chains a single number, the count of chains
#' @param cores a single number, the count of processes
#' @param seed a single number, or \code{NULL} to draw one
#'
#' @return a list with elements \code{chains} and \code{seed}. \code{chains}
#' holds one sampler result for each chain that succeeded.
#'
#' @noRd
runChains <- function(sampler, args, chains, cores, seed = NULL) {
  cores <- min(cores, chains)

  oldRng <- fusionRngState()
  on.exit(fusionRngRestore(oldRng), add = TRUE)

  # NULL seed still needs a value, the chains otherwise start from one state
  # and return identical draws. Record the drawn seed for reproducibility.
  if (is.null(seed)) {
    seed <- sample.int(.Machine$integer.max, 1)
  }

  fusionRngSeed(seed)
  streams <- chainStreams(chains)

  if (cores == 1) {
    res <- lapply(streams, function(stream) {
      try(runOneChain(stream, sampler, args), silent = TRUE)
    })
  } else {
    res <- with(
      mirai::daemons(cores),
      mirai::mirai_map(
        streams,
        runOneChain,
        .args = list(sampler = sampler, args = args)
      )[]
    )
  }

  list(chains = collectChains(res), seed = seed)
}

runOneChain <- function(stream, sampler, args) {
  RNGkind("L'Ecuyer-CMRG")
  assign(".Random.seed", stream, envir = globalenv())
  do.call(sampler, args)
}

chainStreams <- function(chains) {
  streams <- vector("list", chains)
  stream <- get(".Random.seed", envir = globalenv(), inherits = FALSE)
  for (k in seq_len(chains)) {
    streams[[k]] <- stream
    stream <- parallel::nextRNGStream(stream)
  }
  streams
}

collectChains <- function(res) {
  failed <- vapply(res, isChainFailure, logical(1))

  if (all(failed)) {
    stop(
      "All ",
      length(res),
      " chains failed. First error:\n",
      chainMessage(res[[1]]),
      call. = FALSE
    )
  }

  if (any(failed)) {
    warning(
      "Chain ",
      paste(which(failed), collapse = ", "),
      " of ",
      length(res),
      " failed. First error:\n",
      chainMessage(res[[which(failed)[1]]]),
      call. = FALSE
    )
  }

  res[!failed]
}

isChainFailure <- function(x) {
  mirai::is_error_value(x) || inherits(x, "try-error")
}

chainMessage <- function(x) {
  if (mirai::is_error_value(x)) {
    return(as.character(x))
  }
  conditionMessage(attr(x, "condition"))
}
