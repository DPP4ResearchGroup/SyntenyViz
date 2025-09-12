#!/bin/bash

###
# compatible with both Travis CI and GitHub Actions
# uses GITHUB_WORKSPACE if available, fallback to TRAVIS_BUILD_DIR for compatibility
# uses GITHUB_RUN_NUMBER if available, fallback to TRAVIS_BUILD_NUMBER for compatibility
#
###
# travis secure:
#   robqbot_TOKEN
#   robqbot_EMAIL
#   robqbot_NAME
###

# Include git publish framework
# shellcheck source=/dev/null
# Use GITHUB_WORKSPACE if available, fallback to TRAVIS_BUILD_DIR for compatibility
WORKSPACE_DIR="${GITHUB_WORKSPACE:-${TRAVIS_BUILD_DIR}}"
source "${WORKSPACE_DIR}/.scripts/R_publish_framework.sh" --source-only

commit_R_docs() {
  git checkout develop
  git add NAMESPACE     # commit new NAMESPACE
  git add man 		# commit manual 
  git add doc -f	# commit doc
  git add vignettes	# commit vignettes output assets
  # Use GITHUB_RUN_NUMBER if available, fallback to TRAVIS_BUILD_NUMBER for compatibility
  BUILD_NUMBER="${GITHUB_RUN_NUMBER:-${TRAVIS_BUILD_NUMBER}}"
  git commit -m "[skip ci] documentation @robqbot github actions build: ${BUILD_NUMBER}"
}

prep_vignettes () {
  if [[ ! -d "$jekyllFolder" ]]; then mkdir -p "$jekyllFolder"; fi 
  cp -a doc/* "$jekyllFolder"
}

commit_R_vignettes() {
  git add "$jekyllFolder"
  # Use GITHUB_RUN_NUMBER if available, fallback to TRAVIS_BUILD_NUMBER for compatibility
  BUILD_NUMBER="${GITHUB_RUN_NUMBER:-${TRAVIS_BUILD_NUMBER}}"
  git commit -m "[skip ci] vignettes @robqbot github actions build: ${BUILD_NUMBER}"  
}

setup_git
commit_R_docs
prep_vignettes
commit_R_vignettes
upload_R_docs
