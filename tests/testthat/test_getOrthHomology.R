context("OrthHomology Search Query Testing")
# Load required packages
library(orthogene)

testthat::test_that("getOrthHomolog function across species", {
  
  # Test parameters
  species <- "mouse"
  gene_id <- "ENSG00000139618"
  gene_id_type <- "ensembl_gene_id"
  
  # Call the function
  result <- getOrthHomolog(species, gene_id, gene_id_type)
  
  # Check if the result is a data frame
  expect_is(result, "data.frame")
  
  # Check if the result contains expected columns
  expect_true("orthologous_gene" %in% colnames(result))
})