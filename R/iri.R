# This file provides a function for calculation the international roughness index (IRI) given a road profile.

#' Computes the IRI for fixed length segments (e.g. 100 m segments) given a road profile
#'
#' @param profile Road profile (as numeric vector in mm) whose IRI is to be calculated.
#' @param sample.interval Distance (in m) between two samples of the given profile.
#' @param segment.length Distance (in m) for which the IRI is to be calculated. Default is 100 m.
#'
#' @return Calculated IRI (as numeric vector) of the given profile.
#'
#' @examples
#' iri <- CalculateIRI(profile, 0.1)
#' @export
CalculateIRI <- function(profile, sample.interval, segment.length = 100) {
  # initialize costants
  sample.interval  # DX (m)
  k = max(2, (0.25 / sample.interval + 0.5) + 1)

  # initialize variables

  # loop trough profile and calculate roughness

  # compute slope input

  # simulate vehicle response

  # retrun iri series
  return(NULL)
}
