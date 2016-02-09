# This file provides a function for calculation the international roughness index (IRI) given a road profile.

#' Computes the IRI for fixed length segments (e.g. 100 m segments) given a road profile
#'
#' @param profile Road profile (as numeric vector in mm) whose IRI is to be calculated.
#' @param iri_coef Set of coefficients for specific sample size (e. g. IRI_COEF_100).
#' @param segment.length Distance (in m) for which the IRI is to be calculated. Default is 100 m.
#' @return Calculated IRI per segment (as numeric) of the given profile.
#' @examples
#' iri <- CalculateIRI(profile, 0.1)
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
  profile_segments <- split(profile, ceiling(seq_along(profile)/num_samples_per_segment))

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
        print("out of semgents or ")
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
