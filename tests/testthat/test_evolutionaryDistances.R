context("Evolutionary distances utilities")

testthat::test_that("getEvolutionaryDistances returns expected columns", {
  df <- getEvolutionaryDistances()
  expect_true(is.data.frame(df))
  expect_true(all(c("species_pair","evolutionary_distance","species1","species2") %in% colnames(df)))
})


