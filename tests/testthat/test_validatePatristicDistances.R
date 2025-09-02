context("validatePatristicDistances")

testthat::test_that("validatePatristicDistances compares tree vs list", {
  testthat::skip_if_not_installed("ape")
  tree <- ape::read.tree(text = "(human:0.2,mouse:0.3);")
  pats <- list("human-mouse" = 0.25)
  res <- validatePatristicDistances(tree, pats, tolerance = 1.0)
  expect_true(is.data.frame(res))
  expect_true(all(c("species_pair","patristic_distance","tree_distance","difference","within_tolerance") %in% colnames(res)))
  expect_true(nrow(res) >= 1)
})


