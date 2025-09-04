#!/bin/bash

#variables
packageName=SyntenyViz

# Include R CMD build and R CMD check
R_build_docs() {
  echo "Building documentation..."
  Rscript -e 'devtools::document()'
  Rscript -e 'devtools::build_vignettes()'
}

R_build_pkgs() {
  echo "Building and checking package..."
  # Use GitHub Actions workspace instead of TRAVIS_BUILD_DIR
  cd "${GITHUB_WORKSPACE}/.." || exit 1
  R CMD build "${packageName}"
  R CMD check "${packageName}_*.tar.gz" --check-subdirs=yes
}

R_build_docs
R_build_pkgs
