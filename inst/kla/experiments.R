####### sample execution
if (!exists("plano")) {
  plano <<- read.csv2("~/R_projects/rroad/inst/kla/ow_plano.csv")
}

iri <- CalculateIRIperSegments(1:104, IRI_COEF_100, 1)
iri <- CalculateIRIContinuously(1:3, IRI_COEF_100)



#######  rebuild test from paper
generate_test_profile <- function (x) {
  if (x < 1) return(0)
  if (x >= 1 && x < 3) return(x - 1)
  if (x >= 3 && x < 5) return(5 - x)
  if (x >= 5) return(0)
}
x <- seq(.25, 30, by = .25)
test_profile <- data.frame(x=x, profile=sapply(x, generate_test_profile))
test_profile$iri <- CalculateIRIContinuously(test_profile$profile, IRI_COEF_250)
plot(x = test_profile$x, y = test_profile$profile, ylim = c(0, 8), xlim = c(0,25), type = "l")
lines(x = test_profile$x, y = test_profile$iri*10)

head(test_profile, n = 30)



####### starting and ending points definition for segmantation
profile_length <- 104
seg_length <- 10
buffer_look_ahead <- 2

starts <- seq(1,profile_length-buffer_look_ahead,by=seg_length)
if ((profile_length-buffer_look_ahead-1) %% seg_length == 0) { # this considers, that the iri calculation needs normaly just k-1 smaples, not for the first calculation per segment
  starts <- starts[-length(starts)]
}
starts
length(starts)
ends <- sapply(starts, function(x){ min(profile_length, x+seg_length-1+buffer_look_ahead) })
ends
length(ends)





