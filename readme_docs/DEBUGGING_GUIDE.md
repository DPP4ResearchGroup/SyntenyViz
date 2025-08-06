# SyntenyViz Package Debugging Guide

## Overview
This guide provides comprehensive debugging techniques for the SyntenyViz R package.

## Quick Start

### 1. Load Package for Development
```r
# In R console or RStudio
devtools::load_all()
```

### 2. Run Debugging Script
```r
# Source the debugging script
source("debug_package.R")

# Run comprehensive debugging
main_debug()
```

### 3. Test Individual Functions
```r
# Test the main function with debug mode
getOrthHomolog("mouse", "ENSG00000139618", debug = TRUE)

# Test with verbose mode
getOrthHomolog("mouse", "ENSG00000139618", verbose = TRUE)

# Test the new similarity function
orthologs <- getOrthHomolog("mouse", "ENSG00000139618")
similarity <- calculateOrthologSimilarity(orthologs, "human", "mouse", debug = TRUE)
```

## Debugging Functions Available

### `test_getOrthHomolog()`
Tests the main function with various scenarios:
- Normal cases
- Missing parameters
- Invalid inputs
- Error conditions
- Different input types

### `test_calculateOrthologSimilarity()`
Tests the new similarity calculation function:
- Different similarity types (sequence, functional, evolutionary, composite, all)
- Various species pairs
- Error handling
- Input validation

### `check_package_structure()`
Checks the package structure:
- DESCRIPTION file
- R files
- Test files
- Documentation files

### `check_dependencies()`
Verifies all required packages are installed:
- orthogene
- dplyr
- BiocManager
- GenomicRanges
- Gviz
- stringr
- rlist
- grid

### `test_with_sample_data()`
Tests the function with various sample data:
- Different species (mouse, rat, human)
- Different gene types (ensembl, symbol)
- Multiple gene IDs

### `run_package_checks()`
Runs comprehensive package checks:
- devtools::check()
- devtools::test()

## Common Debugging Techniques

### 1. Interactive Debugging
```r
# Set breakpoint in function
debug(getOrthHomolog)

# Call function (will pause at breakpoint)
getOrthHomolog("mouse", "ENSG00000139618")

# Remove debug mode
undebug(getOrthHomolog)
```

### 2. Step-by-Step Debugging
```r
# Add browser() statement in function
getOrthHomolog <- function(species, gene_id, ...) {
    browser()  # Execution will pause here
    # ... rest of function
}
```

### 3. Error Recovery
```r
# Enable error recovery
options(error = recover)

# Call function that might error
getOrthHomolog("invalid", "invalid")

# Disable error recovery
options(error = NULL)
```

### 4. Trace Function Calls
```r
# Trace function execution
trace(getOrthHomolog, browser)

# Call function (will pause at each line)
getOrthHomolog("mouse", "ENSG00000139618")

# Remove trace
untrace(getOrthHomolog)
```

## Testing Commands

### Run All Tests
```r
devtools::test()
```

### Run Specific Test File
```r
devtools::test_file("tests/testthat/test_getOrthHomology.R")
```

### Run Package Checks
```r
devtools::check()
```

### Build Package
```r
devtools::build()
```

### Install Package
```r
devtools::install()
```

## Common Issues and Solutions

### 1. Package Not Found
```r
# Install missing package
BiocManager::install("orthogene")
```

### 2. Function Not Found
```r
# Check if function is exported
ls("package:SyntenyViz")
```

### 3. Documentation Issues
```r
# Generate documentation
devtools::document()
```

### 4. Test Failures
```r
# Run tests with verbose output
devtools::test(reporter = "verbose")
```

## Debugging Checklist

- [ ] All required packages installed
- [ ] Package loads without errors
- [ ] Functions are properly exported
- [ ] Documentation is complete
- [ ] Tests pass
- [ ] Package checks pass
- [ ] Error handling works correctly
- [ ] Edge cases are handled
- [ ] Performance is acceptable

## Performance Debugging

### Profile Function Performance
```r
# Install profvis if not available
if (!requireNamespace("profvis", quietly = TRUE)) {
    install.packages("profvis")
}

# Profile function
profvis::profvis({
    getOrthHomolog("mouse", "ENSG00000139618")
})
```

### Memory Usage
```r
# Check memory usage
pryr::mem_used()

# Profile memory
pryr::mem_change({
    result <- getOrthHomolog("mouse", "ENSG00000139618")
})
```

## Advanced Debugging

### 1. Mock Dependencies
```r
# Mock orthogene package for testing
mock_orthogene <- function(...) {
    data.frame(
        orthologous_gene = "MOCK_GENE",
        species = "mouse",
        stringsAsFactors = FALSE
    )
}

# Replace function temporarily
assignInNamespace("get_orthologs", mock_orthogene, "orthogene")
```

### 2. Logging
```r
# Add logging to function
getOrthHomolog <- function(species, gene_id, ...) {
    message("DEBUG: Function called with species=", species, " gene_id=", gene_id)
    # ... rest of function
}
```

### 3. Unit Testing with Mocks
```r
# Use testthat with mocking
library(testthat)
library(mockery)

test_that("function works with mocked data", {
    mock_get_orthologs <- mock(data.frame(gene = "test"))
    with_mock(
        get_orthologs = mock_get_orthologs,
        {
            result <- getOrthHomolog("mouse", "test")
            expect_equal(nrow(result), 1)
        }
    )
})
```

## Troubleshooting

### Common Error Messages

1. **"Package 'orthogene' is required but not installed"**
   - Solution: `BiocManager::install("orthogene")`

2. **"Function not found"**
   - Solution: Check if function is exported in NAMESPACE

3. **"Invalid 'gene_id_type'"**
   - Solution: Use only "ensembl_gene_id" or "symbol"

4. **"Both 'species' and 'gene_id' must be provided"**
   - Solution: Provide both parameters

### Getting Help

1. Check the function documentation: `?getOrthHomolog`
2. Run the debugging script: `source("debug_package.R")`
3. Check package status: `devtools::check()`
4. Review test results: `devtools::test()`

## Best Practices

1. **Always test with debug mode first**
2. **Use tryCatch for error handling**
3. **Validate inputs thoroughly**
4. **Test edge cases**
5. **Keep tests up to date**
6. **Document all functions**
7. **Use meaningful error messages**
8. **Profile performance regularly** 