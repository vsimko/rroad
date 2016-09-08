.onAttach <- function(libname, pkgname) {

  # just to show a startup message
  message <- paste("rroad", utils::packageVersion("rroad"), "loaded.")
  packageStartupMessage(message, appendLF = TRUE)

  # lazily evaluated promise
  delayedAssign("IRI_COEF_100", list(
    dx = 0.1,
    st = matrix(nrow = 4, ncol = 4, byrow = TRUE,
                  c(.9994014, 4.442351E-03, 2.188854E-04, 5.72179E-05,
                    -.2570548, .975036, 7.966216E-03, 2.458427E-02,
                    3.960378E-03, 3.814527E-04, .9548048, 4.055587E-03,
                    1.687312, .1638951, -19.34264, .7948701)),
    pr = c(3.793992E-04, .2490886, 4.123478E-02, 17.65532)
  ), assign.env = as.environment("package:rroad"))

  # lazily evaluated promise
  delayedAssign("IRI_COEF_250", list(
    dx = 0.25,
    st = matrix(nrow = 4, ncol = 4, byrow = TRUE,
                c(.9966071, 1.091514E-02, -2.083274E-03, 3.190145E-04,
                  -.5563044, .9438768, -.8324718, 5.064701E-02,
                  2.153176E-02, 2.126763E-03, .7508714, 8.221888E-03,
                  3.335013, .3376467, -39.12762, .4347564)),
    pr = c(5.476107E-03, 1.388776, .2275968, 35.79262)
  ), assign.env = as.environment("package:rroad"))

}

#' precomputed coeficients 100 mm segments (lazily evaluated promise)
#' @name IRI_COEF_100
NULL

#' precomputed coeficients 250 mm segments (lazily evaluated promise)
#' @name IRI_COEF_250
NULL
