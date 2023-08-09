test_that("mflow_probability works", {
  props <- c(0.0037825570, 0.0006065385, 0.0010901371, 0.0010616181)
  fracs <- c(0.146, 0.161, 0.237, 0.36)
  expectedProbs <- c(0.427953722771148, 0.0756733082390105, 0.200211001311819, 0.296161967678021)
  expect_equal(mflow_probability(props, fracs), expectedProbs)
})

test_that("mflow_apply works", {
  props <- readRDS(test_path("fixtures", "iggASVProps.rda"))
  fracs <- readRDS(test_path("fixtures", "iggFracs.rda"))
  expectedProbs <- c()
  expect_equal(mflow_apply(props[,-1], fracs), expectedProbs)
})
