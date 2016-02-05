.onAttach <- function(libname, pkgname) {
  # just to show a startup message
  message <- paste("rroad", utils::packageVersion("rroad"), "loaded.")
  packageStartupMessage(message, appendLF = TRUE)
}

#' Coeficients for computing IRI for 100mm segments
iri_coef_100mm <- list(
  dx = 0.1,
  st = matrix(nrow = 4, ncol = 4),
  pr = c(0,0,0,0)
)

#' Coeficients for computing IRI for 250mm segments
iri_coef_250mm <- list(
  dx = 0.25,
  st = matrix(nrow = 4, ncol = 4),
  pr = c(0,0,0,0)
)
