#!/bin/bash

#variables
packageName=SyntenyViz

# Include R CMD build and R CMD check
R_build_docs() {
  R -e 'devtools::document()'
  R -e 'devtools::build_vignettes()'
}

R_build_pkgs() {
  cd "${TRAVIS_BUILD_DIR}/../" || exit
  R CMD build "${packageName}"
  R CMD check "${packageName}_*.tar.gz" --check-subdirs=yes
}

R_build_docs
R_build_pkgs
