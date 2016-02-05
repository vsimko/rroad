.onAttach <- function(libname, pkgname) {

  # just to show a startup message
  message <- paste("rroad", utils::packageVersion("rroad"), "loaded.")
  packageStartupMessage(message, appendLF = TRUE)

  # lazily evaluated promise (precomputed coeficients 100mm segments)
  delayedAssign("IRI_COEF_100", list(
    dx = 0.1,
    st = matrix(nrow = 4, ncol = 4),
    pr = c(0,0,0,0)
  ), assign.env = as.environment("package:rroad"))

  # lazily evaluated promise (precomputed coeficients 250mm segments)
  delayedAssign("IRI_COEF_250", list(
    dx = 0.25,
    st = matrix(nrow = 4, ncol = 4),
    pr = c(0,0,0,0)
  ), assign.env = as.environment("package:rroad"))

}
