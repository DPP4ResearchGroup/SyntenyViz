context("Ortholog Similarity Calculation Testing")

# Load required packages
library(dplyr)

# Create sample ortholog data for testing
create_sample_ortholog_data <- function() {
  data.frame(
    orthologous_gene = c("ENSMUSG00000000001", "ENSMUSG00000000002", "ENSMUSG00000000003"),
    species = c("mouse", "mouse", "mouse"),
    gene_id = c("ENSG00000139618", "ENSG00000141510", "ENSG00000157764"),
    stringsAsFactors = FALSE
  )
}

testthat::test_that("calculateOrthologSimilarity function basic functionality", {
  
  # Create sample data
  sample_data <- create_sample_ortholog_data()
  
  # Test basic functionality
  result <- calculateOrthologSimilarity(sample_data, "human", "mouse")
  
  # Check if the result is a data frame
  expect_true(is.data.frame(result))
  
  # Check if result has more columns than input (should have similarity scores)
  expect_true(ncol(result) > ncol(sample_data))
  
  # Check if similarity_score column exists
  expect_true("similarity_score" %in% colnames(result))
})

testthat::test_that("calculateOrthologSimilarity function with different similarity types", {
  
  sample_data <- create_sample_ortholog_data()
  
  # Test sequence similarity
  result_seq <- calculateOrthologSimilarity(sample_data, "human", "mouse", 
                                           similarity_type = "sequence")
  expect_true("sequence_similarity" %in% colnames(result_seq))
  expect_true("sequence_identity" %in% colnames(result_seq))
  expect_true("sequence_coverage" %in% colnames(result_seq))
  
  # Test functional similarity
  result_func <- calculateOrthologSimilarity(sample_data, "human", "mouse", 
                                            similarity_type = "functional")
  expect_true("functional_similarity" %in% colnames(result_func))
  expect_true("go_term_overlap" %in% colnames(result_func))
  expect_true("pathway_similarity" %in% colnames(result_func))
  
  # Test evolutionary similarity
  result_evo <- calculateOrthologSimilarity(sample_data, "human", "mouse", 
                                           similarity_type = "evolutionary")
  expect_true("evolutionary_distance" %in% colnames(result_evo))
  expect_true("evolutionary_similarity" %in% colnames(result_evo))
  expect_true("divergence_time" %in% colnames(result_evo))
  
  # Test all similarity types
  result_all <- calculateOrthologSimilarity(sample_data, "human", "mouse", 
                                           similarity_type = "all")
  expect_true("sequence_similarity" %in% colnames(result_all))
  expect_true("functional_similarity" %in% colnames(result_all))
  expect_true("evolutionary_similarity" %in% colnames(result_all))
})

testthat::test_that("calculateOrthologSimilarity function error handling - missing parameters", {
  
  sample_data <- create_sample_ortholog_data()
  
  # Test missing ortholog_data
  expect_error(
    calculateOrthologSimilarity(NULL, "human", "mouse"),
    "ortholog_data must be provided and cannot be NULL"
  )
  
  # Test missing species1
  expect_error(
    calculateOrthologSimilarity(sample_data, species2 = "mouse"),
    "Both species1 and species2 must be provided"
  )
  
  # Test missing species2
  expect_error(
    calculateOrthologSimilarity(sample_data, "human"),
    "Both species1 and species2 must be provided"
  )
})

testthat::test_that("calculateOrthologSimilarity function error handling - invalid inputs", {
  
  sample_data <- create_sample_ortholog_data()
  
  # Test invalid similarity_type
  expect_error(
    calculateOrthologSimilarity(sample_data, "human", "mouse", similarity_type = "invalid"),
    "Invalid similarity_type"
  )
  
  # Test non-data.frame input
  expect_error(
    calculateOrthologSimilarity(list(), "human", "mouse"),
    "ortholog_data must be a data frame"
  )
  
  # Test non-character species
  expect_error(
    calculateOrthologSimilarity(sample_data, 123, "mouse"),
    "species1 and species2 must be character strings"
  )
  
  expect_error(
    calculateOrthologSimilarity(sample_data, "human", 456),
    "species1 and species2 must be character strings"
  )
})

testthat::test_that("calculateOrthologSimilarity function with debug mode", {
  
  sample_data <- create_sample_ortholog_data()
  
  # Test with debug mode enabled
  result <- calculateOrthologSimilarity(sample_data, "human", "mouse", debug = TRUE)
  
  # Check if the result is a data frame
  expect_true(is.data.frame(result))
  
  # Check if similarity_score column exists
  expect_true("similarity_score" %in% colnames(result))
})

testthat::test_that("calculateOrthologSimilarity function with verbose mode", {
  
  sample_data <- create_sample_ortholog_data()
  
  # Test with verbose mode enabled
  result <- calculateOrthologSimilarity(sample_data, "human", "mouse", verbose = TRUE)
  
  # Check if the result is a data frame
  expect_true(is.data.frame(result))
  
  # Check if similarity_score column exists
  expect_true("similarity_score" %in% colnames(result))
})

testthat::test_that("calculateOrthologSimilarity function with different species pairs", {
  
  sample_data <- create_sample_ortholog_data()
  
  # Test different species pairs
  species_pairs <- list(
    c("human", "mouse"),
    c("human", "rat"),
    c("mouse", "rat"),
    c("human", "chicken")
  )
  
  for (pair in species_pairs) {
    result <- calculateOrthologSimilarity(sample_data, pair[1], pair[2])
    
    # Check if the result is a data frame
    expect_true(is.data.frame(result))
    
    # Check if similarity_score column exists
    expect_true("similarity_score" %in% colnames(result))
    
    # Check if similarity scores are within expected range (0-1)
    expect_true(all(result$similarity_score >= 0 & result$similarity_score <= 1))
  }
})

testthat::test_that("calculateOrthologSimilarity function composite score calculation", {
  
  sample_data <- create_sample_ortholog_data()
  
  # Test composite similarity
  result <- calculateOrthologSimilarity(sample_data, "human", "mouse", 
                                       similarity_type = "composite")
  
  # Check if all expected columns exist
  expect_true("similarity_score" %in% colnames(result))
  expect_true("confidence_level" %in% colnames(result))
  expect_true("sequence_weight" %in% colnames(result))
  expect_true("functional_weight" %in% colnames(result))
  expect_true("evolutionary_weight" %in% colnames(result))
  
  # Check if similarity scores are within expected range
  expect_true(all(result$similarity_score >= 0 & result$similarity_score <= 1))
  
  # Check if confidence levels are valid
  valid_confidence_levels <- c("High", "Medium", "Low", "Very Low")
  expect_true(all(result$confidence_level %in% valid_confidence_levels))
  
  # Check if weights sum to 1
  expect_equal(unique(result$sequence_weight + result$functional_weight + result$evolutionary_weight), 1)
})

testthat::test_that("calculateOrthologSimilarity function result sorting", {
  
  sample_data <- create_sample_ortholog_data()
  
  # Test that results are sorted by similarity score (descending)
  result <- calculateOrthologSimilarity(sample_data, "human", "mouse", 
                                       similarity_type = "composite")
  
  # Check if similarity scores are in descending order
  expect_true(all(diff(result$similarity_score) <= 0))
})

testthat::test_that("calculateOrthologSimilarity function handles empty data", {
  
  # Test with empty data frame
  empty_data <- data.frame(orthologous_gene = character(), species = character(), 
                           gene_id = character(), stringsAsFactors = FALSE)
  
  result <- calculateOrthologSimilarity(empty_data, "human", "mouse")
  
  # Check if result is still a data frame
  expect_true(is.data.frame(result))
  
  # Check if result has expected columns
  expect_true("similarity_score" %in% colnames(result))
  
  # Check if result has 0 rows
  expect_equal(nrow(result), 0)
})

testthat::test_that("calculateOrthologSimilarity function evolutionary distance calculation", {
  
  sample_data <- create_sample_ortholog_data()
  
  # Test known species pairs
  known_pairs <- list(
    list(species1 = "human", species2 = "mouse", expected_distance = 0.3),
    list(species1 = "human", species2 = "rat", expected_distance = 0.35),
    list(species1 = "mouse", species2 = "rat", expected_distance = 0.1)
  )
  
  for (pair in known_pairs) {
    result <- calculateOrthologSimilarity(sample_data, pair$species1, pair$species2, 
                                         similarity_type = "evolutionary")
    
    # Check if evolutionary distance matches expected value
    expect_equal(unique(result$evolutionary_distance), pair$expected_distance)
    
    # Check if evolutionary similarity is calculated correctly
    expected_similarity <- 1 - pair$expected_distance
    expect_equal(unique(result$evolutionary_similarity), expected_similarity)
  }
})

testthat::test_that("calculateOrthologSimilarity function with cache option", {
  
  sample_data <- create_sample_ortholog_data()
  
  # Test with cache enabled
  result_cache <- calculateOrthologSimilarity(sample_data, "human", "mouse", 
                                             use_cache = TRUE)
  
  # Test with cache disabled
  result_no_cache <- calculateOrthologSimilarity(sample_data, "human", "mouse", 
                                                use_cache = FALSE)
  
  # Both should produce similar results (structure-wise)
  expect_true(is.data.frame(result_cache))
  expect_true(is.data.frame(result_no_cache))
  expect_true("similarity_score" %in% colnames(result_cache))
  expect_true("similarity_score" %in% colnames(result_no_cache))
}) 

# Test file for calculateOrthologSimilarity function

test_that("calculateOrthologSimilarity works with basic input", {
    # Create sample ortholog data
    ortholog_data <- data.frame(
        gene_id_1 = c("ENSG00000139618", "ENSG00000157764"),
        gene_id_2 = c("ENSMUSG00000041147", "ENSMUSG00000041148"),
        species1 = c("human", "human"),
        species2 = c("mouse", "mouse"),
        stringsAsFactors = FALSE
    )
    
    # Test basic functionality
    result <- calculateOrthologSimilarity(ortholog_data, "human", "mouse", 
                                        similarity_type = "evolutionary")
    
    expect_true(is.data.frame(result))
    expect_true("evolutionary_distance" %in% colnames(result))
    expect_true("evolutionary_similarity" %in% colnames(result))
    expect_equal(nrow(result), 2)
})

test_that("getEvolutionaryDistances returns correct data structure", {
    # Test basic functionality
    result <- getEvolutionaryDistances()
    
    expect_true(is.data.frame(result))
    expect_true("species_pair" %in% colnames(result))
    expect_true("evolutionary_distance" %in% colnames(result))
    expect_true("species1" %in% colnames(result))
    expect_true("species2" %in% colnames(result))
    expect_true("evolutionary_similarity" %in% colnames(result))
    expect_true("divergence_time_mya" %in% colnames(result))
    expect_true(nrow(result) > 0)
})

test_that("getEvolutionaryDistances filters by species correctly", {
    # Test filtering by species
    result <- getEvolutionaryDistances(species1 = "human")
    
    expect_true(is.data.frame(result))
    expect_true(all(result$species1 == "human" | result$species2 == "human"))
    expect_true(nrow(result) > 0)
})

test_that("getEvolutionaryDistances filters by distance range correctly", {
    # Test filtering by distance range
    result <- getEvolutionaryDistances(min_distance = 0.1, max_distance = 0.3)
    
    expect_true(is.data.frame(result))
    expect_true(all(result$evolutionary_distance >= 0.1))
    expect_true(all(result$evolutionary_distance <= 0.3))
    expect_true(nrow(result) > 0)
})

test_that("evolutionary distances are reasonable", {
    # Test that evolutionary distances are within expected ranges
    result <- getEvolutionaryDistances()
    
    # All distances should be between 0 and 1
    expect_true(all(result$evolutionary_distance >= 0))
    expect_true(all(result$evolutionary_distance <= 1))
    
    # Similarity should be 1 - distance
    expect_equal(result$evolutionary_similarity, 1 - result$evolutionary_distance)
    
    # Check that we have some data (at least the fallback)
    expect_true(nrow(result) >= 1)
    
    # Check some specific known distances if they exist
    human_mouse <- result[result$species_pair == "human-mouse", ]
    if (nrow(human_mouse) > 0) {
        expect_equal(human_mouse$evolutionary_distance, 0.3)
    }
    
    human_chimp <- result[result$species_pair == "human-chimpanzee", ]
    if (nrow(human_chimp) > 0) {
        expect_equal(human_chimp$evolutionary_distance, 0.01)
    }
})

test_that("calculateOrthologSimilarity handles different similarity types", {
    # Create sample ortholog data
    ortholog_data <- data.frame(
        gene_id_1 = c("ENSG00000139618"),
        gene_id_2 = c("ENSMUSG00000041147"),
        species1 = c("human"),
        species2 = c("mouse"),
        stringsAsFactors = FALSE
    )
    
    # Test evolutionary similarity only
    result_evo <- calculateOrthologSimilarity(ortholog_data, "human", "mouse", 
                                            similarity_type = "evolutionary")
    expect_true("evolutionary_distance" %in% colnames(result_evo))
    expect_false("sequence_similarity" %in% colnames(result_evo))
    
    # Test composite similarity
    result_comp <- calculateOrthologSimilarity(ortholog_data, "human", "mouse", 
                                             similarity_type = "composite")
    expect_true("similarity_score" %in% colnames(result_comp))
    expect_true("confidence_level" %in% colnames(result_comp))
})

test_that("loadEvolutionaryDistances handles missing YAML file gracefully", {
    # Test that the function works even if YAML file is missing
    # This tests the fallback mechanism
    result <- loadEvolutionaryDistances()
    
    expect_true(is.list(result))
    expect_true(length(result) >= 1)
    expect_true("human-mouse" %in% names(result))
    expect_equal(result[["human-mouse"]], 0.3)
})