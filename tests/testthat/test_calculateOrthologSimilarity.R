context("Ortholog similarity calculations")

testthat::test_that("calculateOrthologSimilarity validates inputs", {
  expect_error(calculateOrthologSimilarity(NULL, "human", "mouse"),
               "ortholog_data must be provided")
  expect_error(calculateOrthologSimilarity(list(), "human", "mouse"),
               "ortholog_data must be a data frame")
  df <- data.frame(orthologous_gene = character(), stringsAsFactors = FALSE)
  expect_error(calculateOrthologSimilarity(df, species1 = NULL, species2 = "mouse"),
               "Both species1 and species2 must be provided")
  expect_error(calculateOrthologSimilarity(df, species1 = 1, species2 = "mouse"),
               "must be character strings")
  expect_error(calculateOrthologSimilarity(df, "human", "mouse", similarity_type = "bogus"),
               "Invalid similarity_type")
})

testthat::test_that("calculateOrthologSimilarity returns a data.frame with scores", {
  df <- data.frame(
    query_gene = c("ENSG000001"),
    orthologous_gene = c("ENSMUSG000000"),
    stringsAsFactors = FALSE
  )
  res <- calculateOrthologSimilarity(df, "human", "mouse", similarity_type = "composite", debug = TRUE)
  expect_true(is.data.frame(res))
  expect_true(all(c("sequence_similarity","functional_similarity","evolutionary_similarity") %in% colnames(res)))
  expect_true("similarity_score" %in% colnames(res))
})


