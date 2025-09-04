#!/bin/bash

# Travis CI R Debug Script for SyntenyViz
# This script is specifically designed for Travis CI environment

set -e  # Exit on any error

echo "=== Travis CI R Debug Script ==="
echo "Build directory: ${TRAVIS_BUILD_DIR}"
echo "Build number: ${TRAVIS_BUILD_NUMBER}"

# Include git publish framework
# shellcheck source=/dev/null
source "${TRAVIS_BUILD_DIR}/.scripts/R_publish_framework.sh" --source-only

commit_R_debug() {
  echo "Committing debug logs..."
  git checkout develop
  git add ./*.Rcheck           
  git commit -m "[skip travis] debug log @robqbot Travis CI build: ${TRAVIS_BUILD_NUMBER}"
}

setup_git
commit_R_debug
upload_R_docs

echo "=== Travis CI R Debug Script Completed ==="
