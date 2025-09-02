#!/bin/bash

###
# secure:
#   robqbot_TOKEN
#   robqbot_EMAIL
#   robqbot_NAME
###

# Include git publish framework
# shellcheck source=/dev/null
source "${GITHUB_WORKSPACE}/.scripts/R_publish_framework.sh" --source-only

commit_R_debug() {
  git checkout develop
  git add ./*.Rcheck           
  git commit -m "[skip ci] debug log @robqbot GitHub Actions build: $GITHUB_RUN_NUMBER"
}

setup_git
commit_R_debug
upload_R_docs
