#!/bin/bash

# Travis CI R Build Script for SyntenyViz
# This script is specifically designed for Travis CI environment

set -e  # Exit on any error

# Variables
packageName=SyntenyViz

echo "=== Travis CI R Build Script ==="
echo "Package: ${packageName}"
echo "Build directory: ${TRAVIS_BUILD_DIR}"
echo "R version: $(R --version | head -1)"

# Function to build documentation
R_build_docs() {
  echo "Building documentation..."
  Rscript -e 'if (!require("devtools", quietly = TRUE)) install.packages("devtools", repos = "https://cran.rstudio.com/")'
  Rscript -e 'devtools::document()'
  Rscript -e 'devtools::build_vignettes()'
}

# Function to build and check package
R_build_pkgs() {
  echo "Building and checking package..."
  
  # Change to parent directory of the package
  cd "${TRAVIS_BUILD_DIR}/.." || exit 1
  
  # Build the package
  echo "Building package..."
  R CMD build "${packageName}"
  
  # Check the package
  echo "Checking package..."
  R CMD check "${packageName}_*.tar.gz" --check-subdirs=yes --no-manual
  
  echo "Package build and check completed successfully!"
}

# Function to install dependencies
install_deps() {
  echo "Installing package dependencies..."
  
  # Install Bioconductor packages
  Rscript -e 'if (!require("BiocManager", quietly = TRUE)) install.packages("BiocManager", repos = "https://cran.rstudio.com/")'
  Rscript -e 'BiocManager::install(c("GenomicRanges", "Gviz", "orthogene"), update = FALSE, ask = FALSE)'
  
  # Install CRAN packages
  Rscript -e 'install.packages(c("knitr", "rmarkdown", "dplyr", "stringr", "grid", "yaml", "testthat", "R.rsp", "roxygen2", "pkgdown", "rcmdcheck", "rversions", "urlchecker", "usethis", "devtools"), repos = "https://cran.rstudio.com/")'
}

# Main execution
echo "Starting Travis CI build process..."

# Install dependencies
install_deps

# Build documentation
R_build_docs

# Build and check package
R_build_pkgs

echo "=== Travis CI R Build Script Completed Successfully ==="
