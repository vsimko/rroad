# This file provides a function for calculation the international roughness index (IRI) given a road profile.

#' Computes the IRI for fixed length segments (e.g. 100 m segments) given a road profile
#'
#' @param profile Road profile (as numeric vector in mm) whose IRI is to be calculated.
#' @param iri_coef Set of coefficients for specific sample size (e. g. IRI_COEF_100).
#' @param segment.length Distance (in m) for which the IRI is to be calculated. Default is 100 m.
#' @return Calculated IRI (m/km) per segment (as numeric) of the given profile.
#' @examples
#' profile <- rnorm(10000)
#' iri <- CalculateIRI(profile, IRI_COEF_100, 20)
#' par(mfrow = c(1,2))
#' plot(profile, type="l",
#'    xlab="Distance [dm]", ylab="Profile [m]",
#'    main="Read profile (Laser measurement)")
#' plot(iri, type="s",
#'    xlab="Segment", ylab="IRI [m/km]",
#'    main="International Roughness Index (IRI)\nsample = 10cm, segment = 20m")
#' @export
CalculateIRI <- function(profile, iri_coef, segment.length = 100) {
  # initialize costants
  DX <- iri_coef$dx  # sample interval (m)
  K <- max(2, as.integer(.5 + .25 / DX) + 1)  # number of profile points used to compute mvg avg slope input (window)
  BL <- (K - 1) * DX  # baselength
  ST <- iri_coef$st  # coefficients of the iri equations (state transition)
  PR <- iri_coef$pr  # coefficients of the iri equations

  # split profile into segments (e.g. per 100m segment)
  num_samples_per_segment <- segment.length / DX

  # num_segments <- length(profile) / num_samples_per_segment
  profile_segments <- split(profile, ceiling(seq_along(profile) / num_samples_per_segment))

  # vector for collecting return value
  iri <- numeric()

  # loop trough segments and calculate avg iri per segment
  for (profile_segment in profile_segments) {
    # sliding window of profil elevations for calculating mvg avg slope (buffer of length K)
    y <- rep(0, 26)
    y[K] <- profile[K]  # elevation 11 m from start
    y[1] <- profile[1]  # elevation at beginning

    # vehicle variables (1 to 4) containing values from former profil epoint
    z_last <- vector()
    z_last[1] <- (y[K] - y[1]) / 11
    z_last[2] <- 0
    z_last[3] <- z_last[1]
    z_last[4] <- z_last[2]

    rs <- 0  # rectified slope / accumulated slope
    iri_df <- data.frame()  # df for colleteing return values
    ix <- 1  # index within sliding window

    # calculate avg IRI per segment; loop through profile points in segment
    for (i in 1:length(profile_segment)) {

      # filling window; loop through slope calculation window
      next_segm_id <- length(iri) + 2

      if (length(profile_segment) >= ix) { # if slope could be built within semgent
        y[K] <- profile_segment[ix]
      } else if (length(profile_segments) >= next_segm_id && TRUE) { # if slope needs to be built with samples of next segment and there is a following segment
        y[K] <- profile_segments[[next_segm_id]][ix-num_samples_per_segment]
      } else { # if slope needs to be built with samples of next segment but there is no next segment or no following sample
        # y[K] keeps value from former sample
      }

      ix <- ix + 1
      while (ix < K) {
        y[ix] <- y[K]
        y[K] <- profile_segment[ix]
        ix <- ix + 1
      }

      # compute slope input
      yp <- (y[K] - y[1]) / BL
      for (j in 2:K) {
        y[j-1] <- y[j]
      }

      # simulate vehicle response for determining accumulated rs
      z <- vector()  # vehicle variables (1 to 4)
      for (j in 1:4) {
        z[j] <- PR[[j]] * yp
        for (jj in 1:4) {
          z[j] <- z[j] + ST[[j,jj]] * z_last[jj]
        }
      }
      rs <- rs + abs(z[1]- z[3])

      # store vehicle variables (1 to 4) for next profile input
      z_last <- z
    }

    # determine avg rs by dividing by number of samples per segment and attach to result vector
    segm_iri <- rs / length(profile_segment)
    iri <- c(iri, segm_iri)
  }

  # return iri vector
  return(iri)
}


#' Computes the IRI for a continuously increasing segment given a road profile
#'
#' Depending on the sample size a setrain buffer has to be attached to the profile
#' @param profile Road profile (as numeric vector in mm) whose IRIs are to be calculated.
#' @param iri_coef Set of coefficients for specific sample size (e. g. IRI_COEF_100).
#' @return Calculated IRIs (m/km) for increasing segments (as numeric vector) of the given profile.
#' @examples
#' generate_test_profile <- function (x) {
#' if (x < 1) return(0)
#' if (x >= 1 && x < 3) return(x - 1)
#' if (x >= 3 && x < 5) return(5 - x)
#' if (x >= 5) return(0)
#' }
#' x <- seq(.25, 30, by = .25)
#' test_profile <- data.frame(x=x, profile=sapply(x, generate_test_profile))
#' test_profile$iri <- CalculateIRIContinuously(test_profile$profile, IRI_COEF_250)
#' plot(x = test_profile$x, y = test_profile$profile, ylim = c(0, 8), xlim = c(0,25), type = "l")
#' lines(x = test_profile$x, y = test_profile$iri*10)
#' @export
CalculateIRIContinuously <- function(profile, iri_coef) {
  # initialize costants
  DX <- iri_coef$dx  # sample interval (m)
  K <- max(2, as.integer(.5 + .25 / DX) + 1)  # number of profile points used to compute mvg avg slope input (window)
  BL <- (K - 1) * DX  # baselength
  ST <- iri_coef$st  # coefficients of the iri equations (state transition)
  PR <- iri_coef$pr  # coefficients of the iri equations

  # vector for collecting return value
  iris <- numeric()

  # sliding window of profil elevations for calculating mvg avg slope (buffer of length K)
  y <- rep(0, 26)
  y[K] <- profile[K]  # elevation 11 m from start
  y[1] <- profile[1]  # elevation at beginning

  # vehicle variables (1 to 4) containing values from former profile point
  z_last <- vector()
  z_last[1] <- (y[K] - y[1]) / 11
  z_last[2] <- 0
  z_last[3] <- z_last[1]
  z_last[4] <- z_last[2]

  rs <- 0  # rectified slope / accumulated slope
  iri_df <- data.frame()  # df for colleteing return values
  ix <- 1  # index within sliding window

  # calculate IRI for each new profile point; loop through profile points
  for (i in 1:length(profile)) {

    # stop if there are no more point left for building the slope
    if (length(profile) < ix) {
      break
    }

    # filling window; loop through slope calculation window
    y[K] <- profile[ix]
    ix <- ix + 1
    while (ix < K) {
      y[ix] <- y[K]
      y[K] <- profile[ix]
      ix <- ix + 1
    }

    # compute slope input
    yp <- (y[K] - y[1]) / BL
    for (j in 2:K) {
      y[j-1] <- y[j]
    }

    # simulate vehicle response for determining accumulated rs
    z <- vector()  # vehicle variables (1 to 4)
    for (j in 1:4) {
      z[j] <- PR[j] * yp
      for (jj in 1:4) {
        z[j] <- z[j] + ST[j,jj] * z_last[jj]
      }
    }
    rs <- rs + abs(z[1]- z[3])

    # store vehicle variables (1 to 4) for next profile input
    z_last <- z

    # determine avg rs by dividing by number of considered samples and attach to result vector
    current_iri <- rs / i
    iris <- c(iris, current_iri)
  }

  # return iri vector
  return(iris)
}
