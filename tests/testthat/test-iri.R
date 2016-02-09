context("IRI computation")

# Tests ==========

test_that("First test", {
  profile <- rnorm(10000)
  iri <- CalculateIRIperSegments(profile, IRI_COEF_100, 20)
  expect_equal(length(iri), 50)
})
