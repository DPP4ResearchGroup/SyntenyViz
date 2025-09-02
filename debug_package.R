#!/usr/bin/env Rscript
# SyntenyViz Package Debugging Script
# This script provides comprehensive debugging capabilities for the SyntenyViz package

# Load required libraries
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}
library(devtools)

# Load the package for development
cat("Loading SyntenyViz package for debugging...\n")
load_all()

# Function to test getOrthHomolog with various scenarios
test_getOrthHomolog <- function() {
  cat("\n=== Testing getOrthHomolog Function ===\n")
  
  # Test 1: Normal case
  cat("\n1. Testing normal case...\n")
  tryCatch({
    result1 <- getOrthHomolog("mouse", "ENSG00000139618", debug = TRUE)
    cat("✓ Normal case completed\n")
    if (!is.null(result1)) {
      cat("  Result dimensions:", dim(result1), "\n")
    }
  }, error = function(e) {
    cat("✗ Normal case failed:", e$message, "\n")
  })
  
  # Test 2: Missing parameters
  cat("\n2. Testing missing parameters...\n")
  tryCatch({
    result2 <- getOrthHomolog(gene_id = "ENSG00000139618", debug = TRUE)
    cat("✗ Should have failed with missing species\n")
  }, error = function(e) {
    cat("✓ Correctly caught missing species error:", e$message, "\n")
  })
  
  # Test 3: Invalid gene_id_type
  cat("\n3. Testing invalid gene_id_type...\n")
  tryCatch({
    result3 <- getOrthHomolog("mouse", "ENSG00000139618", gene_id_type = "invalid", debug = TRUE)
    cat("✗ Should have failed with invalid gene_id_type\n")
  }, error = function(e) {
    cat("✓ Correctly caught invalid gene_id_type error:", e$message, "\n")
  })
  
  # Test 4: Non-character inputs
  cat("\n4. Testing non-character inputs...\n")
  tryCatch({
    result4 <- getOrthHomolog(123, "ENSG00000139618", debug = TRUE)
    cat("✗ Should have failed with non-character species\n")
  }, error = function(e) {
    cat("✓ Correctly caught non-character species error:", e$message, "\n")
  })
  
  # Test 5: Vector inputs
  cat("\n5. Testing vector inputs...\n")
  tryCatch({
    result5 <- getOrthHomolog(c("mouse", "human"), "ENSG00000139618", debug = TRUE)
    cat("✗ Should have failed with vector species\n")
  }, error = function(e) {
    cat("✓ Correctly caught vector species error:", e$message, "\n")
  })
  
  # Test 6: Symbol input type
  cat("\n6. Testing symbol input type...\n")
  tryCatch({
    result6 <- getOrthHomolog("mouse", "BRCA2", gene_id_type = "symbol", debug = TRUE)
    cat("✓ Symbol input type completed\n")
    if (!is.null(result6)) {
      cat("  Result dimensions:", dim(result6), "\n")
    }
  }, error = function(e) {
    cat("✗ Symbol input type failed:", e$message, "\n")
  })
}

# Function to test calculateOrthologSimilarity with various scenarios
test_calculateOrthologSimilarity <- function() {
  cat("\n=== Testing calculateOrthologSimilarity Function ===\n")
  
  # Create sample ortholog data
  sample_data <- data.frame(
    orthologous_gene = c("ENSMUSG00000000001", "ENSMUSG00000000002"),
    species = c("mouse", "mouse"),
    gene_id = c("ENSG00000139618", "ENSG00000141510"),
    stringsAsFactors = FALSE
  )
  
  # Test 1: Normal case
  cat("\n1. Testing normal case...\n")
  tryCatch({
    result1 <- calculateOrthologSimilarity(sample_data, "human", "mouse", debug = TRUE)
    cat("✓ Normal case completed\n")
    if (!is.null(result1)) {
      cat("  Result dimensions:", dim(result1), "\n")
      cat("  Similarity score range:", range(result1$similarity_score), "\n")
    }
  }, error = function(e) {
    cat("✗ Normal case failed:", e$message, "\n")
  })
  
  # Test 2: Different similarity types
  cat("\n2. Testing different similarity types...\n")
  similarity_types <- c("sequence", "functional", "evolutionary", "composite", "all")
  
  for (type in similarity_types) {
    tryCatch({
      result <- calculateOrthologSimilarity(sample_data, "human", "mouse", 
                                           similarity_type = type, debug = FALSE)
      cat("  ✓", type, "similarity completed\n")
    }, error = function(e) {
      cat("  ✗", type, "similarity failed:", e$message, "\n")
    })
  }
  
  # Test 3: Missing parameters
  cat("\n3. Testing missing parameters...\n")
  tryCatch({
    result2 <- calculateOrthologSimilarity(NULL, "human", "mouse", debug = TRUE)
    cat("✗ Should have failed with NULL data\n")
  }, error = function(e) {
    cat("✓ Correctly caught NULL data error:", e$message, "\n")
  })
  
  # Test 4: Invalid similarity type
  cat("\n4. Testing invalid similarity type...\n")
  tryCatch({
    result3 <- calculateOrthologSimilarity(sample_data, "human", "mouse", 
                                          similarity_type = "invalid", debug = TRUE)
    cat("✗ Should have failed with invalid similarity type\n")
  }, error = function(e) {
    cat("✓ Correctly caught invalid similarity type error:", e$message, "\n")
  })
  
  # Test 5: Different species pairs
  cat("\n5. Testing different species pairs...\n")
  species_pairs <- list(
    c("human", "mouse"),
    c("human", "rat"),
    c("mouse", "rat")
  )
  
  for (pair in species_pairs) {
    tryCatch({
      result <- calculateOrthologSimilarity(sample_data, pair[1], pair[2], debug = FALSE)
      cat("  ✓", pair[1], "-", pair[2], "completed\n")
    }, error = function(e) {
      cat("  ✗", pair[1], "-", pair[2], "failed:", e$message, "\n")
    })
  }
}

# Function to check package structure
check_package_structure <- function() {
  cat("\n=== Checking Package Structure ===\n")
  
  # Check DESCRIPTION file
  cat("\n1. Checking DESCRIPTION file...\n")
  if (file.exists("DESCRIPTION")) {
    cat("✓ DESCRIPTION file exists\n")
    desc <- readLines("DESCRIPTION")
    cat("  Package:", desc[grep("^Package:", desc)], "\n")
    cat("  Version:", desc[grep("^Version:", desc)], "\n")
  } else {
    cat("✗ DESCRIPTION file missing\n")
  }
  
  # Check R files
  cat("\n2. Checking R files...\n")
  r_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
  cat("  Found", length(r_files), "R files:\n")
  for (file in r_files) {
    cat("    -", basename(file), "\n")
  }
  
  # Check test files
  cat("\n3. Checking test files...\n")
  test_files <- list.files("tests/testthat", pattern = "\\.R$", full.names = TRUE)
  cat("  Found", length(test_files), "test files:\n")
  for (file in test_files) {
    cat("    -", basename(file), "\n")
  }
  
  # Check documentation
  cat("\n4. Checking documentation...\n")
  man_files <- list.files("man", pattern = "\\.Rd$", full.names = TRUE)
  cat("  Found", length(man_files), "documentation files\n")
}

# Function to run package checks
run_package_checks <- function() {
  cat("\n=== Running Package Checks ===\n")
  
  # Check for common issues
  cat("\n1. Running devtools::check()...\n")
  tryCatch({
    check_result <- check()
    cat("✓ Package check completed\n")
  }, error = function(e) {
    cat("✗ Package check failed:", e$message, "\n")
  })
  
  # Run tests
  cat("\n2. Running tests...\n")
  tryCatch({
    test_result <- test()
    cat("✓ Tests completed\n")
  }, error = function(e) {
    cat("✗ Tests failed:", e$message, "\n")
  })
}

# Function to check dependencies
check_dependencies <- function() {
  cat("\n=== Checking Dependencies ===\n")
  
  # Check required packages
  required_packages <- c("orthogene", "dplyr", "BiocManager", "GenomicRanges", 
                        "Gviz", "stringr", "rlist", "grid")
  
  cat("\nChecking required packages:\n")
  for (pkg in required_packages) {
    if (requireNamespace(pkg, quietly = TRUE)) {
      cat("  ✓", pkg, "is installed\n")
    } else {
      cat("  ✗", pkg, "is NOT installed\n")
    }
  }
}

# Function to test with sample data
test_with_sample_data <- function() {
  cat("\n=== Testing with Sample Data ===\n")
  
  # Sample gene IDs for testing
  sample_genes <- list(
    ensembl = c("ENSG00000139618", "ENSG00000141510", "ENSG00000157764"),
    symbol = c("BRCA2", "TP53", "BRCA1")
  )
  
  # Sample species
  sample_species <- c("mouse", "rat", "human")
  
  cat("\nTesting with sample data:\n")
  
  for (species in sample_species) {
    cat("\n  Testing species:", species, "\n")
    
    for (gene_type in names(sample_genes)) {
      for (gene_id in sample_genes[[gene_type]]) {
        cat("    Testing", gene_type, ":", gene_id, "...")
        
        tryCatch({
          result <- getOrthHomolog(species, gene_id, gene_id_type = gene_type, debug = FALSE)
          if (!is.null(result)) {
            cat(" ✓ (", nrow(result), "results)\n")
          } else {
            cat(" ✓ (no results)\n")
          }
        }, error = function(e) {
          cat(" ✗ (error:", e$message, ")\n")
        })
      }
    }
  }
}

# Main debugging function
main_debug <- function() {
  cat("=== SyntenyViz Package Debugging ===\n")
  cat("Starting comprehensive debugging...\n")
  
  # Check dependencies first
  check_dependencies()
  
  # Check package structure
  check_package_structure()
  
  # Test the main function
  test_getOrthHomolog()
  
  # Test the new similarity function
  test_calculateOrthologSimilarity()
  
  # Test with sample data
  test_with_sample_data()
  
  # Run package checks (commented out as it might take long)
  # run_package_checks()
  
  cat("\n=== Debugging Complete ===\n")
  cat("Check the output above for any issues.\n")
}

# Run the debugging if this script is executed directly
if (!interactive()) {
  main_debug()
} else {
  cat("Debugging functions loaded. Run main_debug() to start debugging.\n")
  cat("Available functions:\n")
  cat("  - main_debug(): Run all debugging checks\n")
  cat("  - test_getOrthHomolog(): Test the main function\n")
  cat("  - check_package_structure(): Check package structure\n")
  cat("  - check_dependencies(): Check required packages\n")
  cat("  - test_with_sample_data(): Test with sample data\n")
} 