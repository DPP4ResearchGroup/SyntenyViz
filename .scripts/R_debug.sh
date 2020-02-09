#!/bin/bash

###
# secure:
#   robqbot_TOKEN
#   robqbot_EMAIL
#   robqbot_NAME
###

# Include git publish framework
# shellcheck source=/dev/null
source "$(TRAVIS_BUILD_DIR)/.scripts/R_publish_framework.sh" --source-onlly

commit_R_debug() {
  git checkout develop
  git add ./*.Rcheck           
  git commit -m "[skip travis] debug log @robqbot travis build: $TRAVIS_BUILD_NUMBER"
}

setup_git
commit_R_debug
upload_R_docs
