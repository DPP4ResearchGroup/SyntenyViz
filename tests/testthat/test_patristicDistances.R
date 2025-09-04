context("Patristic distance utilities")

testthat::test_that("loadPatristicDistances returns a named list", {
  d <- loadPatristicDistances()
  expect_true(is.list(d))
  expect_true(!is.null(names(d)))
})

testthat::test_that("patristicToDivergenceTime and divergenceTimeToPatristic are inverses (approx)", {
  d <- 0.3456
  t <- patristicToDivergenceTime(d)
  d2 <- divergenceTimeToPatristic(t)
  expect_equal(d2, d, tolerance = 1e-8)
})

testthat::test_that("calculatePatristicDistance handles simple tree", {
  testthat::skip_if_not_installed("ape")
  tree <- ape::read.tree(text = "(human:0.1,mouse:0.3);")
  dist <- calculatePatristicDistance(tree, "human", "mouse")
  expect_true(is.numeric(dist))
  expect_false(is.na(dist))
})

testthat::test_that("getPatristicDistances returns a data.frame with expected columns", {
  df <- getPatristicDistances()
  expect_true(is.data.frame(df))
  expect_true(all(c("species_pair","patristic_distance","species1","species2") %in% colnames(df)))
})

testthat::test_that("getDistanceConfidence returns a string", {
  conf <- getDistanceConfidence("human-mouse")
  expect_true(is.character(conf))
})

testthat::test_that("getPatristicDistanceSummary returns expected statistics", {
  s <- getPatristicDistanceSummary()
  expect_true(is.list(s))
  expect_true(all(c("total_pairs","mean_distance","median_distance","min_distance","max_distance") %in% names(s)))
})


