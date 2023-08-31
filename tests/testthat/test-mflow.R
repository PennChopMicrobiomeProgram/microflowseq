dual_cts <- matrix(c(5, 7, 19, 13), nrow = 2)
dual_fracs <- 35 * colSums(dual_cts)
dual_props <- apply(dual_cts, 2, normalize_sum)

test_that("normalize_sum works", {
  vec <- c(25, 75)
  expect_equal(normalize_sum(vec), c(0.25, 0.75))
})

test_that("mflow_probability works", {
  props <- c(0.0037825570, 0.0006065385, 0.0010901371, 0.0010616181)
  fracs <- c(0.146, 0.161, 0.237, 0.36)
  expectedProbs <- c(0.427953722771148, 0.0756733082390105, 0.200211001311819, 0.296161967678021)
  expect_equal(mflow_probability(props, fracs), expectedProbs)
})

test_that("mflow_apply works", {
  expectedProbs <- matrix(c(0.2083333, 0.3500000, 0.7916667, 0.6500000), nrow=2)
  expect_equal(round(mflow_apply(dual_props, dual_fracs), 7), expectedProbs)
})
