context("OrthHomology Search Query Testing")

# Load required packages
library(orthogene)

testthat::test_that("getOrthHomolog function basic functionality", {
  
  # Test parameters
  species <- "mouse"
  gene_id <- "ENSG00000139618"
  gene_id_type <- "ensembl_gene_id"
  
  # Call the function
  result <- getOrthHomolog(species, gene_id, gene_id_type)
  
  # Check if the result is a data frame or NULL
  expect_true(is.data.frame(result) || is.null(result))
  
  # If result is not NULL, check if it contains expected columns
  if (!is.null(result) && nrow(result) > 0) {
    expect_true("orthologous_gene" %in% colnames(result))
  }
})

testthat::test_that("getOrthHomolog function with symbol input", {
  
  # Test with symbol input
  result <- getOrthHomolog("mouse", "BRCA2", gene_id_type = "symbol")
  
  # Check if the result is a data frame or NULL
  expect_true(is.data.frame(result) || is.null(result))
  
  # If result is not NULL, check if it contains expected columns
  if (!is.null(result) && nrow(result) > 0) {
    expect_true("orthologous_gene" %in% colnames(result))
  }
})

testthat::test_that("getOrthHomolog function error handling - missing parameters", {
  
  # Test missing species parameter
  expect_error(
    getOrthHomolog(gene_id = "ENSG00000139618"),
    "Both 'species' and 'gene_id' must be provided"
  )
  
  # Test missing gene_id parameter
  expect_error(
    getOrthHomolog(species = "mouse"),
    "Both 'species' and 'gene_id' must be provided"
  )
})

testthat::test_that("getOrthHomolog function error handling - invalid gene_id_type", {
  
  # Test invalid gene_id_type
  expect_error(
    getOrthHomolog("mouse", "ENSG00000139618", gene_id_type = "invalid"),
    "Invalid 'gene_id_type'. Must be 'ensembl_gene_id' or 'symbol'"
  )
})

testthat::test_that("getOrthHomolog function error handling - non-character inputs", {
  
  # Test non-character species
  expect_error(
    getOrthHomolog(123, "ENSG00000139618"),
    "'species' must be a single character string"
  )
  
  # Test non-character gene_id
  expect_error(
    getOrthHomolog("mouse", 123),
    "'gene_id' must be a single character string"
  )
})

testthat::test_that("getOrthHomolog function error handling - vector inputs", {
  
  # Test vector species
  expect_error(
    getOrthHomolog(c("mouse", "human"), "ENSG00000139618"),
    "'species' must be a single character string"
  )
  
  # Test vector gene_id
  expect_error(
    getOrthHomolog("mouse", c("ENSG00000139618", "ENSG00000141510")),
    "'gene_id' must be a single character string"
  )
})

testthat::test_that("getOrthHomolog function with debug mode", {
  
  # Test with debug mode enabled
  result <- getOrthHomolog("mouse", "ENSG00000139618", debug = TRUE)
  
  # Check if the result is a data frame or NULL
  expect_true(is.data.frame(result) || is.null(result))
})

testthat::test_that("getOrthHomolog function with verbose mode", {
  
  # Test with verbose mode enabled
  result <- getOrthHomolog("mouse", "ENSG00000139618", verbose = TRUE)
  
  # Check if the result is a data frame or NULL
  expect_true(is.data.frame(result) || is.null(result))
})

testthat::test_that("getOrthHomolog function with different species", {
  
  # Test with different species
  species_list <- c("mouse", "rat", "human")
  
  for (species in species_list) {
    result <- getOrthHomolog(species, "ENSG00000139618")
    
    # Check if the result is a data frame or NULL
    expect_true(is.data.frame(result) || is.null(result))
  }
})

testthat::test_that("getOrthHomolog function handles empty results gracefully", {
  
  # Test with a gene that might not have orthologs
  result <- getOrthHomolog("mouse", "NONEXISTENT_GENE")
  
  # Should return NULL for non-existent genes
  expect_true(is.null(result))
})

testthat::test_that("getOrthHomolog function package dependency check", {
  
  # This test assumes orthogene is available
  # In a real scenario, you might want to mock this
  expect_true(requireNamespace("orthogene", quietly = TRUE))
})