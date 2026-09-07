mcmcSsLogit <- function(
  y,
  X,
  model,
  prior = list(),
  mcmc,
  mats,
  saveWarmup,
  chain = 1,
  refresh = 0,
  silent = 0
) {
  defaultPrior <- list(r = 5 * 10^6, g0 = 5, G0 = 25, tau2_fix = NULL)
  prior <- utils::modifyList(defaultPrior, as.list(prior))

  N <- nrow(as.matrix(y))
  Xw <- X

  categories <- model$categories
  jkcov <- length(model$cov0)
  jk_beta <- 1 + sum(categories - 1) + model$n_cont
  nVar <- sum(model$n_nom, model$n_ord, model$n_cont)

  if (!is.null(prior$tau2_fix)) {
    if (length(prior$tau2_fix) != nVar) {
      stop("'tau2_fix' must be specified for every covariate separately")
    }
  }

  ind <- cumsum(c(1, rep(1, model$n_cont), categories - 1, 1))

  G <- createSelmat(model$diff)
  G_beta <- createSelmat(categories - 1)

  if (model$n_cont > 0) {
    for (i in 1:model$n_cont) {
      G <- Matrix::bdiag(1, G)
      G_beta <- Matrix::bdiag(1, G_beta)
    }
    G <- as.matrix(G)
    G_beta <- as.matrix(G_beta)
  }

  trG <- t(G)
  trG_beta <- t(G_beta)

  #D <- as.matrix(Matrix::bdiag(1, mats$D_comb))
  B <- as.matrix(Matrix::bdiag(1, mats$B))
  #E <- as.matrix(Matrix::bdiag(1, mats$D_dummy))
  #A_diag <- model$A

  TM <- getTransMat(model)
  qr <- prior$r - 1
  kappa <- y - 1 / 2

  gamma <- getGamma(model)$gamma
  gamma_long <- getGamma(model)$gamma_long
  gn <- prior$g0 + (c(rep(1, model$n_cont), categories - 1)) / 2

  r_delta <- rep(1, jkcov)
  delta <- rep(1, jkcov)

  if (is.null(prior$tau2_fix)) {
    # starting values for sampling
    tau2 <- c(10^9, rep(1000, nVar))
  } else {
    # assign fix values
    tau2 <- c(10^9, prior$tau2_fix)
  }

  tau2_lfd <- c(tau2[1], t(trG_beta %*% tau2[-1]))
  tau2_delta <- c(tau2[1], t(trG %*% tau2[-1]))

  res_flat <- logit(
    y,
    X,
    samp = 3000,
    burn = 1000,
    P0 = diag(0.1, nrow = ncol(X), ncol = ncol(X))
  )
  beta <- colMeans(res_flat$beta)
  #theta_0 <- B %*% beta

  iter <- mcmc$iter
  warmup <- mcmc$warmup
  thin <- mcmc$thin
  nDraws <- (iter - warmup) %/% thin

  result <- list(
    beta = array(0, dim = c(nDraws, jk_beta)),
    delta = array(0, dim = c(nDraws, jkcov)),
    tau2 = matrix(0, nDraws, nVar + 1)
  ) # incl intercept

  if (saveWarmup) {
    warmupDraws <- list(
      beta = array(0, dim = c(warmup, jk_beta)),
      delta = array(0, dim = c(warmup, jkcov)),
      tau2 = matrix(0, warmup, nVar + 1)
    )
  }

  #-------------------MCMC sampler-------------------------------------------#

  progress <- makeProgress(chain, iter, warmup, refresh, silent)

  for (m in 1:iter) {
    progress(m)

    # One index for every parameter. tau2 cannot then drift from beta.
    keep <- m > warmup && (m - warmup) %% thin == 0
    idx <- if (keep) (m - warmup) %/% thin else NA_integer_

    #----- step 1: sample latent variable from Polya-Gamma distribution

    Omega <- Matrix::Diagonal(x = rpg(num = N, z = as.matrix(Xw %*% beta)))

    #------ step 2: sample the regression coefficients beta

    B0_invh <- TM %*% (Matrix::tcrossprod(diag(c(1, 1 / r_delta)), TM)) / gamma
    B0_inv <- B0_invh / tau2_lfd

    BN <- tryCatch(
      chol2inv(chol(B0_inv + Matrix::crossprod(Xw, Omega %*% Xw))),
      error = function(e) {
        solve(
          B0_inv +
            Matrix::crossprod(Xw, Omega %*% Xw)
        )
      },
      B0_inv = B0_inv,
      Xw = Xw,
      Omega = Omega
    )

    bN <- BN %*% Matrix::crossprod(Xw, kappa)
    beta <- MASS::mvrnorm(1, bN, BN)
    theta <- B %*% beta

    #----- step 3: sample the scales tau

    if (is.null(prior$tau2_fix)) {
      Qh <- c()

      for (i in 1:nVar) {
        b_i <- (ind[i] + 1):(ind[i + 1])
        Qh <- c(Qh, t(beta[b_i]) %*% (B0_invh[b_i, b_i] %*% beta[b_i]))
      }

      t_cov <- 1 / stats::rgamma(nVar, gn, prior$G0 + 0.5 * Qh)
      tau2 <- c(
        1 / stats::rgamma(1, prior$g0 + 1 / 2, prior$G0 + 0.5 * theta[1]^2),
        t_cov
      )
      tau2_lfd <- c(tau2[1], t(trG_beta %*% tau2[-1]))
      tau2_delta <- c(tau2[1], t(trG %*% tau2[-1]))
    }

    # ---- step 4: sample the indicator variable delta

    if (m > mcmc$startsel) {
      vv <- 2 * tau2_delta[-1] * gamma_long[-1]
      L <- sqrt(prior$r) * exp(-qr * theta[-1]^2 / vv)
      post_delta <- 1 / (1 + L)
      delta <- stats::rbinom(jkcov, 1, post_delta)
      r_delta <- delta + (1 - delta) / prior$r
    }

    #----- store the draw

    if (keep) {
      result$beta[idx, ] <- as.vector(beta)
      result$tau2[idx, ] <- tau2
      result$delta[idx, ] <- delta
    } else if (saveWarmup && m <= warmup) {
      warmupDraws$beta[m, ] <- as.vector(beta)
      warmupDraws$tau2[m, ] <- tau2
      warmupDraws$delta[m, ] <- delta
    }
  }

  if (saveWarmup) {
    result[["warmup"]] <- warmupDraws
  }
  result[["prior"]] <- prior
  result[["seconds"]] <- progressSeconds(progress)

  return(result)
}
