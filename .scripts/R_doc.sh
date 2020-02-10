#!/bin/bash

###
# secure:
#   robqbot_TOKEN
#   robqbot_EMAIL
#   robqbot_NAME
###

# Include git publish framework
# shellcheck source=/dev/null
source "${TRAVIS_BUILD_DIR}/.scripts/R_publish_framework.sh" --source-only

commit_R_docs() {
  git checkout develop
  git add NAMESPACE     # commit new NAMESPACE
  git add man 		# commit manual 
  git commit -m "[skip travis] documentation @robqbot travis build: ${TRAVIS_BUILD_NUMBER}"
}

prep_vignettes () {
  if [ ! -d "$jekyllFolder" ]
    mkdir -p "$jekyllFolder" 
  fi 
  cp -a doc/* "$jekyllFolder"
}

commit_R_vignettes() {
  git add doc -f 
  git add "$jekyllFolder"
  git commit -m "[skip travis] vignettes @robqbot travis build: ${TRAVIS_BUILD_NUMBER}"  
}

setup_git
commit_R_docs
commit_R_vignettes
upload_R_docs
