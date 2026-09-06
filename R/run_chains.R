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

#' Bind the chains into one result
#'
#' @description Binds each element across the chains. Matrices bind by row.
#' Vectors concatenate. The draws of chain 1 come first.
#'
#' `prior` is one prior for every chain, not a draw. It passes through unbound.
#'
#' @param chains a list of sampler results
#'
#' @return one sampler result
#'
#' @noRd
poolChains <- function(chains) {
  if (length(chains) == 1) {
    return(chains[[1]])
  }

  pooled <- lapply(setdiff(names(chains[[1]]), "prior"), function(nm) {
    parts <- lapply(chains, `[[`, nm)
    if (is.matrix(parts[[1]])) do.call(rbind, parts) else unlist(parts)
  })
  names(pooled) <- setdiff(names(chains[[1]]), "prior")

  if ("prior" %in% names(chains[[1]])) {
    pooled[["prior"]] <- chains[[1]]$prior
  }
  pooled
}

dropWarmup <- function(chain, burnin) {
  prior <- chain$prior
  out <- lapply(chain[names(chain) != "prior"], function(x) {
    if (is.matrix(x)) x[-(1:burnin), ] else x[-(1:burnin)]
  })
  if (!is.null(prior)) {
    out[["prior"]] <- prior
  }
  out
}
