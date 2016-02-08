.onAttach <- function(libname, pkgname) {

  # just to show a startup message
  message <- paste("rroad", utils::packageVersion("rroad"), "loaded.")
  packageStartupMessage(message, appendLF = TRUE)

  # lazily evaluated promise (precomputed coeficients 100mm segments)
  delayedAssign("IRI_COEF_100", list(
    dx = 0.1,
    st = t(matrix(nrow = 4, ncol = 4,
                  c(.9994014, 4.442351E-03, 2.188854E-04, 5.72179E-05,
                    -.2570548, .975036, 7.966216E-03, 2.458427E-02,
                    3.960378E-03, 3.814527E-04, .9548048, 4.055587E-03,
                    1.687312, .1638951, -19.34264, .7948701))),
    pr = c(3.793992E-04, .2490886, 4.123478E-02, 17.65532)
  ), assign.env = as.environment("package:rroad"))

#   # lazily evaluated promise (precomputed coeficients 250mm segments)
#   delayedAssign("IRI_COEF_250", list(
#     dx = 0.25,
#     st = matrix(nrow = 4, ncol = 4),  # TODO
#     pr = c(0.005476107, 1.388776, 0.2275968, 35.79262)
#   ), assign.env = as.environment("package:rroad"))

}


