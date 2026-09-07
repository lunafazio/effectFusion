mcmcLinreg <- function(
  y,
  X,
  prior,
  iter,
  warmup,
  thin = 1,
  saveWarmup = FALSE,
  chain = 1,
  refresh = 0,
  silent = 1
) {
  k <- ncol(X)
  N <- nrow(as.matrix(y))
  XX <- crossprod(X)
  Xy <- crossprod(X, y)

  sn <- prior$s0 + N / 2
  tau2 <- rep(prior$tau2_fix, k)

  if (length(tau2) > 1) {
    B0_inv <- diag(1 / tau2)
  } else {
    B0_inv <- 1 / tau2
  }
  cholx <- chol(XX + B0_inv)
  BN <- backsolve(cholx, backsolve(cholx, diag(ncol(cholx)), transpose = TRUE))
  bN <- BN %*% Xy
  sgma2 <- drop(stats::var(y - X %*% bN))

  nDraws <- (iter - warmup) %/% thin

  result <- list(
    beta = array(0, dim = c(nDraws, k)),
    sgma2 = rep(0, nDraws)
  )

  if (saveWarmup) {
    warmupDraws <- list(
      beta = array(0, dim = c(warmup, k)),
      sgma2 = rep(0, warmup)
    )
  }

  result$mcmc <- list(iter = iter, warmup = warmup, thin = thin)
  result$prior <- prior

  #-------------------MCMC sampler-------------------------------------------#

  progress <- makeProgress(chain, iter, warmup, refresh, silent)

  for (m in 1:iter) {
    progress(m)

    # One index for every parameter. sgma2 cannot then drift from beta.
    keep <- m > warmup && (m - warmup) %% thin == 0
    idx <- if (keep) (m - warmup) %/% thin else NA_integer_

    #------ step 1: sample the regression coefficients beta
    if (prior$conj) {
      beta <- MASS::mvrnorm(1, bN, BN * sgma2)
    } else {
      cholx <- chol(XX / sgma2 + B0_inv)
      BN <- backsolve(
        cholx,
        backsolve(cholx, diag(ncol(cholx)), transpose = TRUE)
      )
      bN <- BN %*% Xy / sgma2
      beta <- MASS::mvrnorm(1, bN, BN)
    }

    #----- step 2: sample the error variance
    Sn <- prior$S0 + 1 / 2 * t(y - X %*% beta) %*% (y - X %*% beta)
    sgma2 <- 1 / stats::rgamma(1, sn, Sn)

    #----- store the draw

    if (keep) {
      result$beta[idx, ] <- beta
      result$sgma2[idx] <- sgma2
    } else if (saveWarmup && m <= warmup) {
      warmupDraws$beta[m, ] <- beta
      warmupDraws$sgma2[m] <- sgma2
    }
  }

  if (saveWarmup) {
    result[["warmup"]] <- warmupDraws
  }

  result[["seconds"]] <- progressSeconds(progress)

  return(result)
}
