# This file provides a function for calculation the international roughness index (IRI) given a road profile.

#' Computes the IRI for fixed length segments (e.g. 100 m segments) given a road profile
#'
#' @param profile Road profile (as numeric vector in mm) whose IRI is to be calculated.
#' @param iri_coef Set of coefficients for specific sample size (e. g. IRI_COEF_100).
#' @param segment.length Distance (in m) for which the IRI is to be calculated. Default is 100 m.
#' @return Calculated IRI (m/km) per segment (as numeric) of the given profile.
#' @examples
#' profile <- rnorm(10000)
#' iri <- CalculateIRIperSegments(profile, IRI_COEF_100, 20)
#' par(mfrow = c(1,2))
#' plot(profile, type="l",
#'    xlab="Distance [dm]", ylab="Profile [m]",
#'    main="Read profile (Laser measurement)")
#' plot(iri, type="s",
#'    xlab="Segment", ylab="IRI [m/km]",
#'    main="International Roughness Index (IRI)\nsample = 10cm, segment = 20m")
#' @export
CalculateIRIperSegments <- function(profile, iri_coef, segment.length = 100) {
  # CalculateIRIperSegmentsOverlapping() with segment.offset = segment.length
  CalculateIRIperSegmentsOverlapping(profile, iri_coef, segment.length, segment.length)
}


#' Computes the IRI for fixed length overlapping segments (e.g. 100 m segments) with an
#' offset (e.g. 20 m) given a road profile
#'
#' @param profile Road profile (as numeric vector in mm) whose IRI is to be calculated.
#' @param iri_coef Set of coefficients for specific sample size (e. g. IRI_COEF_100).
#' @param segment.length Distance (in m) for which the IRI is to be calculated. Default is 100 m.
#' @param segment.offset Offset (in m) for which the segments will not overlap. Default is 20 m.
#' @return Calculated IRI (m/km) per segment (as numeric) of the given profile.
#' @examples
#' profile <- rnorm(10000)
#' iri <- CalculateIRIperSegments(profile, IRI_COEF_100, 20)
#' par(mfrow = c(1,2))
#' plot(profile, type="l",
#'    xlab="Distance [dm]", ylab="Profile [m]",
#'    main="Read profile (Laser measurement)")
#' plot(iri, type="s",
#'    xlab="Segment (with 20 m offset)", ylab="IRI [m/km]",
#'    main="International Roughness Index (IRI)\nsample = 10cm, segment = 20m")
#' @export
CalculateIRIperSegmentsOverlapping <- function(profile, iri_coef, segment.length = 100, segment.offset = 20) {
  # check that segment.offset is samller than segment.length
  stopifnot(segment.length >= segment.offset)

  # initialize costants
  DX <- iri_coef$dx  # sample interval (m)
  K <- max(2, as.integer(.5 + .25 / DX) + 1)  # number of profile points used to compute mvg avg slope input (window)
  BL <- (K - 1) * DX  # baselength

  # split profile into segments by defining starting and ending indices (e.g. per 100m segment considering offsets)
  num_samples_per_segment <- segment.length / DX
  num_samples_per_offset <- segment.offset / DX
  buffer_look_ahead <- K - 2
  starts <- seq(1,length(profile)-buffer_look_ahead,by=num_samples_per_offset)
  # if there is exactly one sample missing for calculating initial IRI for next segment, delete last segment
  if ((length(profile)-buffer_look_ahead-1) %% num_samples_per_offset == 0) {
    starts <- starts[-length(starts)]
  }
  ends <- sapply(starts, function(x){ min(length(profile), x+num_samples_per_segment-1+buffer_look_ahead) })

  profile_segments <- list()
  for (i in seq_along(starts)) {
    new_segment <- profile[starts[i]:ends[i]]
    profile_segments[[i]] <- new_segment
  }

  # vector for collecting return value
  iris <- numeric()

  # loop trough segments and calculate avg iri per segment
  for (profile_segment in profile_segments) {
    segm_iri_cont <- CalculateIRIContinuously(profile_segment, iri_coef)
    iris <- c(iris, segm_iri_cont[length(segm_iri_cont)])
  }

  # return iri vector
  return(iris)
}


#' Computes the IRI for a continuously increasing segment given a road profile
#'
#' Depending on the sample size a certain buffer has to be attached to the profile
#' for calculation the slope at the end.
#' @param profile Road profile (as numeric vector in mm) whose IRIs are to be calculated.
#' @param iri_coef Set of coefficients for specific sample size (e. g. IRI_COEF_250).
#' @return Calculated IRIs (m/km) for increasing segments (as numeric vector) of the given profile.
#' @examples
#' generate_test_profile <- function (x) {
#' if (x < 1) return(0)
#' if (x >= 1 && x < 3) return(x - 1)
#' if (x >= 3 && x < 5) return(5 - x)
#' if (x >= 5) return(0)
#' }
#' x <- seq(.25, 30, by = .25)
#' test_profile <- data.frame(x = x, profile=sapply(x, generate_test_profile))
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
